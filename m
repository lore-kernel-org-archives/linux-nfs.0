From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/3] nfsd: don't try to shut down nfs4 state handling
	unless it's up
Date: Tue, 15 Jun 2010 13:36:28 -0400
Message-ID: <20100615173628.GA20757@fieldses.org>
References: <1275924800-5214-1-git-send-email-jlayton@redhat.com> <1275924800-5214-2-git-send-email-jlayton@redhat.com> <20100608235828.GK26435@fieldses.org> <20100609062922.4bae21ac@corrin.poochiereds.net> <20100609180907.GB10953@fieldses.org> <20100609142943.60d31a11@tlielax.poochiereds.net> <20100613202842.GA14132@fieldses.org> <20100615133622.10dad9f2@corrin.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:47191 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754225Ab0FORg3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jun 2010 13:36:29 -0400
In-Reply-To: <20100615133622.10dad9f2-4QP7MXygkU+dMjc06nkz3ljfA9RmPOcC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 15, 2010 at 01:36:22PM -0400, Jeff Layton wrote:
> On Sun, 13 Jun 2010 16:28:42 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Wed, Jun 09, 2010 at 02:29:43PM -0400, Jeff Layton wrote:
> > > Ahh ok, I see what you're talking about now. Yeah, that should probably
> > > also be fixed. I think we just need to ensure to shut down the state in
> > > an error condition. Something like this compile-tested only patch?
> > > 
> > > From 19bd25ea9a76ea184e4c30831765e812ce19b0a5 Mon Sep 17 00:00:00 2001
> > > From: Jeff Layton <jlayton@redhat.com>
> > > Date: Wed, 9 Jun 2010 14:21:51 -0400
> > > Subject: [PATCH] nfsd: shut down NFSv4 state when nfsd_svc encounters an error
> > > 
> > > Currently, it's left up in some situations. That could cause the grace
> > > period to be shorter than it should be (along with other problems).
> > 
> > The patch looks right to me, thanks.
> > 
> > --b.
> > 
> 
> FWIW, I've done a bit of testing with this patch on top of the other
> set and it seems to be ok. That said, I don't have a reliable test that
> makes the state setup "leak" like this, so I can't really say much
> other than that it seems to be ok.

OK, thanks.  It should show up in my 2.6.36 tree sometime soon.

--b.
