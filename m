Return-Path: <SRS0=XJYd=BT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71866C433DF
	for <linux-nfs@archiver.kernel.org>; Sun,  9 Aug 2020 20:27:44 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 0EA1F206B5
	for <linux-nfs@archiver.kernel.org>; Sun,  9 Aug 2020 20:27:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fieldses.org header.i=@fieldses.org header.b="qQe9n9xY"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726299AbgHIU1n (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 9 Aug 2020 16:27:43 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:59930 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726296AbgHIU1n (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 9 Aug 2020 16:27:43 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id DBF31C061756
        for <linux-nfs@vger.kernel.org>; Sun,  9 Aug 2020 13:27:42 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id 536DE69C3; Sun,  9 Aug 2020 16:27:39 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 536DE69C3
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1597004859;
        bh=RmGACZZZQ1527G5ocrb6UZaQEA8gJh1S3mqOpgsULNk=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=qQe9n9xYldBLGwi+S1Pj7JewELTwBR24a64ZkBR/hdcyCj2wVEiw7uHR6so4wkZsQ
         QMiBJ0w3zW43ISWkeHUR8/NgNK30CBqSQv+OYH4Bf94GsPJOfZCphrncPpiae89wVL
         ZyPLfwcep8yTC+KA64c3kjayUontuVetIn78Viyo=
Date:   Sun, 9 Aug 2020 16:27:39 -0400
From:   Bruce Fields <bfields@fieldses.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: still seeing single client NFS4ERR_DELAY / CB_RECALL
Message-ID: <20200809202739.GA29574@fieldses.org>
References: <139C6BD7-4052-4510-B966-214ED3E69D61@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <139C6BD7-4052-4510-B966-214ED3E69D61@oracle.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sun, Aug 09, 2020 at 01:11:36PM -0400, Chuck Lever wrote:
> Hi Bruce-
> 
> I noticed that one of my tests takes about 4x longer on NFSv4.0 than
> it does on NFSv3 or NFSv4.[12]. As an initial stab at the cause, I'm
> seeing lots of these:

Oops, looks obvious in retrospect, but I didn't think of it.

In the 4.1+ case, sessions mean that we know which client every
operation comes from.

In the 4.0 case that only works for operations that take a stateid or
something else we can link back to a client.

That means in the 4.0 case delegations are less useful, since they have
to be broken on any (non-truncating) setattr, any link/unlink, etc.,
even if the operation comes from the same client--the server doesn't
have a way to know that.

Maybe the change to give out read delegations even on write opens
probably just isn't worth in the 4.0 case.

--b.


> 
>            <...>-283894 [003]  4060.507314: nfs4_xdr_status:
>            task:51308@5 xid=0x1ec806a9 error=-10008 (DELAY)
>            operation=34 <...>-283894 [003]  4060.507338: nfs4_setattr:
>            error=-10008 (DELAY) fileid=00:27:258012 fhandle=0x25ef273d
>            stateid=0:0x7bd5c66f <...>-283982 [006]  4060.508134:
>            nfs4_state_mgr:       hostname=klimt.ib clp
>            state=CHECK_LEASE|0x4020 NFSv4-6239  [007]  4060.508137:
>            nfs4_cb_recall:       error=0 (OK) fileid=00:27:258012
>            fhandle=0x25ef273d stateid=1:0x910c8d4c dstaddr=klimt.ib
> 
> The workload is the git regression suite, which I run like this on a
> single client:
> 
>   --- mount test export ---
> 
>  $ cd /mnt; rm -rf git*; tar zvxf ~/Downloads/git-2.23.0.tar.gz
> 
>   --- remount test export ---
> 
>  $ cd /mnt/git*; make clean; make -j12
> 
>   --- remount test export ---
> 
>  $ cd /mnt/git*; make -j12 test
> 
> -- Chuck Lever
> 
> 
