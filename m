Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f175.google.com ([209.85.192.175]:61943 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751333AbaDYTa7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Apr 2014 15:30:59 -0400
Received: by mail-pd0-f175.google.com with SMTP id fp1so1301220pdb.6
        for <linux-nfs@vger.kernel.org>; Fri, 25 Apr 2014 12:30:58 -0700 (PDT)
Received: from hobbes.nimgs.com (wsip-184-188-181-148.sd.sd.cox.net. [184.188.181.148])
        by mx.google.com with ESMTPSA id gy10sm17713969pbd.8.2014.04.25.12.30.56
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 25 Apr 2014 12:30:57 -0700 (PDT)
From: Craig Yoshioka <craigyk@gmail.com>
Content-Type: text/plain; charset=windows-1252
Subject: idmap problems
Message-Id: <1DC2D0D6-C964-47E9-8D6A-008A26201BC8@gmail.com>
Date: Fri, 25 Apr 2014 12:30:52 -0700
To: linux-nfs@vger.kernel.org
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
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