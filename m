Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f176.google.com ([209.85.223.176]:58207 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751549AbaEMPVP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 May 2014 11:21:15 -0400
Received: by mail-ie0-f176.google.com with SMTP id ar20so476825iec.21
        for <linux-nfs@vger.kernel.org>; Tue, 13 May 2014 08:21:15 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH v3 00/17] NFS: Create a common path used by reads and writes
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <46D51D46-54B4-4CE2-89F5-CF171E75509C@primarydata.com>
Date: Tue, 13 May 2014 11:21:20 -0400
Cc: Trond Myklebust <Trond.Myklebust@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>, hch@infradead.org
Message-Id: <A8E6B113-F44A-4605-B861-AD10A8F6B504@primarydata.com>
References: <1399381960-3019-1-git-send-email-Anna.Schumaker@Netapp.com> <46D51D46-54B4-4CE2-89F5-CF171E75509C@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May 6, 2014, at 9:28 AM, Weston Andros Adamson <dros@primarydata.com> wrote:

> On May 6, 2014, at 9:12 AM, Anna Schumaker <Anna.Schumaker@netapp.com> wrote:
> 
>> I noticed that much of the read and write code was almost identical, with
>> only minor differences in argument types and names.  These patches seek to
>> unify these two codepaths wherever possible in order to make future changes
>> easier.
>> 
>> Table of contents:
>> 	Patches 01 - 05: Set up common data structures.
>> 	Patches 06 - 10: Set up a shared rpc_call_ops struct.
>> 	Patches 11 - 15: Set up a shared nfs_pageio_ops struct.
>> 
>> Some of the commit setup was moved into common code, but I'm willing to
>> move this back into write.c if this looks to be a problem.
>> 
>> Future work:
>> 	I have rough pNFS patches to combine the read and write paths in
>> 	pnfs.c.  They apply on top of Dros' multiple requests work and
>> 	should get more testing before I submit.
>> 
>> Testing:
>> 	I tested every version of NFS using the cthon and xfs tests without
>> 	hitting anything new.  Any extra testing would be great seeing how
>> 	the read and write paths are vitally important.
>> 
>> Changes in v3:
>> 	Instead of creating a new "pageio.c" file, I now put the combined
>> 	code into pagelist.c (good luck, Dros!)
> 
> I’ll merge into my pgio branch later this week and repost my patchset.
> 
> Thanks!
> -dros

I’ve successfully merged my patches on top of your rebased patches, running tests since yesterday.

I’ll post soon.

-dros

> 
>> 
>> 	I also renamed a few functions, and did a better job checking what
>> 	pagelist.c functions can now be static.
>> 
>> Questions?  Comments?  Thoughts?
>> 
>> Anna
>> 
>> 
>> Anna Schumaker (17):
>> NFS: Create a common argument structure for reads and writes
>> NFS: Create a common results structure for reads and writes
>> NFS: Create a common read and write data struct
>> NFS: Create a common read and write header struct
>> NFS: Move the write verifier into the nfs_pgio_header
>> NFS: Create a common pgio_alloc and pgio_release function
>> NFS: Create a common rw_header_alloc and rw_header_free function
>> NFS: Create a common pgio_rpc_prepare function
>> NFS: Create a common nfs_pgio_result_common function
>> NFS: Create a common rpc_call_ops struct
>> NFS: Create a common rpcsetup function for reads and writes
>> NFS: Create a common pgio_error function
>> NFS: Create a generic_pgio function
>> NFS: Create a common initiate_pgio() function
>> NFS: Create a common multiple_pgios() function
>> NFS: Create a common generic_pg_pgios()
>> NFS: Create a common nfs_pageio_ops struct
>> 
>> fs/nfs/blocklayout/blocklayout.c |  22 +-
>> fs/nfs/direct.c                  |   4 +-
>> fs/nfs/internal.h                |  29 +--
>> fs/nfs/nfs2xdr.c                 |  14 +-
>> fs/nfs/nfs3proc.c                |  19 +-
>> fs/nfs/nfs3xdr.c                 |  16 +-
>> fs/nfs/nfs4_fs.h                 |   4 +-
>> fs/nfs/nfs4filelayout.c          |  40 ++--
>> fs/nfs/nfs4proc.c                |  52 ++---
>> fs/nfs/nfs4trace.h               |   8 +-
>> fs/nfs/nfs4xdr.c                 |  19 +-
>> fs/nfs/objlayout/objio_osd.c     |   6 +-
>> fs/nfs/objlayout/objlayout.c     |  16 +-
>> fs/nfs/objlayout/objlayout.h     |   8 +-
>> fs/nfs/pagelist.c                | 406 ++++++++++++++++++++++++++++++++++++-
>> fs/nfs/pnfs.c                    |  46 ++---
>> fs/nfs/pnfs.h                    |  10 +-
>> fs/nfs/proc.c                    |  19 +-
>> fs/nfs/read.c                    | 348 +++-----------------------------
>> fs/nfs/write.c                   | 425 +++++----------------------------------
>> include/linux/nfs_fs.h           |   2 -
>> include/linux/nfs_page.h         |  13 ++
>> include/linux/nfs_xdr.h          |  95 +++------
>> 23 files changed, 674 insertions(+), 947 deletions(-)
>> 
>> -- 
>> 1.9.2
>> 
> 

