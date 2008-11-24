From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: list corruption in locks_start_grace with 2.6.28-rc3
Date: Mon, 24 Nov 2008 11:16:30 -0500
Message-ID: <20081124161630.GD16852@fieldses.org>
References: <x498wrokjj8.fsf@segfault.boston.devel.redhat.com> <20081120203735.GB30808@fieldses.org> <x49ej15gktp.fsf@segfault.boston.devel.redhat.com> <20081122005400.GB28094@fieldses.org> <20081122092237.1ab81cdb@tleilax.poochiereds.net> <49287005.5050009@opengridcomputing.com> <49289B2D.1090404@opengridcomputing.com> <x49wsetdu24.fsf@segfault.boston.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Tucker <tom@opengridcomputing.com>,
	Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
To: Jeff Moyer <jmoyer@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:35204 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751920AbYKXQQd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Nov 2008 11:16:33 -0500
In-Reply-To: <x49wsetdu24.fsf-RRHT56Q3PSP4kTEheFKJxxDDeQx5vsVwAInAS/Ez/D0@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 24, 2008 at 10:26:11AM -0500, Jeff Moyer wrote:
> Tom Tucker <tom@opengridcomputing.com> writes:
> 
> > Jeff M/L:
> >
> > Could you guys confirm that this patch fixes the problem? I was able
> > to reproduce Jeff Layton's problem and this patch resolved
> > the under-reference condition for me.
> 
> With this patch and the one that Bruce posted, I no longer see any
> problems.  Bruce, you can add a Tested-by: Jeff Moyer
> <jmoyer@redhat.com> to your patch submission.
> 
> Thanks, guys!

Done, thanks!  Patches pending for 2.6.28 available from the for-2.6.28
branch at:

	git://linux-nfs.org/~bfields/linux.git for-2.6.28

--b.
