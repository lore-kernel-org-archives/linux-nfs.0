Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:34280 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752051Ab0LQDdC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Dec 2010 22:33:02 -0500
Subject: Re: [PATCH 00/31] NFS XDR clean up for 2.6.38
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Ric Wheeler <ricwheeler@gmail.com>, Steve Dickson <SteveD@redhat.com>,
        linux-nfs@vger.kernel.org
In-Reply-To: <20101216234058.GA17940@infradead.org>
References: <20101214144747.2293.68070.stgit@matisse.1015granger.net>
	 <4D0A6503.7010901@RedHat.com> <20101216230524.GA16760@infradead.org>
	 <4D0AA11A.2010307@gmail.com>  <20101216234058.GA17940@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 16 Dec 2010 22:32:44 -0500
Message-ID: <1292556764.2895.41.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-12-16 at 18:40 -0500, Christoph Hellwig wrote:
> On Thu, Dec 16, 2010 at 06:30:34PM -0500, Ric Wheeler wrote:
> > This has nothing to do with shame or conspiracy, it has to do with
> > doing changes in an orderly way so we can test and stabilize things
> > in the upstream kernel.
> > 
> > Changing both at once is not good for upstream or distros  in my opinion,
> 
> Steve's mail reads pretty different from that.
> 
> But it doesn't really matter as it doesn't make any sense - as Chuck
> has explained theres zero overlap between the XDR decoder changes and
> pnfs features anyway.  And if there was it's pretty clear something that
> the about 98% of the userbase that's using NFSv3 uses should have more
> priority over the 0.5% that are planning to maybe possibly use pnfs in
> the next decade.

Hi guys,

I agree 100% with the basic premise that we should not have to deal with
compatibility issues for NFSv4.1/pnfs backports when deciding what to
merge upstream.
That said: as far as I can see, pretty much all these changes are
confined to the NFSv2 and NFSv3 XDR code. I can quite understand why
distros like Red Hat, SuSE, Debian, and others might want to avoid
having to back port changes, given that the NFSv2 and NFSv3 code bases
are supposed to be fully stable and frozen.

So my questions to Steve and Ric are:

     1. Specifically, which part of these changes are causing
        backporting headaches for the RHEL-6 code base? Note that when
        asking that question I am assuming that Red Hat will triage and
        reject patches that conflict with their stability goals.
     2. Could we set up some minimal set of patches that would allow the
        pNFS backport while avoiding the need for a full backport of
        Chuck's patches for NFSv2/v3? If so, what features do we need,
        and what is not needed?

IOW: how can we refactor these patches so as to avoid tying the set of
NFSv2/v3 changes to any pNFS interests?

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

