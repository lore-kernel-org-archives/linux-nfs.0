Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58846 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932982Ab1JYMeu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Oct 2011 08:34:50 -0400
Received: from bfields by fieldses.org with local (Exim 4.72)
	(envelope-from <bfields@fieldses.org>)
	id 1RIgDR-00048c-Ig
	for linux-nfs@vger.kernel.org; Tue, 25 Oct 2011 08:34:49 -0400
Date: Tue, 25 Oct 2011 08:34:49 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: linux-nfs@vger.kernel.org
Subject: Re: nfsd (and lock) changes for 3.2
Message-ID: <20111025123449.GB15662@fieldses.org>
References: <20111025121924.GA15662@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111025121924.GA15662@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 25, 2011 at 08:19:24AM -0400, bfields wrote:
> 	- Progress on the basic 4.1 todo's.  Thanks in particular to Mi
> 	  Jinlong for (among other things) implementing the somewhat
> 	  tricky DRC limit checking.
> 
> 	  The 4.1 code is getting closer--it *might* be possible to
> 	  finish basic 4.1 early as 3.3, at which point we could start
> 	  on optional features (like pNFS).  But that will depend on
> 	  people sending patches (and pynfs tests) for the remaining 4.1
> 	  todo's.

I've been keeping the todo list up to date here:

	http://wiki.linux-nfs.org/wiki/index.php/Server_4.0_and_4.1_issues

Some of them I think are relatively straightforward--probably anyone
with a little time could dive into them:

	- SEQ4_STATUS_RECALLABLE_STATE_REVOKED

	- backchannel attribute negotiation

	- ACL retention bits

	- Clarify RDMA non-support

Slightly trickier or open-ended; we may need to talk over design first
before diving in:

	- Make DESTROY_SESSION wait on in-progress requests

	- current stateid

	- Check 4.0/4.1 interactions

	- Callback failure handling

	- GSS

The GSS piece is probably the one I'm most worried about.  What we have
seems sufficient for current clients, but I know it's incomplete, and
I'm not entirely clear how much work it is to implement the minimum
required to ensure that future kerberos-using clients won't break
unexpectedly on upgrade to 4.1.

--b.
