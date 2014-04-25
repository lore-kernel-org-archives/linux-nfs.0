Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f45.google.com ([209.85.220.45]:62553 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752042AbaDYXBC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Apr 2014 19:01:02 -0400
Received: by mail-pa0-f45.google.com with SMTP id kq14so3027380pab.18
        for <linux-nfs@vger.kernel.org>; Fri, 25 Apr 2014 16:01:01 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: nfs4 idmap problems
From: Tom Haynes <thomas.haynes@primarydata.com>
In-Reply-To: <361F79C4-BA41-4F6A-94C1-A4FE1C4A2D90@me.com>
Date: Fri, 25 Apr 2014 16:01:02 -0700
Cc: linux-nfs@vger.kernel.org
Message-Id: <D6F60A65-99FC-47F2-948E-7D4969467DB0@primarydata.com>
References: <361F79C4-BA41-4F6A-94C1-A4FE1C4A2D90@me.com>
To: Craig Yoshioka <craigyk@me.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 25, 2014, at 1:35 PM, Craig Yoshioka <craigyk@me.com> wrote:

> I have a FreeBSD server with several NFSv4 shares.
> 
> I have several linux clients (Ubuntu 12.04) that connect just fine and are able to use the NFS shares with 0 problems.
> 
> But I’ve run into idmap problems with some newer linux distros ( Mint 16, Ubuntu 14.04 ) where chown as root sets file ownership as nobody (the idmap operation fails).  Just to be clear, chown as root is working fine from the Ubuntu 12.04 machines.  This poses a problem since some desktop GUIs like to do this sort of thing when creating config files in user home directories, and so user GUI logins fail.
> 
> the logs have a lot of this:
> 
> Apr 25 12:17:51 server rpc.idmapd[433]: nfs4_name_to_uid: calling nsswitch->name_to_uid
> Apr 25 12:17:51 server rpc.idmapd[433]: nss_getpwnam: name 'craigyk@nimgs.com' domain 'nimgs.com': resulting localname 'craigyk'
> Apr 25 12:17:51 server rpc.idmapd[433]: nfs4_name_to_uid: nsswitch->name_to_uid returned 0
> Apr 25 12:17:51 server rpc.idmapd[433]: nfs4_name_to_uid: final return value is 0
> Apr 25 12:17:51 server rpc.idmapd[433]: Client 0: (user) name "craigyk@nimgs.com" -> id "11115"
> ...
> Apr 25 12:18:03 server rpc.idmapd[433]: nfs4_name_to_uid: calling nsswitch->name_to_uid
> Apr 25 12:18:03 server rpc.idmapd[433]: nss_getpwnam: name '11115@nimgs.com' domain 'nimgs.com': resulting localname '11115'
> Apr 25 12:18:03 server rpc.idmapd[433]: nss_getpwnam: name '11115' not found in domain 'nimgs.com'
> Apr 25 12:18:03 server rpc.idmapd[433]: nfs4_name_to_uid: nsswitch->name_to_uid returned -2
> Apr 25 12:18:03 server rpc.idmapd[433]: nfs4_name_to_uid: final return value is -2
> Apr 25 12:18:03 server rpc.idmapd[433]: Client 0: (user) name "11115@nimgs.com" -> id "65534"
> 
> I’ve tried almost everything I can think of.
> The users are being served from Samba4.
> The uid and gid are the same on all clients.
> 
> Why is idmap trying to lookup the user id by it’s user id?—

HI Craig,

If the id-mapping is not working via user names, the client will try to see if user ids will
work. Since the client cannot send a numeric ID, it sends a string, in this case “11115”.

Check to make sure that id mapping is properly configured on both the server and client.

Thanks,
Tom