From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [patch] fix statd -n
Date: Fri, 18 Apr 2008 14:25:50 -0400
Message-ID: <20080418182550.GC24552@fieldses.org>
References: <24c1515f0804170938s23fe3ea3pfe77355ed01d8bbf@mail.gmail.com> <20080418173646.GC19038@fieldses.org> <24c1515f0804181111x465d7083o4b78e1ba36b51cb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Janne Karhunen <janne.karhunen@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:59639 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932206AbYDRSZw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Apr 2008 14:25:52 -0400
In-Reply-To: <24c1515f0804181111x465d7083o4b78e1ba36b51cb-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 18, 2008 at 02:11:55PM -0400, Janne Karhunen wrote:
> On Fri, Apr 18, 2008 at 1:36 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> >  > Apparently lockd does not expect statd to be used with -n
> >  > switch: statd is expected to bind loopback, always. Attached
> >  > patches show one (IPv4 specific) way of fixing it. Comments?
> >
> >  Maybe statd really should always bind to the loopback interface?  Is
> >  there any reason not to?
> 
> In my case I used -n to push NSM/NLM comms to
> clusters specific NFS service address (that just
> happens to migrate all around). -n is the only way
> to do this: otherwise it will bind to INADDR_ANY
> on node that has gazillion interfaces/addresses..
> 
> That, and the original reasoning for the option is
> said in statd code:
> 
>         /*
>          * If a local hostname is given (-n option to statd), bind to
> the address
>          * specified. This is required to support clients that ignore
> the mon_name in
>          * the statd protocol but use the source address from the
> request packet.
>          */

Weird--I dont' see that comment.

> >  From a quick look at the current nfs-utils code: it looks like the -n
> >  option only affects the operation of the sm-notify program that's called
> >  on boot to notify peer statd's?  I'm a little confused.  (What version
> >  of nfs-utils are you working from?)
> 
> Right. 1.0.8 -> 1.0.12, it's valid for all.

Oh, OK.  Looks like the change was made for 1.1.0; do nfs-utils more
recent than that work for you?

--b.
