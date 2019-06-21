Return-Path: <SRS0=dvvl=UU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02200C43613
	for <linux-nfs@archiver.kernel.org>; Fri, 21 Jun 2019 18:13:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D62F8208C3
	for <linux-nfs@archiver.kernel.org>; Fri, 21 Jun 2019 18:13:10 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726063AbfFUSNK (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 21 Jun 2019 14:13:10 -0400
Received: from fieldses.org ([173.255.197.46]:45178 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726034AbfFUSNK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 21 Jun 2019 14:13:10 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id DDB9F1C84; Fri, 21 Jun 2019 14:13:09 -0400 (EDT)
Date:   Fri, 21 Jun 2019 14:13:09 -0400
To:     "J. Bruce Fields" <bfields@redhat.com>,
        Anna Schumaker <schumakeranna@gmail.com>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/16] exposing knfsd client state to userspace
Message-ID: <20190621181309.GD25590@fieldses.org>
References: <1561042275-12723-1-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1561042275-12723-1-git-send-email-bfields@redhat.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Jun 20, 2019 at 10:50:59AM -0400, J. Bruce Fields wrote:
> 	- this duplicates some functionality of the little-used fault
> 	  injection code; could we replace it entirely?

I'd be really curious to hear from any users of that code, by the way.
Anna, any ideas?

The idea was that it could be used to test client handling of
exceptional conditions like recalled delegations and partially lost
state.  Is anyone regularly running such tests?

I don't hate the code, and I'm not on a crusade to tear it all out Right
Now, but it does create a few odd corner cases, so I'm wondering whether
I could get away with replacing it eventually or whether that risks
breaking someone's scripts.

--b.
