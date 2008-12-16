From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NLM] 2.6.27 broken
Date: Tue, 16 Dec 2008 15:16:10 -0500
Message-ID: <20081216201610.GE18928@fieldses.org>
References: <20081115132831.GA11329@janus> <20081120222731.GA591@fieldses.org> <20081128112447.GA25340@janus> <20081216173923.GE16388@fieldses.org> <1229456632.6023.1.camel@tucsk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Frank van Maarseveen <frankvm@frankvm.com>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: Miklos Szeredi <mszeredi@suse.cz>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:52209 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753903AbYLPUQO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Dec 2008 15:16:14 -0500
In-Reply-To: <1229456632.6023.1.camel@tucsk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 16, 2008 at 08:43:52PM +0100, Miklos Szeredi wrote:
> On Tue, 2008-12-16 at 12:39 -0500, J. Bruce Fields wrote:
> > More precisely, it looks like this started with
> > 
> > 	bde74e4bc64415b142e "locks: add special return value for
> > 		asynchronous locks"
> > 
> > But I haven't had the chance to look any harder yet.  Miklos?  Is this
> > easy for you to reproduce?
> 
> Not immediately, at the moment I don't have NFS set up.  But if you
> don't beat me to it, I'll look into this.

OK, thanks.  I'll take another look too when I get the chance, so let me
know of any partial result.

It may just for example be returning the wrong error to the client on an
nlm blocking lock request, so that the client assumes the lock is gone
and goes away rather than waiting for a grant request.

--b.
