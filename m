Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54055 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754434Ab2KZQYX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 11:24:23 -0500
Date: Mon, 26 Nov 2012 11:24:20 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org, ffilz@us.ibm.com,
        Fred Isaman <iisaman@netapp.com>
Subject: Re: fixes for 3.8
Message-ID: <20121126162420.GD11860@fieldses.org>
References: <1353940799-11763-1-git-send-email-bfields@redhat.com>
 <20121126154735.GA11860@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121126154735.GA11860@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 26, 2012 at 10:47:35AM -0500, bfields wrote:
> On Mon, Nov 26, 2012 at 09:39:51AM -0500, J. Bruce Fields wrote:
> > The following are some fixes I plan to queue up for 3.8, mostly problems
> > found while looking at the v4 xdr code.
> 
> I also added corresponding tests to
> 
> 	git://linux-nfs.org/~bfields/pynfs.git

There are also a few more commits there that weed out false positives
(or tests that look possibly technically correct but so trivial as to
not be worth complaining about).  In most cases the tests are still
there if you know the right tag to task for, they just aren't run by
default.  I think it's really important that we don't make people wade
through a lot of noise to get to the important failures.

Frank, could you check if you still get spurious warnings or failures
against Ganesha?

At this point, against a linux server,

  ./nfs4.0/testserver.py server:/dir --rundeps --maketree all

has 8 failures, of which 4 look like legitimate server bugs.  The
remaining 4 depend on who I'm running as: as root, some permissions
tests fail due to root bypassing access checks on mode-0 objects.  As a
regular user the special-device tests fail or can't run.  I don't have a
plan for those yet.

--b.
