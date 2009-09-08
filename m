From: Nick Piggin <npiggin@suse.de>
Subject: Re: Why doesn't zap_pte_range() call page_mkwrite()
Date: Tue, 8 Sep 2009 19:00:02 +0200
Message-ID: <20090908170002.GD29902@wotan.suse.de>
References: <E1Lx4yU-0007A8-Gl@pomaz-ex.szeredi.hu> <1240519320.5602.9.camel@heimdal.trondhjem.org> <E1LxFd4-0008Ih-Rd@pomaz-ex.szeredi.hu> <20090424104137.GA7601@sgi.com> <E1LxMlO-0000sU-1J@pomaz-ex.szeredi.hu> <1240592448.4946.35.camel@heimdal.trondhjem.org> <20090425051028.GC10088@wotan.suse.de> <20090908153007.GB2513@think> <20090908154132.GC29902@wotan.suse.de> <20090908163149.GB2975@think>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Chris Mason <chris.mason@oracle.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Miklos Szeredi <miklos@szeredi.hu>, holt@sgi.com,
	linux-nfs@vger.kernel.org, linux-fsdevel-u79uwXL29TY@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:36403 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751609AbZIHRAA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Sep 2009 13:00:00 -0400
In-Reply-To: <20090908163149.GB2975@think>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 08, 2009 at 12:31:49PM -0400, Chris Mason wrote:
> On Tue, Sep 08, 2009 at 05:41:32PM +0200, Nick Piggin wrote:
> > It hasn't fallen completely off my radar. fsblock has the same issue
> > (although I've just been ignoring gup writes into fsblock fs for the
> > time being).
> 
> Ok, I'll change my detection code a bit then.

OK.


> > I have a basic idea of what to do... It would be nice to change calling
> > convention of get_user_pages and take the page lock. Database people might
> > scream, in which case we could only take the page lock for filesystems that
> > define ->page_mkwrite (so shared mem segments avoid the overhead). Lock
> > ordering might get a bit interesting, but if we can have callers ensure they
> > always submit and release partially fulfilled requirests, then we can always
> > trylock them.
> 
> I think everyone will have page_mkwrite eventually, at least everyone
> who the databases will care about ;)

Ah, the problem is not where the DIO write goes, it's where the read
goes :) (ie. the read writes into get_user_pages pages).

So for databases this should typically be shared memory segments I'd
say (tmpfs), or maybe anonymous memory.

