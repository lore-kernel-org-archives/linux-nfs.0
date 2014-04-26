Return-Path: linux-nfs-owner@vger.kernel.org
Received: from st11p02mm-asmtpout002.mac.com ([17.172.220.237]:53685 "EHLO
	st11p02mm-asmtp002.mac.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751048AbaDZACq convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Apr 2014 20:02:46 -0400
MIME-version: 1.0
Content-type: text/plain; charset=windows-1252
Received: from [192.168.1.17] ([75.80.98.195]) by st11p02mm-asmtp002.mac.com
 (Oracle Communications Messaging Server 7u4-27.08(7.0.4.27.7) 64bit (built Aug
 22 2013)) with ESMTPSA id <0N4M00I5R2R3PM40@st11p02mm-asmtp002.mac.com> for
 linux-nfs@vger.kernel.org; Sat, 26 Apr 2014 00:02:31 +0000 (GMT)
Subject: Re: nfs4 idmap problems
From: Craig Yoshioka <craigyk@me.com>
In-reply-to: <D6F60A65-99FC-47F2-948E-7D4969467DB0@primarydata.com>
Date: Fri, 25 Apr 2014 17:02:29 -0700
Cc: linux-nfs@vger.kernel.org
Message-id: <37FDB0FD-65FB-4FE9-8E75-8748371CFB5F@me.com>
References: <361F79C4-BA41-4F6A-94C1-A4FE1C4A2D90@me.com>
 <D6F60A65-99FC-47F2-948E-7D4969467DB0@primarydata.com>
To: Tom Haynes <thomas.haynes@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It is as properly configured as I could figure out.
I set verbosity to 5 and it lists the correct domain on start-up and doesn’t report any explicit errors.

On the non-functioning systems:

(Fedora 20)
  There is no explicit configuration for a Pipefs-Directory in idmapd.conf (but it looks like it is using /var/lib/nfs/rpc_pipefs).  I figured I should leave this as the system default.  
  The version of libnfsidmap is 0.25
                 nfs-utils   is 1.3.0

(Ubuntu 14.04 and Mint 16)
  has exact same idmapd.conf as working 12.04 machines
  Version of libnfsidmap is 0.25-5
             nfs-common  is 1.2.8-6ubuntu1

The working systems (also CentOS 5.8 but I haven’t checked the versions there):
(Ubuntu 12.04)
 libnfsidmap 0.25-1ubuntu2
 nfs-common  1.2.5-3ubuntu3.1

On Apr 25, 2014, at 4:01 PM, Tom Haynes <thomas.haynes@primarydata.com> wrote:

> 
> On Apr 25, 2014, at 1:35 PM, Craig Yoshioka <craigyk@me.com> wrote:
> 
>> I have a FreeBSD server with several NFSv4 shares.
>> 
>> I have several linux clients (Ubuntu 12.04) that connect just fine and are able to use the NFS shares with 0 problems.
>> 
>> But I’ve run into idmap problems with some newer linux distros ( Mint 16, Ubuntu 14.04 ) where chown as root sets file ownership as nobody (the idmap operation fails).  Just to be clear, chown as root is working fine from the Ubuntu 12.04 machines.  This poses a problem since some desktop GUIs like to do this sort of thing when creating config files in user home directories, and so user GUI logins fail.
>> 
>> the logs have a lot of this:
>> 
>> Apr 25 12:17:51 server rpc.idmapd[433]: nfs4_name_to_uid: calling nsswitch->name_to_uid
>> Apr 25 12:17:51 server rpc.idmapd[433]: nss_getpwnam: name 'craigyk@nimgs.com' domain 'nimgs.com': resulting localname 'craigyk'
>> Apr 25 12:17:51 server rpc.idmapd[433]: nfs4_name_to_uid: nsswitch->name_to_uid returned 0
>> Apr 25 12:17:51 server rpc.idmapd[433]: nfs4_name_to_uid: final return value is 0
>> Apr 25 12:17:51 server rpc.idmapd[433]: Client 0: (user) name "craigyk@nimgs.com" -> id "11115"
>> ...
>> Apr 25 12:18:03 server rpc.idmapd[433]: nfs4_name_to_uid: calling nsswitch->name_to_uid
>> Apr 25 12:18:03 server rpc.idmapd[433]: nss_getpwnam: name '11115@nimgs.com' domain 'nimgs.com': resulting localname '11115'
>> Apr 25 12:18:03 server rpc.idmapd[433]: nss_getpwnam: name '11115' not found in domain 'nimgs.com'
>> Apr 25 12:18:03 server rpc.idmapd[433]: nfs4_name_to_uid: nsswitch->name_to_uid returned -2
>> Apr 25 12:18:03 server rpc.idmapd[433]: nfs4_name_to_uid: final return value is -2
>> Apr 25 12:18:03 server rpc.idmapd[433]: Client 0: (user) name "11115@nimgs.com" -> id "65534"
>> 
>> I’ve tried almost everything I can think of.
>> The users are being served from Samba4.
>> The uid and gid are the same on all clients.
>> 
>> Why is idmap trying to lookup the user id by it’s user id?—
> 
> HI Craig,
> 
> If the id-mapping is not working via user names, the client will try to see if user ids will
> work. Since the client cannot send a numeric ID, it sends a string, in this case “11115”.
> 
> Check to make sure that id mapping is properly configured on both the server and client.
> 
> Thanks,
> Tom--
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

