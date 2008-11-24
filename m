From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] svcsock: Add a reference to sunrpc in svc_addsock
Date: Mon, 24 Nov 2008 14:27:04 -0500
Message-ID: <20081124192704.GA13323@fieldses.org>
References: <1227449316-27946-1-git-send-email-tom@opengridcomputing.com> <x491vx1f8o9.fsf@segfault.boston.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Tucker <tom@opengridcomputing.com>, jlayton@redhat.com,
	linux-nfs@vger.kernel.org
To: Jeff Moyer <jmoyer@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:50980 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750890AbYKXT1I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Nov 2008 14:27:08 -0500
In-Reply-To: <x491vx1f8o9.fsf-RRHT56Q3PSP4kTEheFKJxxDDeQx5vsVwAInAS/Ez/D0@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 24, 2008 at 10:25:10AM -0500, Jeff Moyer wrote:
> Tom Tucker <tom@opengridcomputing.com> writes:
> 
> > The svc_addsock function adds transport instances without taking a
> > reference on the sunrpc.ko module, however, the generic transport
> > destruction code drops a reference when a transport instance
> > is destroyed.
> >
> > Add a try_module_get call to the svc_addsock function for transport
> > instances added by this function.
> >
> > Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> Tested-by: Jeff Moyer <jmoyer@redhat.com>

Done, thanks.--b.
