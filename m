Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:61367 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754345Ab3EVLvh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 May 2013 07:51:37 -0400
Date: Wed, 22 May 2013 07:51:33 -0400
From: Jim Rees <rees@umich.edu>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: include invalid uid/gid in the error message
Message-ID: <20130522115133.GA6274@umich.edu>
References: <1369216794-18044-1-git-send-email-tigran.mkrtchyan@desy.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1369216794-18044-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tigran Mkrtchyan wrote:

  if client receives an invalid uid/gid debug message is generated.
  Unfortunately the actual invalid value is not included.
  
  Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
  ---
   fs/nfs/nfs2xdr.c | 4 ++--
   fs/nfs/nfs3xdr.c | 4 ++--
   2 files changed, 4 insertions(+), 4 deletions(-)
  
  diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
  index 62db136..85c0646 100644
  --- a/fs/nfs/nfs2xdr.c
  +++ b/fs/nfs/nfs2xdr.c
  @@ -319,10 +319,10 @@ static int decode_fattr(struct xdr_stream *xdr, struct nfs_fattr *fattr)
   
   	return 0;
   out_uid:
  -	dprintk("NFS: returned invalid uid\n");
  +	dprintk("NFS: returned invalid uid %d\n", fattr->uid);
   	return -EINVAL;
   out_gid:
  -	dprintk("NFS: returned invalid gid\n");
  +	dprintk("NFS: returned invalid gid %d\n", fattr->gid);
   	return -EINVAL;
   out_overflow:
   	print_overflow_msg(__func__, xdr);
  diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
  index fa6d721..cd52069 100644
  --- a/fs/nfs/nfs3xdr.c
  +++ b/fs/nfs/nfs3xdr.c
  @@ -680,10 +680,10 @@ static int decode_fattr3(struct xdr_stream *xdr, struct nfs_fattr *fattr)
   	fattr->valid |= NFS_ATTR_FATTR_V3;
   	return 0;
   out_uid:
  -	dprintk("NFS: returned invalid uid\n");
  +	dprintk("NFS: returned invalid uid %d\n", fattr->uid);
   	return -EINVAL;
   out_gid:
  -	dprintk("NFS: returned invalid gid\n");
  +	dprintk("NFS: returned invalid gid %d\n", fattr->gid);
   	return -EINVAL;
   out_overflow:
   	print_overflow_msg(__func__, xdr);
  -- 
  1.8.1.4
  
  --
  To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
  the body of a message to majordomo@vger.kernel.org
  More majordomo info at  http://vger.kernel.org/majordomo-info.html

I can't tell what the type of fattr->uid is through the maze of include
files, but would it be a good idea to cast this to unsigned long for
printing?
