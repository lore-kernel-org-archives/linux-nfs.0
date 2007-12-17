From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 01/38] svc: Add an svc transport class
Date: Mon, 17 Dec 2007 12:45:35 -0500
Message-ID: <20071217174535.GA13515@fieldses.org>
References: <20071213184506.GA29496@fieldses.org> <C38BA039.233C0%tom@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NeilBrown <neilb@suse.de>, linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:57401 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754902AbXLQRpi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Dec 2007 12:45:38 -0500
In-Reply-To: <C38BA039.233C0%tom@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 17, 2007 at 03:40:41AM -0600, Tom Tucker wrote:
> 
> 
> 
> On 12/13/07 12:45 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > Sorry for joining in a little late....
> > 
> > On Tue, Dec 11, 2007 at 05:31:54PM -0600, Tom Tucker wrote:
> >> +int svc_reg_xprt_class(struct svc_xprt_class *xcl)
> > 
> > None of the callers appear to check the return value, so this should
> > probably be a void return.
> >
> 
> I don't feel strongly about this, but what I was trying to catch was two
> different transports accidentally colliding on the same name. I doubt there
> will be a run on new transports, but it would at least fail the module load
> with a reasonable error.

Sounds fine.

Thanks!--b.
