From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Is NFS v4 stable and recommend to use now?
Date: Fri, 3 Oct 2008 17:52:47 -0400
Message-ID: <20081003215247.GJ19057@fieldses.org>
References: <beaf78240810020949j703d95cvab1c44f33bff7019@mail.gmail.com> <20081002171719.GA30408@fieldses.org> <beaf78240810021034k3cb7db69p7ac458b8a3cfbb28@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: "Roy M." <setesting001@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:38487 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753448AbYJCVws (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Oct 2008 17:52:48 -0400
In-Reply-To: <beaf78240810021034k3cb7db69p7ac458b8a3cfbb28-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 03, 2008 at 01:34:51AM +0800, Roy M. wrote:
> Hello,
> 
> On Fri, Oct 3, 2008 at 1:17 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > On Fri, Oct 03, 2008 at 12:49:50AM +0800, Roy M. wrote:
> >
> > If you're just doing big I/O to a few files, that may be all you care
> > about.  If you're doing something more complicated then the situation
> > isn't well understood yet.
> >
> 
> Do you mean for few files with large size stored in NFS, then maybe
> not benefit too much from NFS4, while if I have many files, need to
> fetch to client in parallel and in high concurrency, then it might be
> a good choice? (in fact, I also heard client side caching in v4 is
> better)

I doubt the pattern of I/O really matters much--it's the opens and
closes themselves that matter.

(In v3, close-to-open cache consistency requires that the client always
fetch file attributes from the server on an open.  That means open() is
always going to take at least the ping time to the server.  In v4 in
some situations the client can do the open with no call to the server at
all--by comparison such an open is almost instantaneous.  If you're
doing a ton of opens all in a row, that may make a difference.)

--b.

> 
> 
> Besides, can I say v4 is the recommended to be used in production right now?
> 
> Thanks.
