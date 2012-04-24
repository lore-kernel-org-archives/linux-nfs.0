Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f174.google.com ([209.85.216.174]:34460 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757164Ab2DXWI3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Apr 2012 18:08:29 -0400
MIME-Version: 1.0
In-Reply-To: <20120424212911.GA26073@fieldses.org>
References: <20120419140558.17272.74360.stgit@warthog.procyon.org.uk>
	<20120419140612.17272.57774.stgit@warthog.procyon.org.uk>
	<20120424212911.GA26073@fieldses.org>
Date: Tue, 24 Apr 2012 17:08:28 -0500
Message-ID: <CAH2r5muMb8m9-fMc_tcfn3ku_s55q9EEbc-vzvoFjPnsDdq1gA@mail.gmail.com>
Subject: Re: [PATCH 1/6] xstat: Add a pair of system calls to make extended
 file stats available
From: Steve French <smfrench@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: David Howells <dhowells@redhat.com>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-ext4@vger.kernel.org,
        wine-devel@winehq.org, kfm-devel@kde.org, nautilus-list@gnome.org,
        linux-api@vger.kernel.org, libc-alpha@sourceware.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 24, 2012 at 4:29 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Thu, Apr 19, 2012 at 03:06:12PM +0100, David Howells wrote:
>> Add a pair of system calls to make extended file stats available, including
>> file creation time, inode version and data version where available through the
>> underlying filesystem.
>>
>> The idea was initially proposed as a set of xattrs that could be retrieved with
>> getxattr(), but the general preferance proved to be for new syscalls with an
>> extended stat structure.
>>
>> This has a number of uses:
>>
>>  (1) Creation time: The SMB protocol carries the creation time, which could be
>>      exported by Samba, which will in turn help CIFS make use of FS-Cache as
>>      that can be used for coherency data.
>>
>>      This is also specified in NFSv4 as a recommended attribute and could be
>>      exported by NFSD [Steve French].
>>
>>  (2) Lightweight stat: Ask for just those details of interest, and allow a
>>      netfs (such as NFS) to approximate anything not of interest, possibly
>>      without going to the server [Trond Myklebust, Ulrich Drepper].
>>
>>  (3) Heavyweight stat: Force a netfs to go to the server, even if it thinks its
>>      cached attributes are up to date [Trond Myklebust].
>>
>>  (4) Inode generation number: Useful for FUSE and userspace NFS servers [Bernd
>>      Schubert].
>>
>>  (5) Data version number: Could be used by userspace NFS servers [Aneesh Kumar].
>>
>>      Can also be used to modify fill_post_wcc() in NFSD which retrieves
>>      i_version directly, but has just called vfs_getattr().  It could get it
>>      from the kstat struct if it used vfs_xgetattr() instead.
>>
>>  (6) BSD stat compatibility: Including more fields from the BSD stat such as
>>      creation time (st_btime) and inode generation number (st_gen) [Jeremy
>>      Allison, Bernd Schubert].
>>
>>  (7) Extra coherency data may be useful in making backups [Andreas Dilger].
>>
>>  (8) Allow the filesystem to indicate what it can/cannot provide: A filesystem
>>      can now say it doesn't support a standard stat feature if that isn't
>>      available, so if, for instance, inode numbers or UIDs don't exist...
>>
>>  (9) Make the fields a consistent size on all arches and make them large.
>>
>> (10) Store a 16-byte volume ID in the superblock that can be returned in struct
>>      xstat [Steve French].
>>
>> (11) Include granularity fields in the time data to indicate the granularity of
>>      each of the times (NFSv4 time_delta) [Steve French].
>
> It looks like you're including this with *each* time?  But surely
> there's no filesystem with different granularity (say) for ctime than
> for mtime.  Also, nfsd will want only one time_delta, not one for each
> time.
>
> Note also we need to document carefully what this means: I think it
> should be the granularity that the filesystem is capable of
> representing, but people are sometimes surprised to find out that the
> actual time source is usually more coarse-grained than that.

I also would prefer that we simply treat the time granularity as part
of the superblock (mounted volume) ie returned on fstat rather than on
every stat of the filesystem.   For cifs mounts we could conceivably
have different time granularity (1 or 2 second) on mounts to old
servers rather than 100 nanoseconds.


-- 
Thanks,

Steve
