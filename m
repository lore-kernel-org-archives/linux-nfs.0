Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:61095 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752912Ab0CWRB2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Mar 2010 13:01:28 -0400
Subject: [GIT PULL] Please pull NFS client bugfixes
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 23 Mar 2010 13:00:33 -0400
Message-ID: <1269363633.3065.7.camel@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Linus,

Please pull from the "bugfixes" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git bugfixes

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/file.c                  |    3 ++-
 fs/nfs/nfs4xdr.c               |    2 ++
 include/linux/sunrpc/bc_xprt.h |    5 ++++-
 net/sunrpc/auth_gss/auth_gss.c |    5 ++---
 net/sunrpc/bc_svc.c            |   15 ---------------
 net/sunrpc/clnt.c              |    1 +
 net/sunrpc/rpc_pipe.c          |    2 ++
 net/sunrpc/xprt.c              |   22 +++++++++-------------
 net/sunrpc/xprtsock.c          |    3 ---
 9 files changed, 22 insertions(+), 36 deletions(-)

commit 556ae3bb32cabe483375b857dda1322384c57b65
Author: Jeff Layton <jlayton@redhat.com>
Date:   Sun Mar 21 12:10:36 2010 -0400

    NFS: don't try to decode GETATTR if DELEGRETURN returned error
    
    The reply parsing code attempts to decode the GETATTR response even if
    the DELEGRETURN portion of the compound returned an error. The GETATTR
    response won't actually exist if that's the case and we're asking the
    parser to read past the end of the response.
    
    This bug is fairly benign. The parser catches this without reading past
    the end of the response and decode_getfattr returns -EIO. Earlier
    kernels however had decode_op_hdr using the READ_BUF macro, and this
    bug would make this printk pop any time the client got an error from
    a delegreturn:
    
    kernel: decode_op_hdr: reply buffer overflowed in line XXXX
    
    More recent kernels seem to have replaced this printk with a dprintk.
    
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f1f0abe192a72e75d7c59972e30784d043fd8d73
Author: Dan Carpenter <error27@gmail.com>
Date:   Sun Mar 21 12:10:34 2010 -0400

    sunrpc: handle allocation errors from __rpc_lookup_create()
    
    __rpc_lookup_create() can return ERR_PTR(-ENOMEM).
    
    Signed-off-by: Dan Carpenter <error27@gmail.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org

commit ff0901f8036a1586037c30a365c9666e946af0f1
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Mar 19 16:17:45 2010 -0400

    SUNRPC: Fix the return value of rpc_run_bc_task()
    
    Currently rpc_run_bc_task() will return NULL if the task allocation failed.
    However the only caller is bc_send, which assumes that the return value
    will be an ERR_PTR.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c9acb42ef1904d15d0fb315061cefbe638f67f3a
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Mar 19 15:36:22 2010 -0400

    SUNRPC: Fix a use after free bug with the NFSv4.1 backchannel
    
    The ->release_request() callback was designed to allow the transport layer
    to do housekeeping after the RPC call is done. It cannot be used to free
    the request itself, and doing so leads to a use-after-free bug in
    xprt_release().
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit cdead7cf12896c0e50a8be2e52de52c364603095
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Mar 19 15:36:22 2010 -0400

    SUNRPC: Fix a potential memory leak in auth_gss
    
    The function alloc_enc_pages() currently fails to release the pointer
    rqstp->rq_enc_pages in the error path.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Acked-by: J. Bruce Fields <bfields@citi.umich.edu>
    Cc: stable@kernel.org

commit d812e575822a2b7ab1a7cadae2571505ec6ec2bd
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Mar 19 13:55:17 2010 -0400

    NFS: Prevent another deadlock in nfs_release_page()
    
    We should not attempt to free the page if __GFP_FS is not set. Otherwise we
    can deadlock as per
    
      http://bugzilla.kernel.org/show_bug.cgi?id=15578
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org


