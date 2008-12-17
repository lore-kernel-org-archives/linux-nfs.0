From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: possible module refcount leak with auth_gss
Date: Wed, 17 Dec 2008 14:41:27 -0500
Message-ID: <20081217194127.GN4614@fieldses.org>
References: <20081208102855.30081708@tleilax.poochiereds.net> <20081208173706.GE16628@fieldses.org> <20081209153849.6605559a@tleilax.poochiereds.net> <4d569c330812091521s6b9405faq910cb94f067f3b@mail.gmail.com> <20081210112506.2b2d2c3a@tleilax.poochiereds.net> <20081210163136.GB28263@fieldses.org> <20081216164532.22cab9d6@tleilax.poochiereds.net> <20081216214051.51019f51@tupile.poochiereds.net> <20081217192047.GL4614@fieldses.org> <20081217143458.080aa9be@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kevin Coffman <kwc@umich.edu>, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org, Trond Myklebust <trond@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:36412 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750972AbYLQTlb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Dec 2008 14:41:31 -0500
In-Reply-To: <20081217143458.080aa9be-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 17, 2008 at 02:34:58PM -0500, Jeff Layton wrote:
> On Wed, 17 Dec 2008 14:20:47 -0500
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > We certainly shouldn't be really refreshing the cred--that'd end up
> > creating a new gss context when what we're trying to do is destroy one.
> > So leaving cr_ops set to gss_credops() doesn't sound right.
> > 
> > Maybe that gss_refresh_null() should just return 0 and pretend the
> > cred's fine, instead of returning -EACCES?
> > 
> 
> Possibly -- it does look like this is the only place that those credops
> are used.
> 
> What's the reasoning behind clearing the RPCAUTH_CRED_UPTODATE bit
> here? If we don't want to refresh the cred, would it be better to just
> leave it set?

It looks like the CRED_UPTODATE is just being used as a signal to decide
whether the PROC_DESTROY has already been sent; the test_and_clear_bit
ensures that the null call is made just once.  Maybe a separate flag
would be simpler.

This is Trond's code, so he should probably comment.

--b.
