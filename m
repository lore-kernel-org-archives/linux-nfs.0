Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF9C8C43619
	for <linux-nfs@archiver.kernel.org>; Thu,  4 Mar 2021 00:30:18 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id B5D5364EDF
	for <linux-nfs@archiver.kernel.org>; Thu,  4 Mar 2021 00:30:18 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1383820AbhCDA34 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 3 Mar 2021 19:29:56 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:47984 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S234218AbhCCWHF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Mar 2021 17:07:05 -0500
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 99B0BC061762
        for <linux-nfs@vger.kernel.org>; Wed,  3 Mar 2021 13:54:16 -0800 (PST)
Received: by fieldses.org (Postfix, from userid 2815)
        id 67EA62501; Wed,  3 Mar 2021 16:54:15 -0500 (EST)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 67EA62501
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1614808455;
        bh=ri7s28idYapONB9zU07hgPQ8M9PhnxzUEcb/M2L7ij4=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=RjgaSLkOM69M/24hSLcQ3tzeS62UPSAUgkc7WPpxibHYbPfbaDABsGGMITfLjuD+t
         9Gn7Gho99PTP9neWILx7gIU0MZ4iJn/txnCngqYRDetMgUCg3/V4UsHRmn0zQxEIZj
         0dkEimcyaj4gdGft+p5d73d7pgqdA0DOhemN5dUk=
Date:   Wed, 3 Mar 2021 16:54:15 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Steve Dickson <SteveD@RedHat.com>
Cc:     Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/7 V4] The NFSv4 only mounting daemon.
Message-ID: <20210303215415.GE3949@fieldses.org>
References: <20210219200815.792667-1-steved@redhat.com>
 <20210224203053.GF11591@fieldses.org>
 <1553fb2d-9b8e-f8eb-8c72-edcd14a2ad08@RedHat.com>
 <20210303152342.GA1282@fieldses.org>
 <376b6b0a-5679-4692-cfdb-b8c7919393a5@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <376b6b0a-5679-4692-cfdb-b8c7919393a5@RedHat.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Mar 03, 2021 at 04:22:28PM -0500, Steve Dickson wrote:
> Hey!
> 
> On 3/3/21 10:23 AM, J. Bruce Fields wrote:
> > On Tue, Mar 02, 2021 at 05:33:23PM -0500, Steve Dickson wrote:
> >>
> >>
> >> On 2/24/21 3:30 PM, J. Bruce Fields wrote:
> >>> On Fri, Feb 19, 2021 at 03:08:08PM -0500, Steve Dickson wrote:
> >>>> nfsv4.exportd is a daemon that will listen for only v4 mount upcalls.
> >>>> The idea is to allow distros to build a v4 only package
> >>>> which will have a much smaller footprint than the
> >>>> entire nfs-utils package.
> >>>>
> >>>> exportd uses no RPC code, which means none of the 
> >>>> code or arguments that deal with v3 was ported, 
> >>>> this again, makes the footprint much smaller. 
> >>>
> >>> How much smaller?
> >> Will a bit smaller... but a number of daemons like nfsd[cld,clddb,cldnts]
> >> need to also come a long. 
> > 
> > Could we get some numbers?
> > 
> > Looks like nfs-utils in F33 is about 1.2M:
> > 
> > $ rpm -qi nfs-utils|grep ^Size
> > Size        : 1243512
> > 
> > $ strip utils/mountd/mountd
> > $ ls -lh utils/mountd/mountd
> > -rwxrwxr-x. 1 bfields bfields 128K Mar  3 10:12 utils/mountd/mountd
> > $ strip utils/exportd/exportd
> > $ ls -lh utils/exportd/exportd
> > -rwxrwxr-x. 1 bfields bfields 106K Mar  3 10:12 utils/exportd/exportd
> > 
> > So replacing mountd by exportd saves us about 20K out of 1.2M.  Is it
> > worth it?
> In smaller foot print I guess I meant no v3 daemons, esp rpcbind. 

The rpcbind rpm is 120K installed, so if the new v4-only rpm has no
dependency on rpcbind then we save 120K.

So, for stuff needed in both v4-only and full cases, would we package
that in a common rpm that they both depend on?

--b.
