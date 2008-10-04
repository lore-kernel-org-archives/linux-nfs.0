From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Is NFS v4 stable and recommend to use now?
Date: Sat, 4 Oct 2008 16:48:56 -0400
Message-ID: <20081004204856.GB2777@fieldses.org>
References: <beaf78240810020949j703d95cvab1c44f33bff7019@mail.gmail.com> <20081002171719.GA30408@fieldses.org> <beaf78240810021034k3cb7db69p7ac458b8a3cfbb28@mail.gmail.com> <20081003215247.GJ19057@fieldses.org> <beaf78240810040634i672904c7g51e02855227a9d7c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: "Roy M." <setesting001@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:34483 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753384AbYJDUs5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 4 Oct 2008 16:48:57 -0400
In-Reply-To: <beaf78240810040634i672904c7g51e02855227a9d7c-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Oct 04, 2008 at 09:34:49PM +0800, Roy M. wrote:
> Hello,
> 
> On Sat, Oct 4, 2008 at 5:52 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > I doubt the pattern of I/O really matters much--it's the opens and
> > closes themselves that matter.
> >
> > (In v3, close-to-open cache consistency requires that the client always
> > fetch file attributes from the server on an open.  That means open() is
> > always going to take at least the ping time to the server.  In v4 in
> > some situations the client can do the open with no call to the server at
> > all--by comparison such an open is almost instantaneous.  If you're
> > doing a ton of opens all in a row, that may make a difference.)
> >
> 
> In existing v3, you mean even if a file is cached locally by client,
> in each open, the file attributes need to be read from NFS server
> everytime?

Right.  The client has to do that to check whether someone else has
changed the file.  See http://nfs.sourceforge.net/#faq_a8 for an
explanation of close-to-open cache consistency, which is what requires
this.

> But I just wonder without reading the NFS server, how the consistency
> was maintained...

I'm afraid I don't understand the question.

--b.
