Return-Path: <SRS0=q2Lh=Q3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56F77C43381
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 17:10:29 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 306A42146E
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 17:10:29 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725806AbfBTRK2 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 20 Feb 2019 12:10:28 -0500
Received: from fieldses.org ([173.255.197.46]:49184 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725801AbfBTRK2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 20 Feb 2019 12:10:28 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 9FDE7189; Wed, 20 Feb 2019 12:10:27 -0500 (EST)
Date:   Wed, 20 Feb 2019 12:10:27 -0500
To:     Chris Tracy <ctracy@engr.scu.edu>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: Linux NFS v4.1 server support for dynamic slot allocation?
Message-ID: <20190220171027.GA4399@fieldses.org>
References: <alpine.LRH.2.21.1902181301001.4186@unimatrix3.engr.scu.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.21.1902181301001.4186@unimatrix3.engr.scu.edu>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Feb 18, 2019 at 01:46:24PM -0800, Chris Tracy wrote:
> 	Hopefully I'm not missing something obvious, but I'm curious
> whatever happened to the patch series from late 2012 that added
> dynamic v4.1 session slot allocation support to nfsd:
> 
> https://www.spinics.net/lists/linux-nfs/msg34390.html
> 
> The corresponding nfs client patches were integrated, but the nfsd
> series seems to have been left out due to release timing:
> 
> https://www.spinics.net/lists/linux-nfs/msg34505.html
> 
> However, they don't seem to ever have been integrated or discussed
> again. Were there other issues that prevented its inclusion in the
> intervening time?

They'd probably need reworking.  The latest discussion I can find is:

	https://lore.kernel.org/linux-nfs/CAABAsM6vDOaudUZYWH23oGiWGqX5Bd1YbCDnL6L=pxzMXgZzaw@mail.gmail.com/

> 	Alternatively, is there some admin-tweakable knob for controlling
> the number of slots available per-session on the NFS v4.1 server
> (nfsd.ko), similar to the 'max_session_slots' client-side parameter
> for nfs.ko?
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/fs/nfs?id=ef159e9177cc5a09e6174796dde0b2d243ddf28b
> 
> 	I ask because I'm currently standing up a (very) modest HPC cluster
> PoC (1 server, 8 client nodes, all 10Gbit, all running CentOS 7.6)
> and figured that was a good enough excuse to finally move away from
> NFS v3 and investigate NFS v4.x.  However, initial performance
> testing showed that while NFS v4.0 was essentially identical to v3,
> NFS v4.2 (and v4.1) were around 25% slower.
> 
> 	Looking at the traffic in wireshark, I see that in CREATE_SESSION,
> the client sets ca_maxrequests to 64 (consistent with the value of
> 'max_session_slots') but the server always replies with a value of
> 10 for ca_maxreqests.  This seems to be the source of the
> performance issue, since if I fallback to v4.0 or v3, but set nfsd
> to use only 10 threads in nfs.conf, I get roughly equivalent
> performance to v4.2.
> 
> 	Looking at the code (both in CentOS's 3.10.0-957.5.1.el7.x86_64 and
> in the 4.20.8 mainline), it seems the value that would need to
> change is the preprocessor define NFSD_CACHE_SIZE_SLOTS_PER_SESSION.
> This is fixed at 32, and while it's a bit more complex than this,
> the code in nfs4_get_drc_mem (fs/nfsd/nfs4state.c) basically sets
> the per-client session slot limit to '(int)(32/3)' which is where
> the '10' comes from.

Thanks for the report!

I think the limit should only be that low if the client requests very
large slots.  Do your clients have 35c036ef4a72 "nfs: RPC_MAX_AUTH_SIZE
is in bytes" applied?

> 	Is there something else I've missed somewhere that allows adjusting
> the server-side session slot limit to be more than 10 without having
> to compile a custom version of nfsd.ko?

No.  It might be a good idea, though really I think your setup should
just work out of the box.

--b.
