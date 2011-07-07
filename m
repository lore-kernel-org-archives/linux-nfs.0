Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39141 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756661Ab1GGOk2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jul 2011 10:40:28 -0400
Received: by wyg8 with SMTP id 8so693502wyg.19
        for <linux-nfs@vger.kernel.org>; Thu, 07 Jul 2011 07:40:26 -0700 (PDT)
Message-ID: <4E15C555.9030002@fubra.com>
Date: Thu, 07 Jul 2011 15:40:21 +0100
From: Matthew Ward <matthew.ward@fubra.com>
To: linux-nfs@vger.kernel.org
Subject: Issue with NFS and LDAP, attribute caching with "Permission denied"
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi all,

I'm having a particular issue with NFS and LDAP permissions causing 
"Permission denied" when trying to access directories where my apache 
user is a member of another's group, and there seems to be some kind of 
caching of permissions that are stopping me from getting into 
directories until the NFS server is restarted. I've tried reducing 
attribute caching timeouts as well as turning attribute caching off with 
noac, which help to alleviate the problem on the client side but still 
require a restart of NFS on the server side otherwise there is a long 
(up to 15 minute) wait. The setup is as follows:

1) A random user and group are added to LDAP on the LDAP server, for 
example `matt`
2) `apache` is added as a memberUid to the group `matt` so that `apache` 
has access to everything that the `group` matt can read
3) Checking the groups for the `apache` user on the client shows it's a 
member of the `matt` group
4) Trying to access directories that are group-read/executable to `matt` 
(drwxr-x---) from `apache` produces "Permission denied"
5) Restarting the NFS server then allows the `apache` user to access the 
`matt`-owned directory

Originally, we didn't have the noac option on the client-side mount and 
even after restarting the NFS server it would still be anywhere between 
30 seconds and 15 minutes before the `apache` user had access to the 
directory, but since turning on noac (or reducing actimeo to something 
small) means that after an NFS server restart we're able to use `apache` 
to access the directory straight away.

I'm just wondering if there's some sort of cache on the server side that 
also needs to be reduced so that we don't have to restart the NFS server 
to avoid the 15 minute wait as well?

NFS-specific files and commands are as follows

/etc/exports (on the server):
-----------------------------
/my/shared/dir x.x.x.x(rw,nohide,insecure,no_subtree_check,async)

/etc/fstab (on the client):
---------------------------
x.x.x.x:/my/shared/dir /my/shared/dir nfs defaults,noatime,actimeo=1 1 1

commands on the client (as the `apache` LDAP user):
---------------------------------------------------
$ whoami
apache
$ groups
apache matt
$ cd /my/shared/dir
$ ls -l
drwxr-s--- 7 matt matt 4096 Jul 6 16:56 matt
$ ls -a matt
ls: cannot open directory matt: Permission denied
(RESTART NFS SERVER)
$ ls -a matt
. ..
$

============
Matthew Ward
Web and Mobile Application Developer
Fubra Limited

w: www.fubra.com
e: matthew.ward@fubra.com

------------------------------

Fubra is a company limited by shares and registered in England and
Wales with number 3967214 at Anstey Park House, Anstey Road,
Alton, Hampshire, GU34 2RL. We are registered for VAT with number
GB733667024, and as a data controller with number Z5193400.
We are members of RIPE, Nominet, The Italian RA and registered
with OfCom as a provider of electronic communications services.

