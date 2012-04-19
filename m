Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f174.google.com ([209.85.216.174]:47455 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754532Ab2DSRLM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Apr 2012 13:11:12 -0400
MIME-Version: 1.0
In-Reply-To: <20120419140558.17272.74360.stgit@warthog.procyon.org.uk>
References: <20120419140558.17272.74360.stgit@warthog.procyon.org.uk>
Date: Thu, 19 Apr 2012 12:11:11 -0500
Message-ID: <CAH2r5ms4WQV3DnTvqNN=2N71Cj8UHwj8Z6+RHXgrAOv6mSoyQg@mail.gmail.com>
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

On Thu, Apr 19, 2012 at 9:05 AM, David Howells <dhowells@redhat.com> wrote:
>
> Implement a pair of new system calls to provide extended and further extensible
 stat functions.
<snip>
> Should the default for a network fs be to do an unconditional (heavyweight)
> stat with a flag to suppress going to the server to update the locally held
> attributes and flushing pending writebacks?

Even though we can use leases (oplocks) to avoid the roundrtrip, it is
probably too expensive to default to forcing a cache flush, especially
when a common case is to get the file creation time or inode number
information (stable vs volatile).

Would it be better to make the stable vs volatile inode number an attribute
of the volume  or something returned by the proposed xstat?

> Should things like the Windows Archive, Hidden and System bits be handled
> through IOC flags, perhaps expanded to 64-bits?

Today I export these through an psuedo-xattr in cifs.ko, I am curious how
NTFS and FAT export these on linux.

> ==========
> TO BE DONE
> ==========
>
> Autofs, ntfs, btrfs, ...

Given the overlap in optional attributes between the network
protocol and local NTFS (and ReFS and to a lesser extent FAT)
I would expect cifs.ko and the ntfs implementations
info to map pretty closely.

> I should perhaps use u8/u32/u64 rather than uint8/32/64_t.
>
> Handle remote filesystems being offline and indicate this with
> XSTAT_INFO_OFFLINE.

You already have support for an indicator for offline files (HSM),
would XSTAT_INFO_OFFLINE be intended for the case
where the network session to the server is disconnected
(and in which you case the application does not want to reconnect)?

-- 
Thanks,

Steve
