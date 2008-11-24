From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: list corruption in locks_start_grace with 2.6.28-rc3
Date: Mon, 24 Nov 2008 10:26:11 -0500
Message-ID: <x49wsetdu24.fsf@segfault.boston.devel.redhat.com>
References: <x498wrokjj8.fsf@segfault.boston.devel.redhat.com>
	<20081120203735.GB30808@fieldses.org>
	<x49ej15gktp.fsf@segfault.boston.devel.redhat.com>
	<20081122005400.GB28094@fieldses.org>
	<20081122092237.1ab81cdb@tleilax.poochiereds.net>
	<49287005.5050009@opengridcomputing.com>
	<49289B2D.1090404@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Layton <jlayton@redhat.com>,
	"J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:55941 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751029AbYKXP0P (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Nov 2008 10:26:15 -0500
In-Reply-To: <49289B2D.1090404@opengridcomputing.com> (Tom Tucker's message of
	"Sat, 22 Nov 2008 17:52:13 -0600")
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tom Tucker <tom@opengridcomputing.com> writes:

> Jeff M/L:
>
> Could you guys confirm that this patch fixes the problem? I was able
> to reproduce Jeff Layton's problem and this patch resolved
> the under-reference condition for me.

With this patch and the one that Bruce posted, I no longer see any
problems.  Bruce, you can add a Tested-by: Jeff Moyer
<jmoyer@redhat.com> to your patch submission.

Thanks, guys!

Cheers,
Jeff
