Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:52497 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752869Ab0LGAbI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Dec 2010 19:31:08 -0500
Date: Mon, 6 Dec 2010 19:31:04 -0500
From: Jim Rees <rees@umich.edu>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/3] nfsd: fix offset printk's in nfsd3 read/write
Message-ID: <20101207003104.GA4317@merit.edu>
References: <1291680566-13980-1-git-send-email-bfields@redhat.com>
 <1291680566-13980-4-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1291680566-13980-4-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

J. Bruce Fields wrote:

  Thanks to dysbr01@ca.com for noticing that the debugging printk in
  the v3 write procedure can print >2GB offsets as negative numbers:
  	https://bugzilla.kernel.org/show_bug.cgi?id=23342
  
  Signed-off-by: J. Bruce Fields <bfields@redhat.com>
  ---
   fs/nfsd/nfs3proc.c |    8 ++++----
   1 files changed, 4 insertions(+), 4 deletions(-)
  
  diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
  index 5b7e302..2247fc9 100644
  --- a/fs/nfsd/nfs3proc.c
  +++ b/fs/nfsd/nfs3proc.c
  @@ -151,10 +151,10 @@ nfsd3_proc_read(struct svc_rqst *rqstp, struct nfsd3_readargs *argp,
   	__be32	nfserr;
   	u32	max_blocksize = svc_max_payload(rqstp);
   
  -	dprintk("nfsd: READ(3) %s %lu bytes at %lu\n",
  +	dprintk("nfsd: READ(3) %s %lu bytes at %Lu\n",

Isn't "llu" preferred over "Lu" these days?
