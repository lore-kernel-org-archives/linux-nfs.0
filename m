Return-Path: <SRS0=pkAy=C4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE63DC43464
	for <linux-nfs@archiver.kernel.org>; Sat, 19 Sep 2020 16:40:22 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 5FFF3208DB
	for <linux-nfs@archiver.kernel.org>; Sat, 19 Sep 2020 16:40:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fieldses.org header.i=@fieldses.org header.b="Jdq8y3OL"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726518AbgISQkV (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 19 Sep 2020 12:40:21 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:44808 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726463AbgISQkV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 19 Sep 2020 12:40:21 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 761A4C0613CE
        for <linux-nfs@vger.kernel.org>; Sat, 19 Sep 2020 09:40:21 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id CA309689F; Sat, 19 Sep 2020 12:40:20 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org CA309689F
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1600533620;
        bh=cuuMLu4lFSYrn7CgFivDw/N8Db9Dj4yGiM60G/tQmys=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=Jdq8y3OLux9r5/Bl+iW57v6lwEgPhc8Zp5bftJGAUiOhUJgQxLeO9vWtCGzcHNh4D
         DwkaVFNIM7EAmB9rksoAvRH+T9IKaCsEAi6U44IX+AIOuWHUSIw5n69n0ofndi0BVn
         F4wSZQWlIHY5OL3GcLR1cm00hvgFBypNa50HRYv0=
Date:   Sat, 19 Sep 2020 12:40:20 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Chris Hall <linux-nfs@gmch.uk>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: mount.nfs4 and logging
Message-ID: <20200919164020.GB15785@fieldses.org>
References: <S1725851AbgIKKt5/20200911104957Z+185@vger.kernel.org>
 <a38a1249-c570-9069-a498-5e17d85a418a@gmch.uk>
 <f06f86ef-08bd-3974-3d92-1fbda700cc11@RedHat.com>
 <f7b9c8b4-29a6-2f28-b1d9-739c546fd557@gmch.uk>
 <20200919163353.GA15785@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200919163353.GA15785@fieldses.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sat, Sep 19, 2020 at 12:33:53PM -0400, J. Bruce Fields wrote:
> For the server, you don't need rpcbind or rpc.statd for v4, but you do
> need rpc.idmapd, rpc.mountd and nfsdcld.
> 
> rpc.mountd is the only one of those three that needs to listen on a
> network port, but that's only in the NFSv2/v3 case.  I'm not sure if
> we're getting that right.

Looking at the code, it looks correct--I see mountd starting those
listeners only when v2 or v3 are configured.

The documentation could be better, though.

--b.
