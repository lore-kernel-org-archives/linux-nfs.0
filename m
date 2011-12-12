Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36803 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752990Ab1LLWoL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Dec 2011 17:44:11 -0500
Date: Mon, 12 Dec 2011 17:44:10 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] client: test OPEN+WRITE+CLOSE in a single compound
Message-ID: <20111212224410.GE22927@fieldses.org>
References: <1323721588-8259-1-git-send-email-tigran.mkrtchyan@desy.de>
 <20111212224219.GC22927@fieldses.org>
 <20111212224300.GD22927@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111212224300.GD22927@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 12, 2011 at 05:43:00PM -0500, J. Bruce Fields wrote:
> On Mon, Dec 12, 2011 at 05:42:19PM -0500, J. Bruce Fields wrote:
> > I already applied some previous version of these--could you check
> > 
> > 	git://linux-nfs.org/~bfields/pynfs.git
> > 
> > and let me know if I got anything wrong?  (If so, incremental patches on
> > top of that would be appreciated.
> 
> Oh, sorry, I missed that you're adding the IO.  OK.--b.

All applied and pushed out now, thanks again.--b.
