Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49993 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030264Ab2B1Tt1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Feb 2012 14:49:27 -0500
Date: Tue, 28 Feb 2012 14:49:26 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Daniel Kahn Gillmor <dkg@fifthhorseman.net>
Cc: linux-nfs@vger.kernel.org
Subject: Re: linux-image: on nfs4 server: RPC: AUTH_GSS upcall timed out
 Please check user daemon is running
Message-ID: <20120228194926.GB2723@fieldses.org>
References: <8762hrozdl.fsf@fifthhorseman.net>
 <20111208174501.GA30088@fieldses.org>
 <4EE253EC.2040609@fifthhorseman.net>
 <20111209191057.GA10089@fieldses.org>
 <87booq3xbd.fsf@pip.fifthhorseman.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87booq3xbd.fsf@pip.fifthhorseman.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 23, 2012 at 12:58:46AM -0500, Daniel Kahn Gillmor wrote:
> On Fri, 9 Dec 2011 14:10:57 -0500, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > On Fri, Dec 09, 2011 at 01:31:08PM -0500, Daniel Kahn Gillmor wrote:
> > > Thanks, that's useful.  Do the clients need to run cachefilesd as well
> > > to take advantage of delegation?
> > 
> > No.
> 
> Is there a way that i can check to be sure that delegations are actually
> happening?

On the client I suppose you'll eventually start seeing DELEG_RETURN
calls in /proc/self/mountstats.  On the server side the
nfsd4_delegations line of /proc/slabinfo should give a hint.

> What kind of performance improvement would you expect to see
> with delegatons happening on, say, a standard desktop user's homedir
> workload?

I don't know.  If you get any test results that would be interesting.

--b.
