From: "Janne Karhunen" <janne.karhunen@gmail.com>
Subject: Re: [patch] fix statd -n
Date: Sat, 3 May 2008 13:31:19 -0400
Message-ID: <24c1515f0805031031o495ef56ekac111ccff64e5a27@mail.gmail.com>
References: <24c1515f0804170938s23fe3ea3pfe77355ed01d8bbf@mail.gmail.com>
	 <4817346F.5000101@netapp.com> <20080429161607.GA20420@fieldses.org>
	 <24c1515f0805010557o5daf72f7hc3db5bf85354898e@mail.gmail.com>
	 <24c1515f0805010628k6b57598btb27116c719b99fad@mail.gmail.com>
	 <481B316E.8090800@gmail.com>
	 <24c1515f0805021413u450d8bbcr806a90c327b287a1@mail.gmail.com>
	 <481B96D0.8010802@gmail.com>
	 <24c1515f0805021554u483c471bm61cf3a6d8d434b45@mail.gmail.com>
	 <481C84E9.3060602@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	"Peter Staubach" <staubach@redhat.com>, linux-nfs@vger.kernel.org
To: "Wendy Cheng" <s.wendy.cheng@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.180]:10236 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762675AbYECRbT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 3 May 2008 13:31:19 -0400
Received: by wa-out-1112.google.com with SMTP id j37so1022884waf.23
        for <linux-nfs@vger.kernel.org>; Sat, 03 May 2008 10:31:19 -0700 (PDT)
In-Reply-To: <481C84E9.3060602@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, May 3, 2008 at 11:29 AM, Wendy Cheng <s.wendy.cheng@gmail.com> wrote:

> > >  I think you mis-understand our approach. With our patch, you do *not*
> need
> > > to do anything if you have only one single (floating) interface to do
> nfs
> > > export (and you can have the machine configured to use other hostname).
> The
> > > statd's "my_name" is correctly filled (from kernel by our patch) - it is
> no
> > > longer bound to 127.0.0.1.
> > >
> > >
> >
> > What happens when it fails over to node that has
> > different name?  Mon_name in NOTIFY changes
> > while address it's coming from does not. Which
> > one should client believe - the address or the
> > name?
> >
> > But OK, I probably need to dig out the patch to
> > have a look.
> >
> >
>  In the middle of re-doing our old patch (it should be very small this time,
> with Frank's patch already in mainline and Chuck taking over IPV6 issues) so
> the logic can be clear. I also have a feel that you never look into
> "sm-notify" ?

I didn't, as I was under a (apparently false) impression
that this indeed is a separate, manual way to trigger
the notification for whatever purpose. My apologies,


-- 
// Janne
