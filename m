Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f170.google.com ([209.85.220.170]:62492 "EHLO
	mail-vc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851AbaEATod convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 May 2014 15:44:33 -0400
Received: by mail-vc0-f170.google.com with SMTP id hr9so4406394vcb.15
        for <linux-nfs@vger.kernel.org>; Thu, 01 May 2014 12:44:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5362994C.8010900@RedHat.com>
References: <2541339C-AF61-4ED7-8F50-E4B3CA2C924F@me.com>
	<5362994C.8010900@RedHat.com>
Date: Thu, 1 May 2014 15:44:32 -0400
Message-ID: <CAHQdGtTFtJYYkhnnxmpgtY7MapL49A1+2w6NBNy3o8NOKvbXWA@mail.gmail.com>
Subject: Re: idmap problems with chown as root
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Craig Yoshioka <craigyk@me.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 1, 2014 at 2:58 PM, Steve Dickson <SteveD@redhat.com> wrote:
>
>
> On 05/01/2014 12:21 PM, Craig Yoshioka wrote:
>>
>> This is a followup to a previous post I made.
>>
>> With Frank Filz’s helpful suggestions I was able to gather better data.
>>
>> problem: when using chown as root on a nfs4 filesystem on newer linux releases file owners get sets to nobody.
>>          the user type doesn’t seem to matter (/etc/passwd, LDAP, Samba4)
> This should take care of the problem:
>
> commit 3226c06989186d9cd60ba146df4e2898fee5047b
> Author: Steve Dickson <steved@redhat.com>
> Date:   Wed Apr 30 11:14:22 2014 -0400
>
>     libnfsidmap: id_as_chars() fails zero value ids.
>
>     Root has a zero value id which is valid and
>     should not be mapped to nfsnobody
>
>     Signed-off-by: Steve Dickson <steved@redhat.com>
>
> steved.
>>
>> setup: Server is FreeBSD 10 system with NFSv4 share.
>>        Server and clients are all configured with the same idmap domain
>>        Network users have consistent uid/gid on server and clients
>>        clients with older linux releases work OK (Ubuntu 12.04, CentOS 5 and 6)
>>        clients with newer linux releases do not work ( Fedora 20, Ubuntu 14.04, Mint 16 )
>>
>> clues:
>>
>> 1. working and non-working systems get to the same fchownat() system call with the same arguments (via strace).
>>
>> example (identical on working and non-working client):
>> ...
>> fchownat(AT_FDCWD, "/mnt/test", 11111, 4294967295, 0) = 0
>> close(1)                                = 0
>> close(2)                                = 0
>> close(4)                                = 0
>> exit_group(0)                           = ?
>> +++ exited with 0 +++
>>
>> 2. working system sends NFSV4 SETATTR request with owner set to: matlab@nimgs.com and non-working as 11111 (via wireshark)
>>
>>
>>
>>
>>
>> 3. I can’t rule out misconfiguration.  but I’ve configured as identically as I could, and tried a lot of small vairations. these are my current settings (the pipefs setting is the distro default)
>>

Does the following help on the client?

echo N >/sys/module/nfs/parameters/nfs4_disable_idmapping

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
