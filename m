Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59566 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754715Ab1CQRwh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Mar 2011 13:52:37 -0400
Date: Thu, 17 Mar 2011 13:52:29 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: roel <roel.kluin@gmail.com>, Neil Brown <neilb@suse.de>,
        linux-nfs@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
        LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] nfsd: wrong index used in inner loop
Message-ID: <20110317175229.GE30180@fieldses.org>
References: <4D76A06A.4090405@gmail.com>
 <20110309004955.GD15814@fieldses.org>
 <4D79A183.8090306@cn.fujitsu.com>
 <20110314222229.GJ25442@fieldses.org>
 <4D7ECF91.2030308@cn.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D7ECF91.2030308@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Mar 15, 2011 at 10:31:45AM +0800, Mi Jinlong wrote:
> 
> 
> J. Bruce Fields:
> > Actually, wait, this is kind of silly.  I don't see why we couldn't just
> > skip the loop and do
> > 
> > 	p += dummy;
> > 
> > Also, your new test is still failing with a BAD_XDR error.  Well, maybe
> > the test should fail--we don't really implement this yet anyway--but it
> > should at least be getting past the xdr decoding.  So something else is
> > still wrong.
> 
>   How did you modify it??
> 
>   When testing it, I modify as 
>  
>     -                       for (j = 0; j < dummy; ++j)
>     -                               READ32(dummy);
>     +                       p += dummy;
> 
>   or
>     
>     -                       for (j = 0; j < dummy; ++j)
>     -                               READ32(dummy);
> 
>   Test case CSESS16 and CSESS16a are PASS, 
>   I can't get BAD_XDR error as you said.

Yes, I thought I had the former, but perhaps I had the wrong kernel
running on my test server.  I've confirmed those tests pass after the
following patch.

--b.

commit 5a02ab7c3c4580f94d13c683721039855b67cda6
Author: Mi Jinlong <mijinlong@cn.fujitsu.com>
Date:   Fri Mar 11 12:13:55 2011 +0800

    nfsd: wrong index used in inner loop
    
    We must not use dummy for index.
    After the first index, READ32(dummy) will change dummy!!!!
    
    Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
    [bfields@redhat.com: Trond points out READ_BUF alone is sufficient.]
    Cc: stable@kernel.org
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 615f0a9..c6766af 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1142,7 +1142,7 @@ nfsd4_decode_create_session(struct nfsd4_compoundargs *argp,
 
 	u32 dummy;
 	char *machine_name;
-	int i, j;
+	int i;
 	int nr_secflavs;
 
 	READ_BUF(16);
@@ -1215,8 +1215,6 @@ nfsd4_decode_create_session(struct nfsd4_compoundargs *argp,
 			READ_BUF(4);
 			READ32(dummy);
 			READ_BUF(dummy * 4);
-			for (j = 0; j < dummy; ++j)
-				READ32(dummy);
 			break;
 		case RPC_AUTH_GSS:
 			dprintk("RPC_AUTH_GSS callback secflavor "
@@ -1232,7 +1230,6 @@ nfsd4_decode_create_session(struct nfsd4_compoundargs *argp,
 			READ_BUF(4);
 			READ32(dummy);
 			READ_BUF(dummy);
-			p += XDR_QUADLEN(dummy);
 			break;
 		default:
 			dprintk("Illegal callback secflavor\n");
