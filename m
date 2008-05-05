From: "Janne Karhunen" <janne.karhunen@gmail.com>
Subject: Re: [patch] fix statd -n
Date: Mon, 5 May 2008 11:01:42 -0400
Message-ID: <24c1515f0805050801m66cce68k94073914ba26511e@mail.gmail.com>
References: <20080421000214.GA5453@fieldses.org>
	 <20080429161607.GA20420@fieldses.org>
	 <24c1515f0805010557o5daf72f7hc3db5bf85354898e@mail.gmail.com>
	 <24c1515f0805010628k6b57598btb27116c719b99fad@mail.gmail.com>
	 <481B316E.8090800@gmail.com>
	 <24c1515f0805021413u450d8bbcr806a90c327b287a1@mail.gmail.com>
	 <481B96D0.8010802@gmail.com>
	 <24c1515f0805021724q7dfe5294r702a9c8ffde01129@mail.gmail.com>
	 <20080505144538.GB8259@fieldses.org> <481F20B6.8080603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	"Peter Staubach" <staubach@redhat.com>, linux-nfs@vger.kernel.org
To: "Wendy Cheng" <s.wendy.cheng@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.177]:50805 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753724AbYEEPBq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 May 2008 11:01:46 -0400
Received: by el-out-1112.google.com with SMTP id n30so715034elf.21
        for <linux-nfs@vger.kernel.org>; Mon, 05 May 2008 08:01:43 -0700 (PDT)
In-Reply-To: <481F20B6.8080603@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 5, 2008 at 10:59 AM, Wendy Cheng <s.wendy.cheng@gmail.com> wrote:

> > In any case, if there's still a legimate use case for -n, even if it's
> > not great, we should err on the side of fixing it just to save problems
> > for anyone with an existing working setup.
> >
>  Simpler code and consolidated logic flow are always better - would like to
> vote for its deletion.

So the solution would be to use -H with a script that
does sm-notify with user specified name (-v)? Kernel
name can't be used directly as it might migrate to
node that has different name.


-- 
// Janne
