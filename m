Return-Path: <SRS0=1vu2=WX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5721C3A5A3
	for <linux-nfs@archiver.kernel.org>; Tue, 27 Aug 2019 15:00:43 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 93E2A20828
	for <linux-nfs@archiver.kernel.org>; Tue, 27 Aug 2019 15:00:43 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726140AbfH0PAm (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 27 Aug 2019 11:00:42 -0400
Received: from fieldses.org ([173.255.197.46]:47792 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725987AbfH0PAm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 27 Aug 2019 11:00:42 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 6F3A01CB4; Tue, 27 Aug 2019 11:00:42 -0400 (EDT)
Date:   Tue, 27 Aug 2019 11:00:42 -0400
From:   "bfields@fieldses.org" <bfields@fieldses.org>
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        "jlayton@redhat.com" <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "bfields@redhat.com" <bfields@redhat.com>,
        "jlayton@poochiereds.net" <jlayton@poochiereds.net>
Subject: Re: [PATCH 0/3] Handling NFSv3 I/O errors in knfsd
Message-ID: <20190827150042.GD9804@fieldses.org>
References: <20190826165021.81075-1-trond.myklebust@hammerspace.com>
 <20190826205156.GA27834@fieldses.org>
 <ef9f2791ef395d7c968a386ce0a32ea503d6478f.camel@hammerspace.com>
 <61F77AD6-BD02-4322-B944-0DC263EB9BD8@oracle.com>
 <20190827145456.GA9804@fieldses.org>
 <5e9d8bceb67d20f6e89f81cb7f2a4eca5e842bcf.camel@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5e9d8bceb67d20f6e89f81cb7f2a4eca5e842bcf.camel@hammerspace.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Aug 27, 2019 at 02:59:34PM +0000, Trond Myklebust wrote:
> On Tue, 2019-08-27 at 10:54 -0400, Bruce Fields wrote:
> > On Tue, Aug 27, 2019 at 09:59:25AM -0400, Chuck Lever wrote:
> > > The strategy of handling these errors more carefully seems good.
> > > Bumping the write/commit verifier so the client writes again to
> > > retrieve the latent error is clever!
> > > 
> > > It's not clear to me though that the NFSv3 protocol can deal with
> > > the multi-client write scenario, since it is stateless. We are now
> > > making it stateful in some sense by preserving error state on the
> > > server across NFS requests, without having any sense of an open
> > > file in the protocol itself.
> > > 
> > > Would an "approximation" without open state be good enough?
> > 
> > I figure there's a correct-but-slow approach which is to increment
> > the
> > write verifier every time there's a write error.  Does that work?  If
> > write errors are rare enough, maybe it doesn't matter that that's
> > slow?
> 
> How is that different from changing the boot verifier?
> Are you
> proposing to track write verifiers on a per-client basis? That seems
> onerous too.

Sorry, I thought "write verifier" and "boot verifier" were synonyms,
and, no, wasn't suggesting tracking it per-file.

--b.

> > Then there's various approximations you could use (IP address?) to
> > guess
> > when only one client's accessing the file.  You save forcing all the
> > clients to resend writes at the expense of some complexity and
> > correctness--e.g., multiple clients behind NAT might not all get
> > write
> > errors.
> > 
> > Am I thinking aobut this right?
> 
> I agree that there are multiple problems with tracking on a per-client
> basis.
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer, Hammerspace
> trond.myklebust@hammerspace.com
> 
> 
