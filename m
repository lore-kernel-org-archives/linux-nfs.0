Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:44907 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752526Ab1IZWoU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Sep 2011 18:44:20 -0400
Date: Mon, 26 Sep 2011 18:44:20 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org, Fred Isaman <faisaman4@gmail.com>
Subject: Re: [PATCH 00/25] nfsd4 state cleanup
Message-ID: <20110926224420.GC22140@fieldses.org>
References: <1316000721-3289-1-git-send-email-bfields@redhat.com>
 <20110919131415.GB32498@fieldses.org>
 <20110926223643.GA22140@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110926223643.GA22140@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Sep 26, 2011 at 06:36:43PM -0400, J. Bruce Fields wrote:
> On Mon, Sep 19, 2011 at 09:14:16AM -0400, bfields wrote:
> > On Wed, Sep 14, 2011 at 07:44:56AM -0400, J. Bruce Fields wrote:
> > > And then also still to do:
> > > 	- close replays: we keep around a stateid to handle close
> > > 	  replays only in the case where it's the last stateid for an
> > > 	  openowner, but that's not sufficient.
> > 
> > A fix for this follows.
> 
> (Committed for 3.2).--b.

And also I should have said, I've added more pynfs tests, including a
test for this, and some additional tests for conflicts between read
delegations and server-side operations, to:

	git://linux-nfs.org/~bfields/pynfs.git

--b.
