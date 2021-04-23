Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3B5EC433ED
	for <linux-nfs@archiver.kernel.org>; Fri, 23 Apr 2021 20:37:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 9857B613C1
	for <linux-nfs@archiver.kernel.org>; Fri, 23 Apr 2021 20:37:11 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S243932AbhDWUhq (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 23 Apr 2021 16:37:46 -0400
Received: from mx2.suse.de ([195.135.220.15]:60420 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S232689AbhDWUhl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 23 Apr 2021 16:37:41 -0400
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.221.27])
        by mx2.suse.de (Postfix) with ESMTP id 26741B035;
        Fri, 23 Apr 2021 20:37:04 +0000 (UTC)
Date:   Fri, 23 Apr 2021 22:37:02 +0200
From:   Petr Vorel <pvorel@suse.cz>
To:     "J . Bruce Fields" <bfields@fieldses.org>
Cc:     linux-nfs@vger.kernel.org, Steve Dickson <steved@redhat.com>,
        NeilBrown <neilb@suse.com>, Chuck Lever <chuck.lever@oracle.com>,
        Alexey Kodanev <alexey.kodanev@oracle.com>
Subject: Re: [RFC PATCH 1/1] mount.nfs: Fix mounting on tmpfs
Message-ID: <YIMv7rkwvJcSrFOP@pevik>
Reply-To: Petr Vorel <pvorel@suse.cz>
References: <20210422191803.31511-1-pvorel@suse.cz>
 <20210422202334.GB25415@fieldses.org>
 <YIIuUPrlbBlr1ooD@pevik>
 <20210423142329.GB10457@fieldses.org>
 <YIL+KWuPmgm8A82C@pevik>
 <20210423181345.GE10457@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20210423181345.GE10457@fieldses.org>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

> On Fri, Apr 23, 2021 at 07:04:41PM +0200, Petr Vorel wrote:
> > Hi Bruce,

> > > On Fri, Apr 23, 2021 at 04:17:52AM +0200, Petr Vorel wrote:
> > > > Hi,

> > > > > On Thu, Apr 22, 2021 at 09:18:03PM +0200, Petr Vorel wrote:
> > > > > > LTP NFS tests (which use netns) fails on tmpfs since d4066486:

> > > > > > mount -t nfs -o proto=tcp,vers=4.2 10.0.0.2:/tmp/ltp.nfs01.nfs-4.2/LTP_nfs01.UF6gRZCy3O/4.2/tcp /tmp/ltp.nfs01.nfs-4.2/LTP_nfs01.UF6gRZCy3O/4.2/0
> > > > > > mount.nfs: mounting 10.0.0.2:/tmp/ltp.nfs01.nfs-4.2/LTP_nfs01.UF6gRZCy3O/4.2/tcp failed, reason given by server: No such file or directory

> > > > > We should figure out the reason for the failure.  A network trace might
> > > > > help.

> > > > Anything specific you're looking for?

> > > Actually I was thinking of capturing the network traffic, something
> > > like:
> > > 	tcpdump -s0 -wtmp.pcap -i<interface>

> > > then try the mount, then kill tcpdump and look at tmp.pcap.

> > I don't see anything suspicious, can you please have a look?
> > https://gitlab.com/pevik/tmp/-/raw/master/nfs.v3.pcap
> > https://gitlab.com/pevik/tmp/-/raw/master/nfs.v4.pcap
> > https://gitlab.com/pevik/tmp/-/raw/master/nfs.v4.1.pcap
> > https://gitlab.com/pevik/tmp/-/raw/master/nfs.v4.2.pcap

> It might be the "hide" option, that's odd:

> > exportfs -v
> > /tmp/LTP_nfs01.xkKpqpRikV/4.2/tcp
> > 		<world>(sync,wdelay,hide,no_subtree_check,fsid=7239,sec=sys,rw,secure,no_root_squash,no_all_squash)

NOTE: hide is also in v3, which is working.

I can provide you even setup. I thought it's related to mount.nfs change (I
tested it on openSUSE and Debian, with various kernel versions), but the real
cause might be in kernel or elsewhere.

Kind regards,
Petr

> --b.
