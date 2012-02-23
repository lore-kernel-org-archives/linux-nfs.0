Return-Path: linux-nfs-owner@vger.kernel.org
Received: from partagas.dragonet.es ([217.70.240.130]:44877 "EHLO
	partagas.dragonet.es" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751785Ab2BWLxs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Feb 2012 06:53:48 -0500
Message-ID: <4F4628B8.90401@steve-ss.com>
Date: Thu, 23 Feb 2012 12:53:28 +0100
From: steve <steve@steve-ss.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@poochiereds.net>
CC: linux-nfs@vger.kernel.org
Subject: Re: POSIX acls over nfs4
References: <4F40053A.3090301@steve-ss.com> <4F412E2F.9070200@steve-ss.com> <4F45E78E.8050501@steve-ss.com> <20120223063913.5736a5b1@tlielax.poochiereds.net>
In-Reply-To: <20120223063913.5736a5b1@tlielax.poochiereds.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/23/2012 12:39 PM, Jeff Layton wrote:
> On Thu, 23 Feb 2012 08:15:26 +0100
> steve<steve@steve-ss.com>  wrote:
>
>> Hi everyone
>> I'm sorry to bump this but I've tried the opensuse, ubuntu and samba
>> lists without any luck.
>>
>> The acls I have created are not inherited when exporting via nfs4. Can
>> anyone help me with this? Tell me it can/can't be done? Versions of nfs
>> to use? Details below.
>> Thanks,
>> Steve
>>
>>
> The NFSv4 protocol does not support POSIX ACLs. It has its own
> implementation of ACLs that is much more windows-like (yet not exactly
> either).
>
> For enforcement, it doesn't really matter too much -- the server
> enforces POSIX ACLs since that's done within the VFS and local
> filesystem. The only "problem" is that you can't see and manipulate
> ACLs directly over NFSv4 using standard POSIX acl tools.
>
> You can view and manipulate NFSv4 ACLs using the programs in the
> nfs4-acl-tools package. Linux' nfsd will map those to/from POSIX ACLs
> but it's always going to be a lossy mapping.
>
> There are also patches in progress to add the ability for Linux
> filesystems to support NFSv4/Windows ACLs natively. That effort is
> called RichACLs, but it's not in mainline yet, and development on it
> seems to have stalled of late.
>
Hi Jeff
Thanks for the reply. I'm trying to make the files created in a share 
take on group rw.

The trouble is that I've already tried setting the acl's via 
nfs4_setfacl on the mounted share too (please see details below). The 
acl + appears on the unmounted share and behaves as expected even when 
it is not mounted. The mounted share however ignores the acl I've set. 
I've tried remounting but still no acl is effective.
My workaround is to scan the folder and change the files to group rw 
every few seconds.

What am I missing here?
Thanks again,
Steve

>> On 02/19/2012 06:15 PM, steve wrote:
>>> On 18/02/12 21:08, steve wrote:
>>>> Hi
>>>> Is it possible for nfs4 to respect the acls I have setup on an ext4
>>>> export?
>>>> Thanks,
>>>> Steve
>>>>
>>>> openSUSE 12.1
>>>> -- 
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>> Sorry, this is what I've tried so far:
>>>   cat /etc/exports
>>> /home
>>> *(rw,no_root_squash,sec=none:sys:krb5:krb5i:krb5p,no_subtree_check,insecure)
>>>
>>> 1. Make a folder to share:
>>> hh3:/home/CACTUS # mkdir -m 770 dropbox
>>> hh3:/home/CACTUS # chown root:suseusers dropbox
>>>
>>> 2. Mount the share:
>>> hh3:/home/CACTUS # mount -t nfs4 hh3:/home /mnt
>>>
>>> 3. Look at the acls:
>>> nfs4_getfacl /mnt/CACTUS/dropbox
>>> A::OWNER@:rwaDxtTcCy
>>> A::GROUP@:rwaDxtcy
>>> A::EVERYONE@:tcy
>>>
>>> Set an acl so that members of suseusers have rw on the share:
>>> hh3:/home/CACTUS # nfs4_setfacl -a A:g:suseusers@hh3.site:RW
>>> /mnt/CACTUS/dropbox
>>>
>>> hh3:/home/CACTUS # nfs4_getfacl /mnt/CACTUS/dropbox/
>>> A::OWNER@:rwaDxtTcCy
>>> A::GROUP@:rwaDxtcy
>>> A:g:suseusers@hh3.site:rwaDtcy
>>> A::EVERYONE@:tcy
>>>
>>> 4. Yes. Back in the unmounted directory, the acl + has appeared:
>>> hh3:/home/CACTUS # ls -la dropbox/
>>> total 8
>>> drwxrwx---+ 2 root suseusers 4096 Feb 19 10:55 .
>>> drwxr-xr-x  9 root root      4096 Feb 19 10:55 ..
>>>
>>> 5. On the mounted share, the acl is not visible. steve6 can create a
>>> file but it is _not_ group rw:
>>> steve6@hh3:~>  cd /mnt/CACTUS/dropbox/
>>> steve6@hh3:/mnt/CACTUS/dropbox>  touch hola.txt
>>> steve6@hh3:/mnt/CACTUS/dropbox>  ls -la
>>> total 8
>>> drwxrwx--- 2 root   suseusers 4096 Feb 19 11:02 .
>>> drwxr-xr-x 9 root   root      4096 Feb 19 10:55 ..
>>> -rw-r--r-- 1 steve6 suseusers    0 Feb 19 11:02 hola.txt
>>>
>>> 6. Recreate the share but this time with a posix acl:
>>> setfacl -d -m g::rw /home/CACTUS/dropbox
>>> steve6@hh3:/home/CACTUS>  touch dropbox/h
>>> steve6@hh3:/home/CACTUS>  ls -la dropbox/
>>> total 8
>>> drwxrws---+ 2 root   suseusers 4096 Feb 19 11:13 .
>>> drwxr-xr-x  9 root   root      4096 Feb 19 11:11 ..
>>> -rw-rw----  1 steve6 suseusers    0 Feb 19 11:13 h
>>>
>>> Yes. Now when steve6 creates a file it _is_ group rw. = posix acl is
>>> working.
>>>
>>> 7. Mount the new posix share and test again:
>>> hh3:/home/CACTUS #chmod g+s /home/CACTUS/dropbox
>>> hh3:/home/CACTUS # mount -t nfs4 hh3:/home /mnt
>>> hh3:/home/CACTUS # nfs4_getfacl /mnt/CACTUS/dropbox/
>>> A::OWNER@:rwaDxtTcCy
>>> A::GROUP@:rwaDxtcy
>>> A::EVERYONE@:tcy
>>> A:fdi:OWNER@:rwaDxtTcCy
>>> A:fdi:GROUP@:rwaDtcy
>>> A:fdi:EVERYONE@:tcy
>>>
>>> steve6@hh3:/mnt/CACTUS/dropbox>  touch h2
>>> steve6@hh3:/mnt/CACTUS/dropbox>  ls -la
>>> total 8
>>> drwxrws--- 2 root   suseusers 4096 Feb 19 11:19 .
>>> drwxr-xr-x 9 root   root      4096 Feb 19 11:11 ..
>>> -rw-rw---- 1 steve6 suseusers    0 Feb 19 11:13 h
>>> -rw-r----- 1 steve6 suseusers    0 Feb 19 11:19 h2
>>> hh3:/home/CACTUS # nfs4_getfacl /mnt/CACTUS/dropbox/
>>> A::OWNER@:rwaDxtTcCy
>>> A::GROUP@:rwaDxtcy
>>> A::EVERYONE@:tcy
>>> A:fdi:OWNER@:rwaDxtTcCy
>>> A:fdi:GROUP@:rwaDtcy
>>> A:fdi:EVERYONE@:tcy
>>> hh3:/home/CACTUS # nfs4_setfacl -a A:fdi:GROUP@:RWX
>>> /mnt/CACTUS/dropboxhh3:/home/CACTUS # nfs4_getfacl /mnt/CACTUS/dropbox/
>>> A::OWNER@:rwaDxtTcCy
>>> A::GROUP@:rwaDxtcy
>>> A::EVERYONE@:tcy
>>> A:fdi:OWNER@:rwaDxtTcCy
>>> A:fdi:GROUP@:rwaDxtcy
>>> A:fdi:EVERYONE@:tcy
>>>
>>> steve6@hh3:/mnt/CACTUS/dropbox>  touch h3
>>> steve6@hh3:/mnt/CACTUS/dropbox>  ls -la
>>> total 8
>>> drwxrws--- 2 root   suseusers 4096 Feb 19 11:21 .
>>> drwxr-xr-x 9 root   root      4096 Feb 19 11:11 ..
>>> -rw-rw---- 1 steve6 suseusers    0 Feb 19 11:13 h
>>> -rw-r----- 1 steve6 suseusers    0 Feb 19 11:19 h2
>>> -rw-r----- 1 steve6 suseusers    0 Feb 19 11:21 h3
>>>
>>> Still no group rw on created files. = nfs4 acl is not working as
>>> expected.
>>>
>>> Workaround. Get the out the big hammer:
>>> #!/bin/sh
>>> while true; do $(chmod -R g+w /home/CACTUS/dropbox); sleep 2; done
>>>
>>> Question:
>>> What am I missing? How do I set files created on an nfs4 share to take
>>> group rw?
>>>
>>> Thanks,
>>> Steve
>>>
>>> -- 
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

