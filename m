From: Doug Ledford <dledford@redhat.com>
Subject: Re: [PATCH V3 00/17] NFS/RDMA client-side patches
Date: Fri, 2 May 2014 15:27:09 -0400 (EDT)
Message-ID: <26074.1548300304$1399058847@news.gmane.org>
References: <20140430191433.5663.16217.stgit@manet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
	linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org,
	Roland Dreier <roland@purestorage.com>,
	Allen Andrews <allen.andrews@emulex.com>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-phx2.redhat.com ([209.132.183.24]:58749 "EHLO
	mx3-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750841AbaEBT1O (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 May 2014 15:27:14 -0400
In-Reply-To: <20140430191433.5663.16217.stgit-FYjufvaPoItvLzlybtyyYzGyq/o6K9yX@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

----- Original Message -----
> Changes since V2:
> 
>  - Rebased on v3.15-rc3
> 
>  - "enable pad optimization" dropped. Testing showed Linux NFS/RDMA
>    server does not support pad optimization yet.
> 
>  - "ALLPHYSICAL CONFIG" dropped. There is a lack of consensus on
>    this one. Christoph would like ALLPHYSICAL removed, but the HPC
>    community prefers keeping a performance-at-all-costs option. And,
>    with most other registration modes now removed, ALLPHYSICAL is
>    the mode of last resort if an adapter does not support FRMR or
>    MTHCAFMR, since ALLPHYSICAL is universally supported. We will
>    very likely revisit this later. I'm erring on the side of less
>    churn and dropping this until the community agrees on how to
>    move forward.
> 
>  - Added a patch to ensure there is always a valid ->qp if RPCs
>    might awaken while the transport is disconnected.
> 
>  - Added a patch to clean up an MTU settings hack for a very old
>    adapter model.
> 
> Test and review the "nfs-rdma-client" branch:
> 
>  git://git.linux-nfs.org/projects/cel/cel-2.6.git
> 
> Thanks!

Hi Chuck,

I've installed this in my cluster and ran a number of simple tests
over a variety of hardware.  For the most part, it's looking much
better than NFSoRDMA looked a kernel or two back, but I can still
trip it up.  All tests were run with rhel7 + current upstream
kernel.

My server was using mlx4 hardware in both IB and RoCE modes.

I tested from mlx4 client in both IB and RoCE modes -> not DOA
I tested from mlx5 client in IB mode -> not DOA
I tested from mthca client in IB mode -> not DOA
I tested from qib client in IB mode -> not DOA
I tested from ocrdma client in RoCE mode -> DOA (cpu soft lockup
  on mount on the client)

I tested nfsv3 -> not DOA
I tested nfsv4 + rdma -> still DOA, but I think this is expected
  as last I knew someone needs to write code for nfsv4 mountd
  over rdma before this will work (as nfsv3 uses a tcp connection
  to do mounting, and then switches to rdma for data transfers
  and nfsv4 doesn't support that or something like that...this
  is what I recall Jeff Layton telling me anyway)

I tested nfsv3 in both IB and RoCE modes with rsize=32768 and
wsize=32768 -> not DOA, reliable, did data verification and passed

I tested nfsv3 in both IB and RoCE modes with rsize=65536 and
wsize=65536 -> not DOA, but not reliable either, data transfers
will stop after a certain amount has been transferred and the
mount will have a soft hang

My data verification was simple (but generally effective in
lots of scenarios):

I had a full linux kernel git repo, with a complete build in it
(totaling a little over 9GB of disk space used) and I would run
tar -cf - linus | tar -xvf - -C <tmpdir> to copy the tree
around (I did copies both on the same mount and on a different
mount that was also NFSoRDMA, including copying from an IB
NFSoRDMA mount to a RoCE NFSoRDMA mount on different mlx4 ports),
and then diff -uprN on the various tree locations to check for
any data differences.

So there's your testing report.  As I said in the beginning, it's
definitely better than it was since it used to oops the server and
I didn't encounter any server side problems this time, only client
side problems.

ToDo items that I see:

Write NFSv4 rdma protocol mount support
Fix client soft mount hangs when rsize/wsize > 32768
Fix DOA of ocrdma driver

Tested-by: Doug Ledford <dledford@redhat.com>


-- 
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD
	      http://people.redhat.com/dledford

