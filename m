Return-Path: <SRS0=IhtM=DC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B981FC4363D
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Sep 2020 14:47:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 1FA492074B
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Sep 2020 14:47:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fieldses.org header.i=@fieldses.org header.b="tAcg5HqX"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728693AbgIYOrP (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 25 Sep 2020 10:47:15 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:56522 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728436AbgIYOrP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Sep 2020 10:47:15 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 09EABC0613CE
        for <linux-nfs@vger.kernel.org>; Fri, 25 Sep 2020 07:47:15 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id 4EC06C56; Fri, 25 Sep 2020 10:47:14 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 4EC06C56
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1601045234;
        bh=McapPCCMDMCEZu3rA2R6mNzGauzkfUy7ux7D7/AxO14=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=tAcg5HqXbdCArDnn7IgkUzuy1q4l40XY2t2Gv2l/7i9W8qsA1owzLcmAjOG5UMRpS
         JM/9nHV6yZsN5kPdImABot6/RZO6br/g2L/kdyn96SbWVIqFAJBLo0hvmmZYeu/Exv
         FbRZqm/sHqbQN2jCwhJXV7sNg7Usibbjx7IKDlV8=
Date:   Fri, 25 Sep 2020 10:47:14 -0400
From:   Bruce Fields <bfields@fieldses.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Bill Baker <Bill.Baker@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 26/27] NFSD: Add tracepoints in the NFS dispatcher
Message-ID: <20200925144714.GE1096@fieldses.org>
References: <160071167664.1468.1365570508917640511.stgit@klimt.1015granger.net>
 <160071198717.1468.14262284967190973528.stgit@klimt.1015granger.net>
 <20200924234526.GB12407@fieldses.org>
 <801F3A94-4668-4DF6-9CAF-27171EEBA17A@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <801F3A94-4668-4DF6-9CAF-27171EEBA17A@oracle.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Sep 25, 2020 at 09:59:54AM -0400, Chuck Lever wrote:
> 
> 
> > On Sep 24, 2020, at 7:45 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > 
> > On Mon, Sep 21, 2020 at 02:13:07PM -0400, Chuck Lever wrote:
> >> This is follow-on work to the tracepoints added in the NFS server's
> >> duplicate reply cache. Here, tracepoints are introduced that report
> >> replies from cache as well as encoding and decoding errors.
> >> 
> >> The NFSv2, v3, and v4 dispatcher requirements have diverged over
> >> time, leaving us with a little bit of technical debt. In addition,
> >> I wanted to add a tracepoint for NFSv2 and NFSv3 similar to the
> >> nfsd4_compound/compoundstatus tracepoints. Lastly, removing some
> >> conditional branches from this hot path helps optimize CPU
> >> utilization. So, I've duplicated the nfsd_dispatcher function.
> > 
> > Comparing current nfsd_dispatch to the nfsv2/v3 nfsd_dispatch: the only
> > thing I spotted removed from the v2/v3-specific dispatch is the
> > rq_lease_breaker = NULL.  (I think that's not correct, actually.  We
> > could remove the need for that to be set in the v2/v3 case, but with the
> > current code it does need to be set.)
> 
> Noted with thanks.
> 
> 
> > Comparing current nfsd_dispatch to the nfsv4 nfsd4_dispatch, the
> > v4-specific dispatch does away with nfs_request_too_big() and the
> > v2-specific shortcut in the error encoding case.
> > 
> > So these still look *very* similar.  I don't feel like we're getting a
> > lot of benefit out of splitting these out.
> 
> I don't disagree with that at all. At this point I'm just noodling
> to see what's possible. I'm now toying with other ways to add high-
> value tracing in the legacy ULPs. In the end I might end up avoiding
> significant changes in the dispatchers in order to add tracing.

OK.

> However, a few thoughts I had while learning how the dispatcher
> code works.
> 
> There are some opportunities for reducing instruction path length
> and the number of conditional branches in here. It's a hot path,
> so I think we should consider some careful micro-optimizations
> even if they don't add significant new features or do add some
> code duplication.
> 
> In user space, the library (iirc) assumes each ULP provides it's
> own dispatcher function. I'd consider duplicating and removing
> svc_generic_dispatcher() to simplify the pasta in svc_process(),
> again as a micro-optimization and for better code legibility.

Not sure you even have to duplicate it, just export the generic
dispatcher and let individual programs point to it, right?

> lockd's pc_func returns an RPC accept_stat, but the NFSD pc_func
> methods return an NFS status. The latter feels like a layering
> violation for the sake of reducing a small amount of code
> duplication. I'd rather see encoding of the NFS status handled in
> the NFS Reply encoders, since that is an XDR function, and because
> that logic seems slightly different for NFSv2, support for which
> we'd like to deprecate at some point.
>
> Note also that *statp in nfsd_dispatch is never explicitly set to
> rpc_success in the normal execution flow. It relies on the
> equivalence of rpc_success and nfs_ok, which is convenient, but
> confusing to read. It might be cleaner if *statp was made an enum
> to make it explicit what set of values go in that return variable.

OK.

--b.
