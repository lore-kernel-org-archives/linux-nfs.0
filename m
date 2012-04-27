Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail121c7.megamailservers.com ([69.49.98.221]:34840 "EHLO
	mail121c7.megamailservers.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758520Ab2D0DP5 convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Apr 2012 23:15:57 -0400
References: <CAH2r5mv1Lijdwk5zsQwYJr4Etb6fhrRyNXm-iFCQX+HecboGrQ@mail.gmail.com> <20120419140558.17272.74360.stgit@warthog.procyon.org.uk> <CAH2r5ms4WQV3DnTvqNN=2N71Cj8UHwj8Z6+RHXgrAOv6mSoyQg@mail.gmail.com> <20656.1335450358@redhat.com> <24787.1335455535@redhat.com>
In-Reply-To: <24787.1335455535@redhat.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain; charset=us-ascii
Message-Id: <3F302713-B675-4BAA-B2B7-235E03C5975F@dilger.ca>
Cc: Steve French <smfrench@gmail.com>,
        "dhowells@redhat.com" <dhowells@redhat.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-cifs@vger.kernel.org" <linux-cifs@vger.kernel.org>,
        "samba-technical@lists.samba.org" <samba-technical@lists.samba.org>,
        "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>,
        "wine-devel@winehq.org" <wine-devel@winehq.org>,
        "kfm-devel@kde.org" <kfm-devel@kde.org>,
        "nautilus-list@gnome.org" <nautilus-list@gnome.org>,
        "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>,
        "libc-alpha@sourceware.org" <libc-alpha@sourceware.org>
From: Andreas Dilger <adilger@dilger.ca>
Subject: Re: [PATCH 0/6] Extended file stat system call
Date: Thu, 26 Apr 2012 19:29:27 -0500
To: David Howells <dhowells@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2012-04-26, at 10:52, David Howells <dhowells@redhat.com> wrote:

> Steve French <smfrench@gmail.com> wrote:
>> 
>> Both NFS and CIFS (and SMB2) can return inode numbers or equivalent unique
>> identifier, but in the case of CIFS some old servers don't support the calls
>> which return inode numbers (or don't return them for all file system types,
>> Windows FAT?) so in these cases cifs has to create inode numbers on the fly
>> on the client.  inode numbers created on the client are not "stable" they can
>> change on unmount/remount (which can cause problems for backup applications).
> 
> In the volatile case you'd probably want to unset XSTAT_INO in st_mask as the
> inode number is a local fabrication.

I'd agree. Why fake up an inode number if the application doesn't care?  Most apps don't actually use the inode. The only uses I know for the inode number in userspace are backup, CIFS/NFS servers, and "ls -li" . 

> However, since there is a remote file ID,
> we could add an XSTAT_INFO_FILE_ID flag to indicate there's a standard xattr
> holding this.

It is a bit strange that the kernel would return a flag that was not requested, but not fatal. 

> On CIFS this could be the servername + pathname, on NFS this
> could be the server address + FH on AFS the cell+volID+FID+uniquifier for
> example.  That's independent of xstat, however, and wouldn't be returned as
> it's a blob that could be quite large.
> 
> I presume in some cases, there is not a unique file ID that persists across
> rename.
> 
>> Similarly NFSv4 does not require that servers always return stable inode
>> numbers (that will never change) and introduced a concept of "volatile file
>> handle."
> 
> Can I presume the inode number cannot be considered stable if the NFS4 FH is
> non-volatile?  Furthermore, can I presume NFS2/3 inode numbers are supposed to
> be stable?
> 
>> Basically the question is whether it is worth reporting a flag on the call
>> which returns the inode number to indicate that the inode number is "stable"
>> (would not change on reboot or reconnection) or "volatile."  Since the
>> majority of NFS and SMB2 servers can return stable inode numbers, I don't
>> feel strongly about the need for an indicator of "stable" vs. "volatile" but
>> I mention it because backup and migration applications mention this (if inode
>> numbers are volatile, they may have to check for hardlinks differently for
>> example)
> 
> It may be that unsetting XSTAT_INO if you've fabricated the inode number
> locally is sufficient.
> 
>>>>> Handle remote filesystems being offline and indicate this with
>>>>> XSTAT_INFO_OFFLINE.
>>>> 
>>>> You already have support for an indicator for offline files (HSM),
> 
> Which indicator is this?  Or do you mean XSTAT_INFO_OFFLINE?
> 
>>>> would XSTAT_INFO_OFFLINE be intended for the case
>>>> where the network session to the server is disconnected
>>>> (and in which you case the application does not want to reconnect)?
>>> 
>>> Hmmm...  Interesting question.  Both NTFS and CIFS have an offline
>>> attribute (which is where I originally got this from) - but should I have a
>>> separate indicator to indicate the client can't access a server over a
>>> network (ie. we've gone to disconnected operation on this file)?
>>> E.g. should there be a XSTAT_INFO_DISCONNECTED too?
>> 
>> my reaction is no, since it adds complexity.  If you do a stat on a
>> disconnected volume (where the network is temporarily down) reconnection will
>> be attempted.  If reconnection fails then the xstat will either fail or be
>> retried forever depending on the value of "hard" vs. "soft" mount flag.
> 
> I was thinking of how to handle disconnected operation, where you can't just
> sit there and churn waiting for the server to come back or give an error.  On
> the other hand, as long as there's some spare space in the struct, we can deal
> with that later when we actually start to implement D/O.
> 
> David
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
