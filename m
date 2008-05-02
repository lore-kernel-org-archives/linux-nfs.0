From: "Janne Karhunen" <janne.karhunen@gmail.com>
Subject: Re: [patch] fix statd -n
Date: Fri, 2 May 2008 18:54:11 -0400
Message-ID: <24c1515f0805021554u483c471bm61cf3a6d8d434b45@mail.gmail.com>
References: <24c1515f0804170938s23fe3ea3pfe77355ed01d8bbf@mail.gmail.com>
	 <20080421000214.GA5453@fieldses.org>
	 <24c1515f0804281352u2d04ac89i820dc6807dde39f1@mail.gmail.com>
	 <4817346F.5000101@netapp.com> <20080429161607.GA20420@fieldses.org>
	 <24c1515f0805010557o5daf72f7hc3db5bf85354898e@mail.gmail.com>
	 <24c1515f0805010628k6b57598btb27116c719b99fad@mail.gmail.com>
	 <481B316E.8090800@gmail.com>
	 <24c1515f0805021413u450d8bbcr806a90c327b287a1@mail.gmail.com>
	 <481B96D0.8010802@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	"Peter Staubach" <staubach@redhat.com>, linux-nfs@vger.kernel.org
To: "Wendy Cheng" <s.wendy.cheng@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.181]:44370 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932140AbYEBWyM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 May 2008 18:54:12 -0400
Received: by wa-out-1112.google.com with SMTP id j37so561916waf.23
        for <linux-nfs@vger.kernel.org>; Fri, 02 May 2008 15:54:11 -0700 (PDT)
In-Reply-To: <481B96D0.8010802@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 2, 2008 at 6:33 PM, Wendy Cheng <s.wendy.cheng@gmail.com> wrote:

> > So this basically makes it a users problem, I don't
> > like it. Statd's standard notifications are just fine and
> > I don't want to have anything to do with the process.
> > It should work as is, out of the box, without writing
> > separate programs to handle stuff that statd doesn't
> > do.
> >
>  I think you mis-understand our approach. With our patch, you do *not* need
> to do anything if you have only one single (floating) interface to do nfs
> export (and you can have the machine configured to use other hostname). The
> statd's "my_name" is correctly filled (from kernel by our patch) - it is no
> longer bound to 127.0.0.1.

What happens when it fails over to node that has
different name?  Mon_name in NOTIFY changes
while address it's coming from does not. Which
one should client believe - the address or the
name?

But OK, I probably need to dig out the patch to
have a look.


> > One specific segment is just enough for us.
>
>  I know .. but there *are* users and live systems *today* that have multiple
> nfs interfaces. For big-fat server, I normally saw 4.

I'm still a bit confused - does your patch make it
sure that all the extra N+1 IP addresses in the
node have nothing to do with NFS?

If not, these still seem like two different use cases,
ie. making the service tightly bound to one service
address instead of making it work right with many.


-- 
// Janne
