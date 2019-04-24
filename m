Return-Path: <SRS0=08pM=S2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63AA0C282E1
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 13:55:53 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3FEEC218FD
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 13:55:53 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730912AbfDXNzw (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 24 Apr 2019 09:55:52 -0400
Received: from fieldses.org ([173.255.197.46]:48968 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1730827AbfDXNzv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 24 Apr 2019 09:55:51 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id CEFB31C9D; Wed, 24 Apr 2019 09:55:50 -0400 (EDT)
Date:   Wed, 24 Apr 2019 09:55:50 -0400
From:   Bruce Fields <bfields@fieldses.org>
To:     Jeff Layton <jlayton@kernel.org>
Cc:     NeilBrown <neilb@suse.com>, slawek1211@gmail.com,
        "open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] locks: move checks from locks_free_lock() to
 locks_release_private()
Message-ID: <20190424135550.GA20542@fieldses.org>
References: <20190422163424.19402-1-jlayton@kernel.org>
 <20190422163424.19402-2-jlayton@kernel.org>
 <87wojl61s5.fsf@notabene.neil.brown.name>
 <CAOhYWN+qtb3fRRbxJBMOCyyivc5-rYAfeVZ362HxWjett+UGHQ@mail.gmail.com>
 <87r29s5fiv.fsf@notabene.neil.brown.name>
 <CAOhYWN+wgm9gVPkGW=jh+WUt0T_Nn1zs=BZAKt8y-b50dWM4zw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOhYWN+wgm9gVPkGW=jh+WUt0T_Nn1zs=BZAKt8y-b50dWM4zw@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Apr 24, 2019 at 09:47:59AM -0400, Jeff Layton wrote:
> Looks good to me. Bruce, would you mind picking this up for the next
> merge window? I don't have any other file locking patches queued up
> for v5.2, and I hate to send Linus a PR for just this.
> 
> Either way:
> 
> Reviewed-by: Jeff Layton <jlayton@kernel.org>

Got it, thanks.--b.
