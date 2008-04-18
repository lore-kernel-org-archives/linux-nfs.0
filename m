From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [patch] fix statd -n
Date: Fri, 18 Apr 2008 14:34:43 -0400
Message-ID: <20080418183443.GE24552@fieldses.org>
References: <24c1515f0804170938s23fe3ea3pfe77355ed01d8bbf@mail.gmail.com> <20080418173646.GC19038@fieldses.org> <24c1515f0804181111x465d7083o4b78e1ba36b51cb@mail.gmail.com> <20080418182550.GC24552@fieldses.org> <24c1515f0804181131i238a50a7v85ef80299ec2216f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Janne Karhunen <janne.karhunen@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:57087 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759671AbYDRSep (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Apr 2008 14:34:45 -0400
In-Reply-To: <24c1515f0804181131i238a50a7v85ef80299ec2216f-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 18, 2008 at 02:31:40PM -0400, Janne Karhunen wrote:
> On Fri, Apr 18, 2008 at 2:25 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> >  >         /*
> >  >          * If a local hostname is given (-n option to statd), bind to
> >  > the address
> >  >          * specified. This is required to support clients that ignore
> >  > the mon_name in
> >  >          * the statd protocol but use the source address from the
> >  > request packet.
> >  >          */
> >
> >  Weird--I dont' see that comment.
> 
> All original nfs-utils-1.0.12 tarball; indeed strange.

I was looking at recent git.  Note the most recent tarball on
sourceforge.net is 1.1.2, and that has the relevant changes.

--b.

> 
> But to be honest, I don't instantly understand how
> this would work without -n at all (apart blind luck).
> INADDR_ANY has no guarantees..
> 
> 
> -- 
> // Janne
