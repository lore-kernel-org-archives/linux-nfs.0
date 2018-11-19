Return-Path: <SRS0=xyvj=N6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88F23C43441
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Nov 2018 19:54:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2BF5920831
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Nov 2018 19:54:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2BF5920831
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730738AbeKTGTw (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 20 Nov 2018 01:19:52 -0500
Received: from fieldses.org ([173.255.197.46]:57156 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1730519AbeKTGTw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Nov 2018 01:19:52 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id B305C37E; Mon, 19 Nov 2018 14:54:42 -0500 (EST)
Date:   Mon, 19 Nov 2018 14:54:42 -0500
From:   Bruce Fields <bfields@fieldses.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 3/4] NFSD: Refactor the generic write vector fill
 helper
Message-ID: <20181119195442.GA22976@fieldses.org>
References: <20180727142007.21878.77494.stgit@klimt.1015granger.net>
 <20180727151905.21878.62693.stgit@klimt.1015granger.net>
 <20181115163246.GB9022@fieldses.org>
 <A6FEE9E7-0226-460F-AA3E-42D7CEE9A781@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <A6FEE9E7-0226-460F-AA3E-42D7CEE9A781@oracle.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Nov 15, 2018 at 04:19:52PM -0800, Chuck Lever wrote:
> 
> 
> > On Nov 15, 2018, at 8:32 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > 
> > Um, I somehow managed to overlook a pynfs regression till just now:
> > 
> > On Fri, Jul 27, 2018 at 11:19:05AM -0400, Chuck Lever wrote:
> >> fill_in_write_vector() is nearly the same logic as
> >> svc_fill_write_vector(), but there are a few differences so that
> >> the former can handle multiple WRITE payloads in a single COMPOUND.
> >> 
> >> svc_fill_write_vector() can be adjusted so that it can be used in
> >> the NFSv4 WRITE code path too. Instead of assuming the pages are
> >> coming from rq_args.pages, have the caller pass in the page list.
> >> 
> >> The immediate benefit is a reduction of code duplication. It also
> >> prevents the NFSv4 WRITE decoder from passing an empty vector
> >> element when the transport has provided the payload in the xdr_buf's
> >> page array.
> >> 
> > ...
> >> @@ -1027,7 +1009,10 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
> >> 	write->wr_how_written = write->wr_stable_how;
> >> 	gen_boot_verifier(&write->wr_verifier, SVC_NET(rqstp));
> >> 
> >> -	nvecs = fill_in_write_vector(rqstp->rq_vec, write);
> >> +	nvecs = svc_fill_write_vector(rqstp, write->wr_pagelist,
> >> +				      &write->wr_head, write->wr_buflen);
> >> +	if (!nvecs)
> >> +		return nfserr_io;
> > 
> > Do you remember why you added this check?
> 
> Yes, at one point svc_fill_write_vector() called the transport
> layer to do some processing, and I needed a way for it to
> indicate a graceful failure.
> 
> 
> > It's causing zero-length writes to fail, in violation of the spec:
> > 
> > 	"If the count is zero, the WRITE will succeed and return a count
> > 	of zero subject to permissions checking."
> 
> RFC 7530, Section 16.36.4.
> 
> 
> > I'm not seeing a reason why it wouldn't be safe just to remove that
> > check.
> 
> Or, make the check more specific:
> 
> 	if (!nvecs && write->wr_buflen)
> 		return nfserr_io;
> 
> This is a little more bullet proof, in case of bugs in the
> transport layer.

The current svc_fill_write_vector is pretty short and obviously can't
hit that case, so I'd just find that confusing.  We can re-add that
check when if and when it's needed.

--b.
