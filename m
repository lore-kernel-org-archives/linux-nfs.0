From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [patch] fix statd -n
Date: Mon, 5 May 2008 10:45:38 -0400
Message-ID: <20080505144538.GB8259@fieldses.org>
References: <20080421000214.GA5453@fieldses.org> <24c1515f0804281352u2d04ac89i820dc6807dde39f1@mail.gmail.com> <4817346F.5000101@netapp.com> <20080429161607.GA20420@fieldses.org> <24c1515f0805010557o5daf72f7hc3db5bf85354898e@mail.gmail.com> <24c1515f0805010628k6b57598btb27116c719b99fad@mail.gmail.com> <481B316E.8090800@gmail.com> <24c1515f0805021413u450d8bbcr806a90c327b287a1@mail.gmail.com> <481B96D0.8010802@gmail.com> <24c1515f0805021724q7dfe5294r702a9c8ffde01129@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wendy Cheng <s.wendy.cheng@gmail.com>,
	Peter Staubach <staubach@redhat.com>, linux-nfs@vger.kernel.org
To: Janne Karhunen <janne.karhunen@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:51567 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756016AbYEEOpl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 May 2008 10:45:41 -0400
In-Reply-To: <24c1515f0805021724q7dfe5294r702a9c8ffde01129-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 02, 2008 at 08:24:25PM -0400, Janne Karhunen wrote:
> On Fri, May 2, 2008 at 6:33 PM, Wendy Cheng <s.wendy.cheng@gmail.com> wrote:
> 
> >  Maybe I mislead you in previous post. The "-H" is only an "example" - to
> > show people how to selectively move an ip address around without affecting
> > other co-existing nfs ip interface on the same server. I did plan to submit
> > a complete user mode patch so the program after "-H" will have a default
> > executable (but user still can use their own if they don't like our nlm
> > directory structure).
> 
> Even if you ship the default executable user would
> still need to go and edit it (add the address). Well,
> I guess it would not be that much harder than
> specifying the -n, but somehow this does seem
> more arcane (for simple setups).

In any case, if there's still a legimate use case for -n, even if it's
not great, we should err on the side of fixing it just to save problems
for anyone with an existing working setup.

If -n has never worked at all for anyone, then OK, let's get rid of it.

--b.
