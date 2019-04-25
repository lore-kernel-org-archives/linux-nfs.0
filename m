Return-Path: <SRS0=LIrp=S3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 66D52C43218
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Apr 2019 16:45:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CC20F206BF
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Apr 2019 16:45:01 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726514AbfDYQpA (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Apr 2019 12:45:00 -0400
Received: from fieldses.org ([173.255.197.46]:51202 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726071AbfDYQpA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 25 Apr 2019 12:45:00 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 1B2431C83; Thu, 25 Apr 2019 12:45:00 -0400 (EDT)
Date:   Thu, 25 Apr 2019 12:45:00 -0400
From:   "bfields@fieldses.org" <bfields@fieldses.org>
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Anna.Schumaker@netapp.com" <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH 6/9] NFSv4: Convert the NFS client idmapper to use the
 container user namespace
Message-ID: <20190425164500.GA9015@fieldses.org>
References: <20190424214650.4658-2-trond.myklebust@hammerspace.com>
 <20190424214650.4658-3-trond.myklebust@hammerspace.com>
 <20190424214650.4658-4-trond.myklebust@hammerspace.com>
 <20190424214650.4658-5-trond.myklebust@hammerspace.com>
 <20190424214650.4658-6-trond.myklebust@hammerspace.com>
 <20190424214650.4658-7-trond.myklebust@hammerspace.com>
 <20190425143243.GA8133@fieldses.org>
 <e94c2488d89ae13675f9931d013a3d711459ecad.camel@hammerspace.com>
 <20190425153339.GB8133@fieldses.org>
 <e3553fd56047430f171a3c285150b56d5fc69ccd.camel@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e3553fd56047430f171a3c285150b56d5fc69ccd.camel@hammerspace.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Apr 25, 2019 at 04:40:18PM +0000, Trond Myklebust wrote:
> On Thu, 2019-04-25 at 11:33 -0400, bfields@fieldses.org wrote:
> > On Thu, Apr 25, 2019 at 03:00:22PM +0000, Trond Myklebust wrote:
> > > The assumption is that if you have enough privileges to mount a
> > > filesystem using the NFS client, then you would also have enough
> > > privileges to run a userspace client, so there is little point in
> > > restricting the NFS client.
> > > 
> > > So the guiding principle is that a NFS client mount that is started
> > > in
> > > a container should behave as if it were started by a process in a
> > > "real
> > > VM". That means that the root uid/gid in the container maps to a
> > > root
> > > uid/gid on the wire.
> > > Ditto, if there is a need to run the idmapper in the container,
> > > then
> > > the expectation is that processes running as 'user' with uid 'u',
> > > will
> > > see their creds mapped correctly by the idmapper. Again, that's
> > > what
> > > you would see if the process were running in a VM instead of a
> > > container.
> > > 
> > > Does that all make sense?
> > 
> > Yes, thanks!
> > 
> > I thought there was a problem that the idmapper depended on
> > keyring usermodehelper calls that it was hard to pass namespace
> > information to.  Did that get fixed and I missed it or or forgot?
> 
> No, you are correct, and so we assume the container is using rpc.idmapd
> (and rpc.gssd) if it is running NFSv4 with RPCSEC_GSS.
> 
> If the keyring upcall gets fixed, then we may allow it to be used in
> future kernels.

OK, got it.  Is there anything we lose by using idmapd?  (IDMAP_NAMESZ
might be a limitation?)

--b.
