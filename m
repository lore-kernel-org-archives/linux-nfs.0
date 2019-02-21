Return-Path: <SRS0=V3X6=Q4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF804C43381
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Feb 2019 16:27:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C457620818
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Feb 2019 16:27:41 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726400AbfBUQ1l (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 21 Feb 2019 11:27:41 -0500
Received: from fieldses.org ([173.255.197.46]:51304 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726074AbfBUQ1l (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 21 Feb 2019 11:27:41 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 1B0181C26; Thu, 21 Feb 2019 11:27:40 -0500 (EST)
Date:   Thu, 21 Feb 2019 11:27:40 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Chris Tracy <ctracy@engr.scu.edu>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: Linux NFS v4.1 server support for dynamic slot allocation?
Message-ID: <20190221162740.GD23154@fieldses.org>
References: <alpine.LRH.2.21.1902181301001.4186@unimatrix3.engr.scu.edu>
 <20190220171027.GA4399@fieldses.org>
 <alpine.LRH.2.21.1902201017450.7591@unimatrix3.engr.scu.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.21.1902201017450.7591@unimatrix3.engr.scu.edu>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Feb 20, 2019 at 11:07:45AM -0800, Chris Tracy wrote:
> 	I'm nothing close to a kernel hacker, but the issue seems to come
> down to nfsd4_get_drc_mem().  Yes, it calls slot_bytes() which uses
> ca->maxresp_cached (the size of which is impacted by the referenced
> patch) but the slot size's impact on the number of slots returned
> seems to pale in comparison to this bit in nfsd4_get_drc_mem():

Gah, yes, that's just a bug.  Thanks for your persistence.

We need some (optional) pynfs CREATE_SESSION tests to confirm that this
is working the way we expect, rather than waiting for people to report
performance regressions....

> 	And in fairness, it's not like it's broken out of the box.  I'm
> complaining about single-client read speeds being 600MB/s with NFS
> v3/v4.0 but "only" ~440MB/s with NFS v4.1/v4.2.

Out of curiosity, is your bandwidth limited by disk at this point?  If
not it might be interesting to compare with recent upstream.

> NOTE: Looking at it now, I wonder if the intent of the comment block
> in nfsd4_get_drc_mem() would be better expressed:
> 
> --------
> avail = min((unsigned long)NFSD_MAX_MEM_PER_SESSION,
> 		nfsd_drc_max_mem - nfsd_drc_mem_used);
> /*
>  * Never use more than a third of the remaining memory,
>  * unless it's the only way to give this client a slot:
>  */
> avail = clamp_t(int, avail, slotsize,
> 	(nfsd_drc_max_mem - nfsd_drc_mem_used)/3);
> num = min_t(int, num, avail / slotsize);
> --------
> 
> ensuring that 'avail' can never be more than a third of the DRC
> memory available, rather than a third of NFSD_MAX_MEM_PER_SESSION.

Yep.  Here's what I've got:

commit c54f24e338ed
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Thu Feb 21 10:47:00 2019 -0500

    nfsd: fix performance-limiting session calculation
    
    We're unintentionally limiting the number of slots per nfsv4.1 session
    to 10.  Often more than 10 simultaneous RPCs are needed for the best
    performance.
    
    This calculation was meant to prevent any one client from using up more
    than a third of the limit we set for total memory use across all clients
    and sessions.  Instead, it's limiting the client to a third of the
    maximum for a single session.
    
    Fix this.
    
    Reported-by: Chris Tracy <ctracy@engr.scu.edu>
    Cc: stable@vger.kernel.org
    Fixes: de766e570413 "nfsd: give out fewer session slots as limit approaches"
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index fb3c9844c82a..6a45fb00c5fc 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1544,16 +1544,16 @@ static u32 nfsd4_get_drc_mem(struct nfsd4_channel_attrs *ca)
 {
 	u32 slotsize = slot_bytes(ca);
 	u32 num = ca->maxreqs;
-	int avail;
+	unsigned long avail, total_avail;
 
 	spin_lock(&nfsd_drc_lock);
-	avail = min((unsigned long)NFSD_MAX_MEM_PER_SESSION,
-		    nfsd_drc_max_mem - nfsd_drc_mem_used);
+	total_avail = nfsd_drc_max_mem - nfsd_drc_mem_used;
+	avail = min((unsigned long)NFSD_MAX_MEM_PER_SESSION, total_avail);
 	/*
 	 * Never use more than a third of the remaining memory,
 	 * unless it's the only way to give this client a slot:
 	 */
-	avail = clamp_t(int, avail, slotsize, avail/3);
+	avail = clamp_t(int, avail, slotsize, total_avail/3);
 	num = min_t(int, num, avail / slotsize);
 	nfsd_drc_mem_used += num * slotsize;
 	spin_unlock(&nfsd_drc_lock);
