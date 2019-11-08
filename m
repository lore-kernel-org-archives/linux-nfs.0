Return-Path: <SRS0=c9+N=ZA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6AB0C5DF60
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Nov 2019 17:15:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B3632206BA
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Nov 2019 17:15:14 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726819AbfKHRPO (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 8 Nov 2019 12:15:14 -0500
Received: from fieldses.org ([173.255.197.46]:36412 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726049AbfKHRPO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 8 Nov 2019 12:15:14 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 9779C1CE6; Fri,  8 Nov 2019 12:15:13 -0500 (EST)
Date:   Fri, 8 Nov 2019 12:15:13 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Olga Kornievskaia <aglo@umich.edu>
Cc:     Samy Ascha <samy@ascha.org>, linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: Specific IP per mounted share from same server
Message-ID: <20191108171513.GB31528@fieldses.org>
References: <5DBD272A-0D55-4D74-B201-431D04878B43@ascha.org>
 <CAN-5tyF7F4Mc8Z-bwg+Rq-ok50mchyF+X24oE8_MZzVy8LRCmw@mail.gmail.com>
 <20191108162927.GA31528@fieldses.org>
 <CAN-5tyGvLHJ2SJ2M56Ob3WRbbiG2-T1QYabgYY0EzbNB4h5DBg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAN-5tyGvLHJ2SJ2M56Ob3WRbbiG2-T1QYabgYY0EzbNB4h5DBg@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Nov 08, 2019 at 12:06:00PM -0500, Olga Kornievskaia wrote:
> On Fri, Nov 8, 2019 at 11:29 AM J. Bruce Fields <bfields@fieldses.org> wrote:
> >
> > On Fri, Nov 08, 2019 at 11:09:10AM -0500, Olga Kornievskaia wrote:
> > > Are you going against a linux server? I don't think linux server has
> > > the functionality you are looking for. What you are really looking for
> > > I believe is session trunking and neither the linux client nor server
> > > fully support that (though we plan to add that functionality in the
> > > near future).  Bruce, correct me if I'm wrong but linux server doesn't
> > > support multi-home (multi-node?)
> >
> >
> > The server should have complete support for session and clientid
> > trunking and multi-homing.  But I think we're just using those words in
> > slightly different ways:
> 
> By the full support, I mean neither client not server support trunking
> discovery unless that sneaked in when I wasn't looking. That was the
> piece that I knew needed to be done for sure.

I'd also say that the client supports trunking discovery--in a way,
that's the source of the problem here.  The client is probing and
discovering that the two IP addresses point to the same server, and
using that information to share the same connection.  That's trunking
discovery, to my understanding.

> When you say it fully support trunking do you mean it when each nfsd
> node runs in its own container, right?

No, I mean that we support a client using multiple sessions (clientid
trunking), or multiple connections per session (session trunking).

> Otherwise, I thought more code would be needed to support the case
> presented here. nfsd would need to have a notion of running something
> like a cluster node on a particular interface and distinguish between
> requests coming from different interface and act accordingly?

I guess it'd be possible to do something like that.  For now we don't
have any plans outside of the namespace/container work.  I wouldn't call
that trunking support.

But I think we agree on what's actually supported and not supported
here, we just disagree about the meanings of words like "trunking
support".

> Client can and will do trunking in case of pNFS to the data servers if
> the server presents multiple IPs. Otherwise, we just have nconnect
> feature but that doesn't split traffic between different network
> paths.

Got it, thanks.

--b.
