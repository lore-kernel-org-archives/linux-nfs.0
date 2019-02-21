Return-Path: <SRS0=V3X6=Q4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6020CC43381
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Feb 2019 04:18:22 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 32FA62070B
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Feb 2019 04:18:22 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726592AbfBUESV (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 20 Feb 2019 23:18:21 -0500
Received: from fieldses.org ([173.255.197.46]:50252 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726181AbfBUESV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 20 Feb 2019 23:18:21 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id E9179189; Wed, 20 Feb 2019 23:18:20 -0500 (EST)
Date:   Wed, 20 Feb 2019 23:18:20 -0500
To:     James Pearson <jcpearson@gmail.com>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: nfsd thread limit and UDP ?
Message-ID: <20190221041820.GA4625@fieldses.org>
References: <CAK3fRr9EL-YOp3yUr5tMe5zuiERxHjkLDhAaWkxxEHjtfSwisQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAK3fRr9EL-YOp3yUr5tMe5zuiERxHjkLDhAaWkxxEHjtfSwisQ@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Feb 20, 2019 at 11:28:53AM +0000, James Pearson wrote:
> On a very busy NFSv3 server (running CentOS 6), we recently upped the
> nfsd thread count to 1024 - but this caused client mount requests over
> UDP to fail.
> 
> We configure all our clients to use TCP for NFS mounts, but the
> automounter (automountd) on MacOS (up to version MacOS 10.12) seeds a
> 'null call' to the NFS server over UDP before attempting the mount -
> but the server appears to ignore any UDP requests - and the automount
> fails

By the way, you might also just turn off UDP.  (Start run rpc.nfsd with
the -U option.)  Hopefully MacOS can handle that case.

--b.

> 
> I can also reproduce the issue on a Linux client via:
> 
>  mount -o udp,nfsvers=3 server:/export /mount/point
> 
> I've found, by trial and error, that the maximum number of nfsd
> threads that can be run on the server is 1017 before UDP mount
> requests fail
> 
> Running tcpdump on the server shows the UDP requests from the client,
> but the server never replies
> 
> It looks like more recent versions of MacOS will do its test 'null
> call' over TCP - so that is one 'solution' to this issue
> 
> However, I'm interested to know if we're hitting some hard limit, or
> if there are any settings we can tweak that could mitigate the
> problem?
> 
> Thanks
> 
> James Pearson
