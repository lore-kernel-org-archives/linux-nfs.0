Return-Path: linux-nfs-owner@vger.kernel.org
Received: from st11p02mm-asmtpout001.mac.com ([17.172.220.236]:39017 "EHLO
	st11p02mm-asmtp001.mac.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751613AbaDYUfP convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Apr 2014 16:35:15 -0400
MIME-version: 1.0
Content-type: text/plain; charset=windows-1252
Received: from hobbes.nimgs.com ([184.188.181.148])
 by st11p02mm-asmtp001.mac.com
 (Oracle Communications Messaging Server 7u4-27.08(7.0.4.27.7) 64bit (built Aug
 22 2013)) with ESMTPSA id <0N4L00G3PT6NL330@st11p02mm-asmtp001.mac.com> for
 linux-nfs@vger.kernel.org; Fri, 25 Apr 2014 20:35:13 +0000 (GMT)
From: Craig Yoshioka <craigyk@me.com>
Subject: nfs4 idmap problems
Message-id: <361F79C4-BA41-4F6A-94C1-A4FE1C4A2D90@me.com>
Date: Fri, 25 Apr 2014 13:35:06 -0700
To: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have a FreeBSD server with several NFSv4 shares.

I have several linux clients (Ubuntu 12.04) that connect just fine and are able to use the NFS shares with 0 problems.

But I’ve run into idmap problems with some newer linux distros ( Mint 16, Ubuntu 14.04 ) where chown as root sets file ownership as nobody (the idmap operation fails).  Just to be clear, chown as root is working fine from the Ubuntu 12.04 machines.  This poses a problem since some desktop GUIs like to do this sort of thing when creating config files in user home directories, and so user GUI logins fail.

the logs have a lot of this:

Apr 25 12:17:51 server rpc.idmapd[433]: nfs4_name_to_uid: calling nsswitch->name_to_uid
Apr 25 12:17:51 server rpc.idmapd[433]: nss_getpwnam: name 'craigyk@nimgs.com' domain 'nimgs.com': resulting localname 'craigyk'
Apr 25 12:17:51 server rpc.idmapd[433]: nfs4_name_to_uid: nsswitch->name_to_uid returned 0
Apr 25 12:17:51 server rpc.idmapd[433]: nfs4_name_to_uid: final return value is 0
Apr 25 12:17:51 server rpc.idmapd[433]: Client 0: (user) name "craigyk@nimgs.com" -> id "11115"
...
Apr 25 12:18:03 server rpc.idmapd[433]: nfs4_name_to_uid: calling nsswitch->name_to_uid
Apr 25 12:18:03 server rpc.idmapd[433]: nss_getpwnam: name '11115@nimgs.com' domain 'nimgs.com': resulting localname '11115'
Apr 25 12:18:03 server rpc.idmapd[433]: nss_getpwnam: name '11115' not found in domain 'nimgs.com'
Apr 25 12:18:03 server rpc.idmapd[433]: nfs4_name_to_uid: nsswitch->name_to_uid returned -2
Apr 25 12:18:03 server rpc.idmapd[433]: nfs4_name_to_uid: final return value is -2
Apr 25 12:18:03 server rpc.idmapd[433]: Client 0: (user) name "11115@nimgs.com" -> id "65534"

I’ve tried almost everything I can think of.
The users are being served from Samba4.
The uid and gid are the same on all clients.

Why is idmap trying to lookup the user id by it’s user id?