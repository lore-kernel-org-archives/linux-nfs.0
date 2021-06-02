Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.3 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BCA5CC4708F
	for <linux-nfs@archiver.kernel.org>; Wed,  2 Jun 2021 20:04:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id A439961360
	for <linux-nfs@archiver.kernel.org>; Wed,  2 Jun 2021 20:04:14 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229892AbhFBUFx (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 2 Jun 2021 16:05:53 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:57724 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229489AbhFBUFv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Jun 2021 16:05:51 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 3A1C6C061756
        for <linux-nfs@vger.kernel.org>; Wed,  2 Jun 2021 13:04:08 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id 857E46D0D; Wed,  2 Jun 2021 16:04:07 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 857E46D0D
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1622664247;
        bh=P5oTm09B6iv9wzn0BcoXtFFBSDx9zqbVYl0t9GRVe7Y=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=oqGMsqDPGU8+lmGAmXkCPfJkL1ynlya2/TuUQwQoZ5tNYkuQp16aNaiXfnrUcAdZP
         0kVRG4M+KMfX8I646m1ORjNgFVc8ErR3Vxe9tWXcen2j7yYqoZ9l7F0uRRwUbm1E+X
         ENUHQOtUuxGi2UQNEOhRwNw2Icig6KLqruR+Og1w=
Date:   Wed, 2 Jun 2021 16:04:07 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     David Wysochanski <dwysocha@redhat.com>
Cc:     linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: BUG: KASAN: use-after-free in
 find_clp_in_name_tree.isra.0+0x13e/0x190 [nfsd]
Message-ID: <20210602200407.GB6995@fieldses.org>
References: <CALF+zOnw_6i2M0gv4rZYURdZgO8e84ja8u_7yEMnMz=3n+hKJg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALF+zOnw_6i2M0gv4rZYURdZgO8e84ja8u_7yEMnMz=3n+hKJg@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Jun 02, 2021 at 02:13:02PM -0400, David Wysochanski wrote:
> I was testing your nfsd-next branch (plus my modified v3 callback
> address and state patch I just sent) and saw this on console after a
> simple test of mount, umount, mount cycle of a NFSv4.1 mount.

Oops, thanks, it just needs this, I think; maybe I'd've caught that bug
earlier if I'd actually posted that patch.  Doing that now....

--b.

commit 70d6ebca5248
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Wed Jun 2 15:50:45 2021 -0400

    foldme

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 967912b4a7dd..6c64ce93510f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2841,6 +2841,7 @@ move_to_confirmed(struct nfs4_client *clp)
 	list_move(&clp->cl_idhash, &nn->conf_id_hashtbl[idhashval]);
 	rb_erase(&clp->cl_namenode, &nn->unconf_name_tree);
 	add_clp_to_name_tree(clp, &nn->conf_name_tree);
+	set_bit(NFSD4_CLIENT_CONFIRMED, &clp->cl_flags);
 	trace_nfsd_clid_confirmed(&clp->cl_clientid);
 	renew_client_locked(clp);
 }
