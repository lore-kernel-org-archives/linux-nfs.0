Return-Path: <SRS0=vPHX=PY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6F1EC43444
	for <linux-nfs@archiver.kernel.org>; Wed, 16 Jan 2019 23:07:55 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 945E120675
	for <linux-nfs@archiver.kernel.org>; Wed, 16 Jan 2019 23:07:55 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388058AbfAPXHu (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 16 Jan 2019 18:07:50 -0500
Received: from fieldses.org ([173.255.197.46]:49372 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727337AbfAPXHt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 16 Jan 2019 18:07:49 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 3CF512013; Wed, 16 Jan 2019 18:07:49 -0500 (EST)
Date:   Wed, 16 Jan 2019 18:07:49 -0500
From:   Bruce Fields <bfields@fieldses.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     "Gustavo A. R. Silva" <gustavo@embeddedor.com>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH net-next] svcrdma: Use struct_size() in kmalloc()
Message-ID: <20190116230749.GB5948@fieldses.org>
References: <20190115211140.GA16131@embeddedor>
 <F652FEF1-0FD7-4FFD-80D4-44DBC2FF47B5@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <F652FEF1-0FD7-4FFD-80D4-44DBC2FF47B5@oracle.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Jan 15, 2019 at 04:49:16PM -0500, Chuck Lever wrote:
> 
> 
> On Jan 15, 2019, at 4:11 PM, Gustavo A. R. Silva <gustavo@embeddedor.com> wrote:
> 
> > One of the more common cases of allocation size calculations is finding
> > the size of a structure that has a zero-sized array at the end, along
> > with memory for some number of elements for that array. For example:
> > 
> > struct foo {
> >    int stuff;
> >    struct boo entry[];
> > };
> > 
> > instance = kmalloc(sizeof(struct foo) + count * sizeof(struct boo), GFP_KERNEL);
> > 
> > Instead of leaving these open-coded and prone to type mistakes, we can
> > now use the new struct_size() helper:
> > 
> > instance = kmalloc(struct_size(instance, entry, count), GFP_KERNEL);
> > 
> > This code was detected with the help of Coccinelle.
> > 
> > Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>
> 
> Reviewed-by: Chuck Lever <chuck.lever@oracle.com>

Thanks, applying for 5.1.--b.

> 
> 
> > ---
> > net/sunrpc/xprtrdma/svc_rdma_rw.c | 3 +--
> > 1 file changed, 1 insertion(+), 2 deletions(-)
> > 
> > diff --git a/net/sunrpc/xprtrdma/svc_rdma_rw.c b/net/sunrpc/xprtrdma/svc_rdma_rw.c
> > index dc1951759a8e..cad37c2122ab 100644
> > --- a/net/sunrpc/xprtrdma/svc_rdma_rw.c
> > +++ b/net/sunrpc/xprtrdma/svc_rdma_rw.c
> > @@ -64,8 +64,7 @@ svc_rdma_get_rw_ctxt(struct svcxprt_rdma *rdma, unsigned int sges)
> > 		spin_unlock(&rdma->sc_rw_ctxt_lock);
> > 	} else {
> > 		spin_unlock(&rdma->sc_rw_ctxt_lock);
> > -		ctxt = kmalloc(sizeof(*ctxt) +
> > -			       SG_CHUNK_SIZE * sizeof(struct scatterlist),
> > +		ctxt = kmalloc(struct_size(ctxt, rw_first_sgl, SG_CHUNK_SIZE),
> > 			       GFP_KERNEL);
> > 		if (!ctxt)
> > 			goto out;
> > -- 
> > 2.20.1
> 
> --
> Chuck Lever
> 
> 
