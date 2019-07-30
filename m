Return-Path: <SRS0=Ztr/=V3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E2D0C0650F
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Jul 2019 15:51:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0C460204FD
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Jul 2019 15:51:23 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1732645AbfG3PvX (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 30 Jul 2019 11:51:23 -0400
Received: from fieldses.org ([173.255.197.46]:41508 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725974AbfG3PvX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 30 Jul 2019 11:51:23 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id A51082010; Tue, 30 Jul 2019 11:51:22 -0400 (EDT)
Date:   Tue, 30 Jul 2019 11:51:22 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v4 1/8] NFSD fill-in netloc4 structure
Message-ID: <20190730155122.GD31707@fieldses.org>
References: <20190708192352.12614-1-olga.kornievskaia@gmail.com>
 <20190708192352.12614-2-olga.kornievskaia@gmail.com>
 <20190717211317.GM24608@fieldses.org>
 <CAN-5tyHxY0YPoXwK0pVudfH3n9SiNwzmYOywzmtpYSHFZkH23Q@mail.gmail.com>
 <CAN-5tyHD4ms1b9udXb8cXKC+N0vZbpmG7cb_TmnB9GTLoOr45g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAN-5tyHD4ms1b9udXb8cXKC+N0vZbpmG7cb_TmnB9GTLoOr45g@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Jul 30, 2019 at 11:48:40AM -0400, Olga Kornievskaia wrote:
> Ok I'd like argue for the code to stay as is because
> 1. can't move the whole function into addr.c because it created a data
> structure (nfs42_netaddr) that rpc knows nothing about
> 2. While the nfs42_netaddr->addr is the output of the rpc_sock2uaddr()
> but we still need the switch to populate the netid . Also since
> rpc_sock2uaddr returns memory than the nfs42_netaddr data structure
> needs to change to store pointers (and that's shared with the client).
> Thus client and server would need to add other code to free the
> created netaddr.
> 3. this function as is can be used by the flexfile layout as well
> (they also decided not to share code with rpc_sockaddr2uaddr but use
> same content). that function also doesn't want the memory to be
> allocated.
> 
> Maybe I'm wrong about all of it and it all needs to be re-written to
> take dynamic memory. But to use as is I don't want to call it and then
> memcpy into existing static buffers and freeing what
> rpc_sockaddr2uaddr has allocated.

OK, that's fine.

--b.
