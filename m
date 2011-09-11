Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:45454 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755161Ab1IKQEr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Sep 2011 12:04:47 -0400
Received: by pzk37 with SMTP id 37so5478616pzk.1
        for <linux-nfs@vger.kernel.org>; Sun, 11 Sep 2011 09:04:46 -0700 (PDT)
Message-ID: <4E6CDC1C.7030507@tonian.com>
Date: Sun, 11 Sep 2011 09:04:44 -0700
From: Benny Halevy <bhalevy@tonian.com>
To: Jim Rees <rees@umich.edu>
CC: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH 0/3] pnfs private workqueue, and two cleanups
References: <1315676495-3689-1-git-send-email-rees@umich.edu> <4E6CDB3D.2050702@tonian.com>
In-Reply-To: <4E6CDB3D.2050702@tonian.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-09-11 09:01, Benny Halevy wrote:
> I merged the patches as well as my two SQUASHMEs
> under pnfs-all-3.1-rc4-2011-09-11

hit "Send" too soon...
In fact I merged all the patches in linux-pnfs-blk/for-benny
Including my SQUASHMEs, I merged the following patches:

fd06920 SUNRPC/NFS: make rpc pipe upcall generic
0359f0e pNFS: introduce pnfs private workqueue
fee4dab SQUASHME: pnfs: simplify and clean up pnfsiod workqueue
ab93fb1 SQUASHME: pnfs: do pnfsiod_start before registering layout drivers
9d904b1 pNFS: make _set_lo_fail generic
be077c0 pnfsblock: init pg_bsize properly
3c03366 pNFS: recoalesce when ld write pagelist fails
a4e8a6e pNFS: recoalesce when ld read pagelist fails

In addition, I fixed up some compile warnings in pnfsd/spnfs/spnfs-block

Benny

> 
> Thanks!
> 
> Benny
> 
> On 2011-09-10 10:41, Jim Rees wrote:
>> These have been sent to the list previously, and I believe are
>> uncontroversial, but have not shown up on your pnfs-all-latest branch.
>>
>> Peng Tao (3):
>>   SUNRPC/NFS: make rpc pipe upcall generic
>>   pNFS: introduce pnfs private workqueue
>>   pNFS: make _set_lo_fail generic
>>
>>  fs/nfs/blocklayout/blocklayout.c    |   36 +++++++++-----------
>>  fs/nfs/blocklayout/blocklayout.h    |    2 -
>>  fs/nfs/blocklayout/blocklayoutdev.c |   22 ------------
>>  fs/nfs/idmap.c                      |   25 +-------------
>>  fs/nfs/nfs4filelayout.c             |   19 ++---------
>>  fs/nfs/objlayout/objio_osd.c        |    8 ++++
>>  fs/nfs/objlayout/objlayout.c        |    4 +-
>>  fs/nfs/pnfs.c                       |   64 ++++++++++++++++++++++++++++++++++-
>>  fs/nfs/pnfs.h                       |    5 +++
>>  include/linux/sunrpc/rpc_pipe_fs.h  |    2 +
>>  net/sunrpc/auth_gss/auth_gss.c      |   24 +------------
>>  net/sunrpc/rpc_pipe.c               |   20 +++++++++++
>>  12 files changed, 122 insertions(+), 109 deletions(-)
>>
