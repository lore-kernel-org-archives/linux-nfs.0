Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48595 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751986Ab1IZWgo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Sep 2011 18:36:44 -0400
Date: Mon, 26 Sep 2011 18:36:43 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/25] nfsd4 state cleanup
Message-ID: <20110926223643.GA22140@fieldses.org>
References: <1316000721-3289-1-git-send-email-bfields@redhat.com>
 <20110919131415.GB32498@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110919131415.GB32498@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Sep 19, 2011 at 09:14:16AM -0400, bfields wrote:
> On Wed, Sep 14, 2011 at 07:44:56AM -0400, J. Bruce Fields wrote:
> > This is just another batch of little cleanups and bugfixes to the nfsd4
> > state code.
> > 
> > What I'm actually thinking I'd like to do next is change the way
> > stateid's are composed to make it possible to look up the client first.
> > Once the client's looked up, lookup of the individual stateid, and most
> > of the following work, looks to me like it could be done under a
> > per-client lock.  The set of clients doesn't change very much so we
> > could use locking that favors readers (maybe rcu) for that part.  So
> > that could be a first step towards saner locking.
> > 
> > And then also still to do:
> > 	- close replays: we keep around a stateid to handle close
> > 	  replays only in the case where it's the last stateid for an
> > 	  openowner, but that's not sufficient.
> 
> A fix for this follows.

(Committed for 3.2).--b.
