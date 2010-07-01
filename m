Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:25032 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752613Ab0GAQqf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Jul 2010 12:46:35 -0400
Subject: Re: [PATCH 4/5] NFSv4: Add support for the RELEASE_LOCKOWNER
 operation
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <4C2CBF9C.5050408@oracle.com>
References: <1277933137-6955-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1277933137-6955-2-git-send-email-Trond.Myklebust@netapp.com>
	 <1277933137-6955-3-git-send-email-Trond.Myklebust@netapp.com>
	 <1277933137-6955-4-git-send-email-Trond.Myklebust@netapp.com>
	 <1277933137-6955-5-git-send-email-Trond.Myklebust@netapp.com>
	 <4C2CBF9C.5050408@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 01 Jul 2010 12:46:33 -0400
Message-ID: <1278002793.2951.13.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-07-01 at 12:17 -0400, Chuck Lever wrote:
> On 06/30/10 05:25 PM, Trond Myklebust wrote:
> >
> > +static void encode_release_lockowner(struct xdr_stream *xdr, const struct nfs_lowner *lowner, struct compound_hdr *hdr)
> > +{
> > +	__be32 *p;
> > +
> > +	p = reserve_space(xdr, 4);
> > +	*p++ = cpu_to_be32(OP_RELEASE_LOCKOWNER);
> 
> Nit: *p++ isn't needed here.  *p will do.

True. I'll fix that up.

Thanks!

Trond
