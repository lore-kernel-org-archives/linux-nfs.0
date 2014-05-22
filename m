Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34155 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751473AbaEVTSH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 May 2014 15:18:07 -0400
Date: Thu, 22 May 2014 15:17:50 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: nfsd4 xdr encoding fixes v2
Message-ID: <20140522191750.GA25423@fieldses.org>
References: <1399841568-19716-1-git-send-email-bfields@redhat.com>
 <20140512082059.GC14194@infradead.org>
 <20140512160740.GE2633@pad.redhat.com>
 <20140512161128.GA1591@infradead.org>
 <20140513110945.GA9461@infradead.org>
 <20140513144826.GB17206@pad.redhat.com>
 <20140513211841.GF5222@fieldses.org>
 <20140513213321.GG5222@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140513213321.GG5222@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 13, 2014 at 05:33:21PM -0400, J. Bruce Fields wrote:
> On Tue, May 13, 2014 at 05:18:41PM -0400, bfields wrote:
> > On Tue, May 13, 2014 at 10:48:26AM -0400, J. Bruce Fields wrote:
> > > On Tue, May 13, 2014 at 04:09:45AM -0700, Christoph Hellwig wrote:
> > > > On Mon, May 12, 2014 at 09:11:28AM -0700, Christoph Hellwig wrote:
> > > > > On Mon, May 12, 2014 at 12:07:41PM -0400, J. Bruce Fields wrote:
> > > > > > On Mon, May 12, 2014 at 01:20:59AM -0700, Christoph Hellwig wrote:
> > > > > > > This series seem to cause hangs during xfstests against a server on the
> > > > > > > same VM.  The trace is fairly similar every the hang happens, but the
> > > > > > > point at which it happens differs:
> > > > > > 
> > > > > > Ouch, OK, and you're sure it starts with this series?
> > > > > > 
> > > > > > I guess I should try to replicate it here.  Might take a copule days.
> > > > 
> > > > Seems lile "nfsd4: allow exotic read compounds" is the culprit.
> > > 
> > > OK, it makes sense that the problem would be there.  Looking....
> > 
> > I got xfstests set up and can reproduce some problems (a hang, the
> > nfs4svc_encode_compoundres WARN, and some allocation failures), though
> > not exactly what you reported.
> > 
> > I also notice that commit ("nfsd4: allow exotic read compounds") has a
> > lot of extraneous cleanup that I should split out.
> 
> In fact, the change to handle multiple reads per compound *should* only
> affect the nfsd4_encode_readv() case.  Whereas you're probably
> exercising only the nfsd4_encode_splice_read() case.  So probably some
> of the extraneous cleanup in that patch is bogus.

Yes, this removal:

	-	xdr->page_ptr += (maxcount + PAGE_SIZE - 1) / PAGE_SIZE;

buried in that cleanup is bogus and seems like it could result in
freeing a page twice.  I've fixed that and split the confusing "cleanup"
out into separate patches.  I can't get any hangs by running xfstests
any more.

On the other hand, I never saw exactly what you did, so more testing
wouldn't hurt.

I'll send out a v3 soon.

--b.
