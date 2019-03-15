Return-Path: <SRS0=RY80=RS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 170EFC43381
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 20:49:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CE588218A1
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 20:49:00 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726511AbfCOUtA (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Mar 2019 16:49:00 -0400
Received: from fieldses.org ([173.255.197.46]:33888 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725990AbfCOUtA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Mar 2019 16:49:00 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 4F9BA1C83; Fri, 15 Mar 2019 16:48:59 -0400 (EDT)
Date:   Fri, 15 Mar 2019 16:48:59 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Scott Mayhew <smayhew@redhat.com>
Cc:     jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [pynfs PATCH 1/4] nfs4.1: add some reboot tests
Message-ID: <20190315204859.GB13567@fieldses.org>
References: <20190314211210.7454-1-smayhew@redhat.com>
 <20190314211210.7454-2-smayhew@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190314211210.7454-2-smayhew@redhat.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Mar 14, 2019 at 05:12:07PM -0400, Scott Mayhew wrote:
> +def testRebootWithManyManyManyClients(t, env):
> +    """Reboot with many many many clients
> +
> +    FLAGS: reboot
> +    CODE: REBT2c
> +    """
> +    return doTestRebootWithNClients(t, env, 1000)

My test server uses a 15 second lease time, mainly just to speed up
tests.  That's not enough for pynfs to send out reclaims for 1000
clients.

So I'm wondering whether that's a reasonable test or not.

On the one hand, we should be able to handle 1000 clients, and a 15
second lease is probably unrealistically short.  And maybe we could
choose more patient behavior for the server (currently it will wait at
most 2 grace periods while reclaims continue to arrive).

On the other hand, real clients will send their reclaims simultaneously
rather than one at a time.  And from a trace it looks like most of the
time's spent waiting for pynfs to send the next request rather than
waiting for replies.  So this is a bit unusual.

I'm inclined to drop the "many many many clients" tests.  It's easy
enough for someone doing reboot testing to patch the tests if they need
to.

By the way, the longest round trip time I see is the RECLAIM_COMPLETE.
I assume that's doing a commit to disk.  It looks like there's nothing
on the server to prevent processing RECLAIM_COMPLETEs in parallel so as
long as that's true I suppose we're OK.

--b.
