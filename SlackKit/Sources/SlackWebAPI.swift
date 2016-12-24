//
// SlackWebAPI.swift
//
// Copyright © 2016 Peter Zignego. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

internal enum SlackAPIEndpoint: String {
    case apiTest = "api.test"
    case authTest = "auth.test"
    case channelsHistory = "channels.history"
    case channelsInfo = "channels.info"
    case channelsList = "channels.list"
    case channelsMark = "channels.mark"
    case channelsSetPurpose = "channels.setPurpose"
    case channelsSetTopic = "channels.setTopic"
    case chatDelete = "chat.delete"
    case chatMeMessage = "chat.meMessage"
    case chatPostMessage = "chat.postMessage"
    case chatUpdate = "chat.update"
    case dndInfo = "dnd.info"
    case dndTeamInfo = "dnd.teamInfo"
    case emojiList = "emoji.list"
    case filesCommentsAdd = "files.comments.add"
    case filesCommentsEdit = "files.comments.edit"
    case filesCommentsDelete = "files.comments.delete"
    case filesDelete = "files.delete"
    case filesUpload = "files.upload"
    case groupsClose = "groups.close"
    case groupsHistory = "groups.history"
    case groupsInfo = "groups.info"
    case groupsList = "groups.list"
    case groupsMark = "groups.mark"
    case groupsOpen = "groups.open"
    case groupsSetPurpose = "groups.setPurpose"
    case groupsSetTopic = "groups.setTopic"
    case imClose = "im.close"
    case imHistory = "im.history"
    case imList = "im.list"
    case imMark = "im.mark"
    case imOpen = "im.open"
    case mpimClose = "mpim.close"
    case mpimHistory = "mpim.history"
    case mpimList = "mpim.list"
    case mpimMark = "mpim.mark"
    case mpimOpen = "mpim.open"
    case pinsAdd = "pins.add"
    case pinsRemove = "pins.remove"
    case reactionsAdd = "reactions.add"
    case reactionsGet = "reactions.get"
    case reactionsList = "reactions.list"
    case reactionsRemove = "reactions.remove"
    case rtmStart = "rtm.start"
    case starsAdd = "stars.add"
    case starsRemove = "stars.remove"
    case teamInfo = "team.info"
    case usersGetPresence = "users.getPresence"
    case usersInfo = "users.info"
    case usersList = "users.list"
    case usersSetActive = "users.setActive"
    case usersSetPresence = "users.setPresence"
}

public class SlackWebAPI {
    
    public typealias FailureClosure = (_ error: SlackError)->Void
    
    public enum InfoType: String {
        case purpose = "purpose"
        case topic = "topic"
    }
    
    public enum ParseMode: String {
        case full = "full"
        case none = "none"
    }
    
    public enum Presence: String {
        case auto = "auto"
        case away = "away"
    }
    
    private enum ChannelType: String {
        case channel = "channel"
        case group = "group"
        case im = "im"
    }
    
    private let networkInterface: NetworkInterface
    private let token: String
    
    init(networkInterface: NetworkInterface, token: String) {
        self.networkInterface = networkInterface
        self.token = token
    }
    
    convenience public init(slackClient: SlackClient) {
        self.init(networkInterface: slackClient.api, token: slackClient.token)
    }
    
    //MARK: - RTM
    public func rtmStart(simpleLatest: Bool? = nil, noUnreads: Bool? = nil, mpimAware: Bool? = nil, success: ((_ response: [String: Any])->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any?] = ["simple_latest": simpleLatest, "no_unreads": noUnreads, "mpim_aware": mpimAware]
        networkInterface.request(endpoint: .rtmStart, token: token, parameters: filterNilParameters(parameters), successClosure: {
                (response) -> Void in
                success?(response)
            }) {(error) -> Void in
                failure?(error)
            }
    }
    
    //MARK: - Auth Test
    public func authenticationTest(success: ((_ authenticated: Bool)->Void)?, failure: FailureClosure?) {
        networkInterface.request(endpoint: .authTest, token: token, parameters: nil, successClosure: {
            (response) -> Void in
                success?(true)
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    //MARK: - Channels
    public func channelHistory(id: String, latest: String = "\(Date().slackTimestamp)", oldest: String = "0", inclusive: Bool = false, count: Int = 100, unreads: Bool = false, success: ((_ history: History?)->Void)?, failure: FailureClosure?) {
        history(endpoint: .channelsHistory, id: id, latest: latest, oldest: oldest, inclusive: inclusive, count: count, unreads: unreads, success: {
            (history) -> Void in
                success?(history)
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    public func channelInfo(id: String, success: ((_ channel: Channel?)->Void)?, failure: FailureClosure?) {
        info(endpoint: .channelsInfo, type:ChannelType.channel, id: id, success: {
            (channel) -> Void in
                success?(channel)
            }) { (error) -> Void in
                failure?(error)
        }
    }
    
    public func channelsList(excludeArchived: Bool = false, success: ((_ channels: [Any]?)->Void)?, failure: FailureClosure?) {
        list(endpoint: .channelsList, type:ChannelType.channel, excludeArchived: excludeArchived, success: {
            (channels) -> Void in
                success?(channels)
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    public func markChannel(channel: String, timestamp: String, success: ((_ ts: String)->Void)?, failure: FailureClosure?) {
        mark(endpoint: .channelsMark, channel: channel, timestamp: timestamp, success: {
            (ts) -> Void in
                success?(timestamp)
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    public func setChannelPurpose(channel: String, purpose: String, success: ((_ purposeSet: Bool)->Void)?, failure: FailureClosure?) {
        setInfo(endpoint: .channelsSetPurpose, type: .purpose, channel: channel, text: purpose, success: {
            (purposeSet) -> Void in
                success?(purposeSet)
            }) { (error) -> Void in
                failure?(error)
        }
    }
    
    public func setChannelTopic(channel: String, topic: String, success: ((_ topicSet: Bool)->Void)?, failure: FailureClosure?) {
        setInfo(endpoint: .channelsSetTopic, type: .topic, channel: channel, text: topic, success: {
            (topicSet) -> Void in
                success?(topicSet)
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    //MARK: - Messaging
    public func deleteMessage(channel: String, ts: String, success: ((_ deleted: Bool)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any] = ["channel": channel, "ts": ts]
        networkInterface.request(endpoint: .chatDelete, token: token, parameters: parameters, successClosure: { (response) -> Void in
                success?(true)
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    public func sendMessage(channel: String, text: String, username: String? = nil, asUser: Bool? = nil, parse: ParseMode? = nil, linkNames: Bool? = nil, attachments: [Attachment?]? = nil, unfurlLinks: Bool? = nil, unfurlMedia: Bool? = nil, iconURL: String? = nil, iconEmoji: String? = nil, success: (((ts: String?, channel: String?))->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any?] = ["channel":channel, "text":text.slackFormatEscaping, "as_user":asUser, "parse":parse?.rawValue, "link_names":linkNames, "unfurl_links":unfurlLinks, "unfurlMedia":unfurlMedia, "username":username, "attachments":encodeAttachments(attachments: attachments), "icon_url":iconURL, "icon_emoji":iconEmoji]
        networkInterface.request(endpoint: .chatPostMessage, token: token, parameters: filterNilParameters(parameters), successClosure: {
            (response) -> Void in
                success?((ts: response["ts"] as? String, response["channel"] as? String))
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    public func sendMeMessage(_ channel: String, text: String, success: (((ts: String?, channel: String?))->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any?] = ["channel": channel, "text": text.slackFormatEscaping]
        networkInterface.request(endpoint: .chatMeMessage, token: token, parameters: filterNilParameters(parameters), successClosure: {
            (response) -> Void in
            success?((ts: response["ts"] as? String, response["channel"] as? String))
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    public func updateMessage(channel: String, ts: String, message: String, attachments: [Attachment?]? = nil, parse:ParseMode = .none, linkNames: Bool = false, success: ((_ updated: Bool)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any?] = ["channel": channel, "ts": ts, "text": message.slackFormatEscaping, "parse": parse.rawValue, "link_names": linkNames, "attachments":encodeAttachments(attachments: attachments)]
        networkInterface.request(endpoint: .chatUpdate, token: token, parameters: filterNilParameters(parameters), successClosure: {
            (response) -> Void in
                success?(true)
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    //MARK: - Do Not Disturb
    public func dndInfo(user: String? = nil, success: ((_ status: DoNotDisturbStatus?)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any?] = ["user": user]
        networkInterface.request(endpoint: .dndInfo, token: token, parameters: filterNilParameters(parameters), successClosure: {
            (response) -> Void in
                success?(DoNotDisturbStatus(status: response))
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    public func dndTeamInfo(users: [String]? = nil, success: ((_ statuses: [String: DoNotDisturbStatus]?)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any?] = ["users":users?.joined(separator: ",")]
        networkInterface.request(endpoint: .dndTeamInfo, token: token, parameters: filterNilParameters(parameters), successClosure: {
            (response) -> Void in
                success?(self.enumerateDNDStauses(statuses: response["users"] as? [String: Any]))
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    //MARK: - Emoji
    public func emojiList(success: ((_ emojiList: [String: Any]?)->Void)?, failure: FailureClosure?) {
        networkInterface.request(endpoint: .emojiList, token: token, parameters: nil, successClosure: {
            (response) -> Void in
                success?(response["emoji"] as? [String: Any])
            }) { (error) -> Void in
                failure?(error)
        }
    }
    
    //MARK: - Files
    public func deleteFile(fileID: String, success: ((_ deleted: Bool)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any] = ["file":fileID]
        networkInterface.request(endpoint: .filesDelete, token: token, parameters: parameters, successClosure: {
            (response) -> Void in
                success?(true)
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    public func uploadFile(file: Data, filename: String, filetype: String = "auto", title: String? = nil, initialComment: String? = nil, channels: [String]? = nil, success: ((_ file: File?)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any?] = ["file":file, "filename": filename, "filetype":filetype, "title":title, "initial_comment":initialComment, "channels":channels?.joined(separator: ",")]
        networkInterface.uploadRequest(token: token, data: file, parameters: filterNilParameters(parameters), successClosure: {
            (response) -> Void in
                success?(File(file: response["file"] as? [String: Any]))
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    //MARK: - File Comments
    public func addFileComment(fileID: String, comment: String, success: ((_ comment: Comment?)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any] = ["file":fileID, "comment":comment.slackFormatEscaping]
        networkInterface.request(endpoint: .filesCommentsAdd, token: token, parameters: parameters, successClosure: {
            (response) -> Void in
                success?(Comment(comment: response["comment"] as? [String: Any]))
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    public func editFileComment(fileID: String, commentID: String, comment: String, success: ((_ comment: Comment?)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any] = ["file":fileID, "id":commentID, "comment":comment.slackFormatEscaping]
        networkInterface.request(endpoint: .filesCommentsEdit, token: token, parameters: parameters, successClosure: {
            (response) -> Void in
            success?(Comment(comment: response["comment"] as? [String: Any]))
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    public func deleteFileComment(fileID: String, commentID: String, success: ((_ deleted: Bool?)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any] = ["file":fileID, "id": commentID]
        networkInterface.request(endpoint: .filesCommentsDelete, token: token, parameters: parameters, successClosure: {
            (response) -> Void in
                success?(true)
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    //MARK: - Groups
    public func closeGroup(groupID: String, success: ((_ closed: Bool)->Void)?, failure: FailureClosure?) {
        close(endpoint: .groupsClose, channelID: groupID, success: {
            (closed) -> Void in
                success?(closed)
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    public func groupHistory(id: String, latest: String = "\(Date().slackTimestamp)", oldest: String = "0", inclusive: Bool = false, count: Int = 100, unreads: Bool = false, success: ((_ history: History?)->Void)?, failure: FailureClosure?) {
        history(endpoint: .groupsHistory, id: id, latest: latest, oldest: oldest, inclusive: inclusive, count: count, unreads: unreads, success: {
            (history) -> Void in
                success?(history)
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    public func groupInfo(id: String, success: ((_ channel: Channel?)->Void)?, failure: FailureClosure?) {
        info(endpoint: .groupsInfo, type:ChannelType.group, id: id, success: {
            (channel) -> Void in
                success?(channel)
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    public func groupsList(excludeArchived: Bool = false, success: ((_ channels: [Any]?)->Void)?, failure: FailureClosure?) {
        list(endpoint: .groupsList, type:ChannelType.group, excludeArchived: excludeArchived, success: {
            (channels) -> Void in
                success?(channels)
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    public func markGroup(channel: String, timestamp: String, success: ((_ ts: String)->Void)?, failure: FailureClosure?) {
        mark(endpoint: .groupsMark, channel: channel, timestamp: timestamp, success: {
            (ts) -> Void in
                success?(timestamp)
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    public func openGroup(channel: String, success: ((_ opened: Bool)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any] = ["channel":channel]
        networkInterface.request(endpoint: .groupsOpen, token: token, parameters: parameters, successClosure: {
            (response) -> Void in
                success?(true)
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    public func setGroupPurpose(channel: String, purpose: String, success: ((_ purposeSet: Bool)->Void)?, failure: FailureClosure?) {
        setInfo(endpoint: .groupsSetPurpose, type: .purpose, channel: channel, text: purpose, success: {
            (purposeSet) -> Void in
                success?(purposeSet)
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    public func setGroupTopic(channel: String, topic: String, success: ((_ topicSet: Bool)->Void)?, failure: FailureClosure?) {
        setInfo(endpoint: .groupsSetTopic, type: .topic, channel: channel, text: topic, success: {
            (topicSet) -> Void in
                success?(topicSet)
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    //MARK: - IM
    public func closeIM(channel: String, success: ((_ closed: Bool)->Void)?, failure: FailureClosure?) {
        close(endpoint: .imClose, channelID: channel, success: {
            (closed) -> Void in
                success?(closed)
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    public func imHistory(id: String, latest: String = "\(Date().slackTimestamp)", oldest: String = "0", inclusive: Bool = false, count: Int = 100, unreads: Bool = false, success: ((_ history: History?)->Void)?, failure: FailureClosure?) {
        history(endpoint: .imHistory, id: id, latest: latest, oldest: oldest, inclusive: inclusive, count: count, unreads: unreads, success: {
            (history) -> Void in
                success?(history)
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    public func imsList(excludeArchived: Bool = false, success: ((_ channels: [Any]?)->Void)?, failure: FailureClosure?) {
        list(endpoint: .imList, type:ChannelType.im, excludeArchived: excludeArchived, success: {
            (channels) -> Void in
                success?(channels)
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    public func markIM(channel: String, timestamp: String, success: ((_ ts: String)->Void)?, failure: FailureClosure?) {
        mark(endpoint: .imMark, channel: channel, timestamp: timestamp, success: {
            (ts) -> Void in
                success?(timestamp)
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    public func openIM(userID: String, success: ((_ imID: String?)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any] = ["user":userID]
        networkInterface.request(endpoint: .imOpen, token: token, parameters: parameters, successClosure: {
            (response) -> Void in
                let group = response["channel"] as? [String: Any]
                success?(group?["id"] as? String)
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    //MARK: - MPIM
    public func closeMPIM(channel: String, success: ((_ closed: Bool)->Void)?, failure: FailureClosure?) {
        close(endpoint: .mpimClose, channelID: channel, success: {
            (closed) -> Void in
                success?(closed)
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    public func mpimHistory(id: String, latest: String = "\(Date().slackTimestamp)", oldest: String = "0", inclusive: Bool = false, count: Int = 100, unreads: Bool = false, success: ((_ history: History?)->Void)?, failure: FailureClosure?) {
        history(endpoint: .mpimHistory, id: id, latest: latest, oldest: oldest, inclusive: inclusive, count: count, unreads: unreads, success: {
            (history) -> Void in
                success?(history)
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    public func mpimsList(excludeArchived: Bool = false, success: ((_ channels: [Any]?)->Void)?, failure: FailureClosure?) {
        list(endpoint: .mpimList, type:ChannelType.group, excludeArchived: excludeArchived, success: {
            (channels) -> Void in
                success?(channels)
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    public func markMPIM(channel: String, timestamp: String, success: ((_ ts: String)->Void)?, failure: FailureClosure?) {
        mark(endpoint: .mpimMark, channel: channel, timestamp: timestamp, success: {
            (ts) -> Void in
                success?(timestamp)
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    public func openMPIM(userIDs: [String], success: ((_ mpimID: String?)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any] = ["users":userIDs.joined(separator: ",")]
        networkInterface.request(endpoint: .mpimOpen, token: token, parameters: parameters, successClosure: {
            (response) -> Void in
                let group = response["group"] as? [String: Any]
                success?(group?["id"] as? String)
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    //MARK: - Pins
    public func pinItem(channel: String, file: String? = nil, fileComment: String? = nil, timestamp: String? = nil, success: ((_ pinned: Bool)->Void)?, failure: FailureClosure?) {
        pin(endpoint: .pinsAdd, channel: channel, file: file, fileComment: fileComment, timestamp: timestamp, success: {
            (ok) -> Void in
                success?(ok)
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    public func unpinItem(channel: String, file: String? = nil, fileComment: String? = nil, timestamp: String? = nil, success: ((_ unpinned: Bool)->Void)?, failure: FailureClosure?) {
        pin(endpoint: .pinsRemove, channel: channel, file: file, fileComment: fileComment, timestamp: timestamp, success: {
            (ok) -> Void in
                success?(ok)
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    private func pin(endpoint: SlackAPIEndpoint, channel: String, file: String? = nil, fileComment: String? = nil, timestamp: String? = nil, success: ((_ ok: Bool)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any?] = ["channel":channel, "file":file, "file_comment":fileComment, "timestamp":timestamp]
        networkInterface.request(endpoint: endpoint, token: token, parameters: filterNilParameters(parameters), successClosure: {
            (response) -> Void in
                success?(true)
            }){(error) -> Void in
                failure?(error)
        }
    }
    
    //MARK: - Reactions
    // One of file, file_comment, or the combination of channel and timestamp must be specified.
    public func addReaction(name: String, file: String? = nil, fileComment: String? = nil, channel: String? = nil, timestamp: String? = nil, success: ((_ reacted: Bool)->Void)?, failure: FailureClosure?) {
        react(endpoint: .reactionsAdd, name: name, file: file, fileComment: fileComment, channel: channel, timestamp: timestamp, success: {
            (ok) -> Void in
                success?(ok)
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    // One of file, file_comment, or the combination of channel and timestamp must be specified.
    public func removeReaction(name: String, file: String? = nil, fileComment: String? = nil, channel: String? = nil, timestamp: String? = nil, success: ((_ unreacted: Bool)->Void)?, failure: FailureClosure?) {
        react(endpoint: .reactionsRemove, name: name, file: file, fileComment: fileComment, channel: channel, timestamp: timestamp, success: {
            (ok) -> Void in
                success?(ok)
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    private func react(endpoint: SlackAPIEndpoint, name: String, file: String? = nil, fileComment: String? = nil, channel: String? = nil, timestamp: String? = nil, success: ((_ ok: Bool)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any?] = ["name":name, "file":file, "file_comment":fileComment, "channel":channel, "timestamp":timestamp]
        networkInterface.request(endpoint: endpoint, token: token, parameters: filterNilParameters(parameters), successClosure: {
            (response) -> Void in
                success?(true)
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    //MARK: - Stars
    // One of file, file_comment, channel, or the combination of channel and timestamp must be specified.
    public func addStar(file: String? = nil, fileComment: String? = nil, channel: String?  = nil, timestamp: String? = nil, success: ((_ starred: Bool)->Void)?, failure: FailureClosure?) {
        star(endpoint: .starsAdd, file: file, fileComment: fileComment, channel: channel, timestamp: timestamp, success: {
            (ok) -> Void in
                success?(ok)
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    // One of file, file_comment, channel, or the combination of channel and timestamp must be specified.
    public func removeStar(file: String? = nil, fileComment: String? = nil, channel: String? = nil, timestamp: String? = nil, success: ((_ unstarred: Bool)->Void)?, failure: FailureClosure?) {
        star(endpoint: .starsRemove, file: file, fileComment: fileComment, channel: channel, timestamp: timestamp, success: {
            (ok) -> Void in
                success?(ok)
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    private func star(endpoint: SlackAPIEndpoint, file: String?, fileComment: String?, channel: String?, timestamp: String?, success: ((_ ok: Bool)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any?] = ["file":file, "file_comment":fileComment, "channel":channel, "timestamp":timestamp]
        networkInterface.request(endpoint: endpoint, token: token, parameters: filterNilParameters(parameters), successClosure: {
            (response) -> Void in
                success?(true)
            }) {(error) -> Void in
                failure?(error)
        }
    }

    
    //MARK: - Team
    public func teamInfo(success: ((_ info: [String: Any]?)->Void)?, failure: FailureClosure?) {
        networkInterface.request(endpoint: .teamInfo, token: token, parameters: nil, successClosure: {
            (response) -> Void in
                success?(response["team"] as? [String: Any])
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    //MARK: - Users
    public func userPresence(user: String, success: ((_ presence: String?)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any] = ["user":user]
        networkInterface.request(endpoint: .usersGetPresence, token: token, parameters: parameters, successClosure: {
            (response) -> Void in
                success?(response["presence"] as? String)
            }){(error) -> Void in
                failure?(error)
        }
    }
    
    public func userInfo(id: String, success: ((_ user: User?)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any] = ["user":id]
        networkInterface.request(endpoint: .usersInfo, token: token, parameters: parameters, successClosure: {
            (response) -> Void in
                success?(User(user: response["user"] as? [String: Any]))
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    public func usersList(includePresence: Bool = false, success: ((_ userList: [String: Any]?)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any] = ["presence":includePresence]
        networkInterface.request(endpoint: .usersList, token: token, parameters: parameters, successClosure: {
            (response) -> Void in
                success?(response["members"] as? [String: Any])
            }){(error) -> Void in
                failure?(error)
        }
    }
    
    public func setUserActive(success: ((_ success: Bool)->Void)?, failure: FailureClosure?) {
        networkInterface.request(endpoint: .usersSetActive, token: token, parameters: nil, successClosure: {
            (response) -> Void in
                success?(true)
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    public func setUserPresence(presence: Presence, success: ((_ success: Bool)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any] = ["presence":presence.rawValue]
        networkInterface.request(endpoint: .usersSetPresence, token: token, parameters: parameters, successClosure: {
            (response) -> Void in
                success?(true)
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    //MARK: - Channel Utilities
    private func close(endpoint: SlackAPIEndpoint, channelID: String, success: ((_ closed: Bool)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any] = ["channel":channelID]
        networkInterface.request(endpoint: endpoint, token: token, parameters: parameters, successClosure: {
            (response) -> Void in
                success?(true)
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    private func history(endpoint: SlackAPIEndpoint, id: String, latest: String = "\(Date().slackTimestamp)", oldest: String = "0", inclusive: Bool = false, count: Int = 100, unreads: Bool = false, success: ((_ history: History?)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any] = ["channel": id, "latest": latest, "oldest": oldest, "inclusive":inclusive, "count":count, "unreads":unreads]
        networkInterface.request(endpoint: endpoint, token: token, parameters: parameters, successClosure: {
            (response) -> Void in
                success?(History(history: response))
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    private func info(endpoint: SlackAPIEndpoint, type: ChannelType, id: String, success: ((_ channel: Channel?)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any] = ["channel": id]
        networkInterface.request(endpoint: endpoint, token: token, parameters: parameters, successClosure: {
            (response) -> Void in
                success?(Channel(channel: response[type.rawValue] as? [String: Any]))
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    private func list(endpoint: SlackAPIEndpoint, type: ChannelType, excludeArchived: Bool = false, success: ((_ channels: [Any]?)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any] = ["exclude_archived": excludeArchived]
        networkInterface.request(endpoint: endpoint, token: token, parameters: parameters, successClosure: {
            (response) -> Void in
                success?(response[type.rawValue+"s"] as? [Any])
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    private func mark(endpoint: SlackAPIEndpoint, channel: String, timestamp: String, success: ((_ ts: String)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any] = ["channel": channel, "ts": timestamp]
        networkInterface.request(endpoint: endpoint, token: token, parameters: parameters, successClosure: {
            (response) -> Void in
                success?(timestamp)
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    private func setInfo(endpoint: SlackAPIEndpoint, type: InfoType, channel: String, text: String, success: ((_ success: Bool)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any] = ["channel": channel, type.rawValue: text]
        networkInterface.request(endpoint: endpoint, token: token, parameters: parameters, successClosure: {
            (response) -> Void in
                success?(true)
            }) {(error) -> Void in
                failure?(error)
        }
    }

    //MARK: - Filter Nil Parameters
    private func filterNilParameters(_ parameters: [String: Any?]) -> [String: Any] {
        var finalParameters = [String: Any]()
        for key in parameters.keys {
            if parameters[key] != nil {
                finalParameters[key] = parameters[key]!
            }
        }
        return finalParameters
    }
    
    //MARK: - Encode Attachments
    private func encodeAttachments(attachments: [Attachment?]?) -> String? {
        if let attachments = attachments {
            var attachmentArray: [Any] = []
            for attachment in attachments {
                if let attachment = attachment {
                    attachmentArray.append(attachment.dictionary)
                }
            }
            do {
                let string = try JSONSerialization.data(withJSONObject: attachmentArray, options: []).base64EncodedString()
                return string
            } catch _ {
                print("Error encoding attachments")
            }
        }
        return nil
    }
    
    //MARK: - Enumerate Do Not Distrub Status
    private func enumerateDNDStauses(statuses: [String: Any]?) -> [String: DoNotDisturbStatus] {
        var retVal = [String: DoNotDisturbStatus]()
        if let keys = statuses?.keys {
            for key in keys {
                retVal[key] = DoNotDisturbStatus(status: statuses?[key] as? [String: Any])
            }
        }
        return retVal
    }
}
