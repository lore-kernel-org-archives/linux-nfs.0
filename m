Return-Path: <SRS0=MTBG=NT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39431C0044C
	for <linux-nfs@archiver.kernel.org>; Thu,  8 Nov 2018 00:28:57 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id F11F22077B
	for <linux-nfs@archiver.kernel.org>; Thu,  8 Nov 2018 00:28:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F11F22077B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728031AbeKHKBp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 8 Nov 2018 05:01:45 -0500
Received: from fieldses.org ([173.255.197.46]:37594 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727829AbeKHKBp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Nov 2018 05:01:45 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 95AD51E29; Wed,  7 Nov 2018 19:28:55 -0500 (EST)
Date:   Wed, 7 Nov 2018 19:28:55 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Scott Mayhew <smayhew@redhat.com>
Cc:     jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC 0/4] un-deprecate nfsdcld
Message-ID: <20181108002855.GA30776@fieldses.org>
References: <20181106183511.17836-1-smayhew@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181106183511.17836-1-smayhew@redhat.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Thanks for doing this, we've really been wanting it.  I should be able
to get to it in the next few days....

Out of curiosity, what are you using for testing?

--b.

On Tue, Nov 06, 2018 at 01:35:07PM -0500, Scott Mayhew wrote:
> When nfsdcld was released, it was quickly deprecated in favor of the
> nfsdcltrack usermodehelper, so as to not require another running daemon.
> That prevents NFSv4 clients from reclaiming locks from nfsd's running in
> containers, since neither nfsdcltrack nor the legacy client tracking
> code work in containers.  These patches un-deprecate the use of nfsdcld
> for NFSv4 client tracking.
> 
> These patches are intended to go alongside some nfs-utils patches that
> introduce an enhancement that allows nfsd to "slurp" up the client
> records during client tracking initialization and store them internally
> in hash table.  This enables nfsd to check whether an NFSv4 client is 
> allowed to reclaim without having to do an upcall to nfsdcld.  It also
> allows nfsd to decide to end the v4 grace period early if the number of
> RECLAIM_COMPLETE operations it has received from "known" clients is
> equal to the number of entries in the hash table.  It also allows nfsd
> to skip the v4 grace period altogether if it knows there are no clients
> allowed to reclaim.
> 
> There is a fallback to allow nfsd to continue to work with older nfsdcld
> daemons in the event that any are out in the wild (unlikely).
> Everything should work fine except nfsd will not be able to exit the
> grace period early or skip the grace period altogether.
> 
> Scott Mayhew (4):
>   nfsd: fix a warning in __cld_pipe_upcall()
>   nfsd: make nfs4_client_reclaim use an xdr_netobj instead of a fixed
>     char array
>   nfsd: un-deprecate nfsdcld
>   nfsd: keep a tally of RECLAIM_COMPLETE operations when using nfsdcld
> 
>  fs/nfsd/netns.h               |   3 +
>  fs/nfsd/nfs4recover.c         | 326 ++++++++++++++++++++++++++++++----
>  fs/nfsd/nfs4state.c           |  82 +++++++--
>  fs/nfsd/nfsctl.c              |   1 +
>  fs/nfsd/state.h               |   8 +-
>  include/uapi/linux/nfsd/cld.h |   1 +
>  6 files changed, 372 insertions(+), 49 deletions(-)
> 
> -- 
> 2.17.1
