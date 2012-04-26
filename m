Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f53.google.com ([209.85.216.53]:60761 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756858Ab2DZOy1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Apr 2012 10:54:27 -0400
MIME-Version: 1.0
In-Reply-To: <20656.1335450358@redhat.com>
References: <20120419140558.17272.74360.stgit@warthog.procyon.org.uk>
	<CAH2r5ms4WQV3DnTvqNN=2N71Cj8UHwj8Z6+RHXgrAOv6mSoyQg@mail.gmail.com>
	<20656.1335450358@redhat.com>
Date: Thu, 26 Apr 2012 09:54:26 -0500
Message-ID: <CAH2r5mv1Lijdwk5zsQwYJr4Etb6fhrRyNXm-iFCQX+HecboGrQ@mail.gmail.com>
Subject: Re: [PATCH 0/6] Extended file stat system call
From: Steve French <smfrench@gmail.com>
To: David Howells <dhowells@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-ext4@vger.kernel.org, wine-devel@winehq.org, kfm-devel@kde.org,
        nautilus-list@gnome.org, linux-api@vger.kernel.org,
        libc-alpha@sourceware.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 26, 2012 at 9:25 AM, David Howells <dhowells@redhat.com> wrote:
> Steve French <smfrench@gmail.com> wrote:
>
>> Would it be better to make the stable vs volatile inode number an attribute
>> of the volume  or something returned by the proposed xstat?
>
> I'm not sure what you mean by a stable vs a volatile inode number.

Both NFS and CIFS (and SMB2) can return inode numbers or equivalent
unique identifier, but in the case of CIFS some old servers don't support the
calls which return inode numbers (or don't return them for all file system
types, Windows FAT?) so in these cases cifs has to create inode
numbers on the fly
on the client.   inode numbers created on the client are not "stable" they
can change on unmount/remount (which can cause problems for backup
applications).

Similarly NFSv4 does not require that servers always return stable inode numbers
(that will never change) and introduced a concept of "volatile file handle."
We have run into this in two cases (there are probably more) -
Specialized NFS servers
for HPC which deal with lots of transient inodes, and second those for servers
which base there inode number on path (Windows NFS?).  See
http://docs.oracle.com/cd/E19082-01/819-1634/rfsrefer-137/index.html
or the NFSv4 RFC.

Basically the question is whether it is worth reporting a flag on the
call which returns
the inode number to indicate that the inode number is "stable" (would not change
on reboot or reconnection) or "volatile."    Since the majority of NFS
and SMB2 servers
can return stable inode numbers, I don't feel strongly about the need
for an indicator
of "stable" vs. "volatile" but I mention it because backup and
migration applications
mention this (if inode numbers are volatile, they may have to check
for hardlinks differently
for example)


>> > Should things like the Windows Archive, Hidden and System bits be handled
>> > through IOC flags, perhaps expanded to 64-bits?
>>
>> Today I export these through an psuedo-xattr in cifs.ko, I am curious how
>> NTFS and FAT export these on linux.
>
> NTFS: Not at all.
>
> FAT: The hidden bit causes the filename to get a dot prepended (and nothing
> else is noted).
>
>> > Autofs, ntfs, btrfs, ...
>>
>> Given the overlap in optional attributes between the network
>> protocol and local NTFS (and ReFS and to a lesser extent FAT)
>> I would expect cifs.ko and the ntfs implementations
>> info to map pretty closely.
>
> Yep.  I wasn't going to do more filesystems till we'd finished arguing about
> the basic arrangement of things in struct xstat.

makes sense


>> > Handle remote filesystems being offline and indicate this with
>> > XSTAT_INFO_OFFLINE.
>>
>> You already have support for an indicator for offline files (HSM),
>
> HSM

HSM is the more general case of two tiered data (disk vs. tape)

en.wikipedia.org/wiki/Hierarchical_storage_management

in the simplest case on "disk" (fast) vs. moved to tape (slow to retrieve)


>> would XSTAT_INFO_OFFLINE be intended for the case
>> where the network session to the server is disconnected
>> (and in which you case the application does not want to reconnect)?
>
> Hmmm...  Interesting question.  Both NTFS and CIFS have an offline attribute
> (which is where I originally got this from) - but should I have a separate
> indicator to indicate the client can't access a server over a network
> (ie. we've gone to disconnected operation on this file)?  E.g. should there be
> a XSTAT_INFO_DISCONNECTED too?

my reaction is no, since it adds complexity.  If you do a stat on a disconnected
volume (where the network is temporarily down) reconnection will be attempted.
If reconnection fails then the xstat will either fail or be retried forever
depending on the value of "hard" vs. "soft" mount flag.

-- 
Thanks,

Steve
