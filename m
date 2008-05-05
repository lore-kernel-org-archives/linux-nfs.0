From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [patch] fix statd -n
Date: Mon, 5 May 2008 11:25:19 -0400
Message-ID: <20080505152519.GE8259@fieldses.org>
References: <24c1515f0805010628k6b57598btb27116c719b99fad@mail.gmail.com> <481B316E.8090800@gmail.com> <24c1515f0805021413u450d8bbcr806a90c327b287a1@mail.gmail.com> <481B96D0.8010802@gmail.com> <24c1515f0805021724q7dfe5294r702a9c8ffde01129@mail.gmail.com> <20080505144538.GB8259@fieldses.org> <481F20B6.8080603@gmail.com> <24c1515f0805050801m66cce68k94073914ba26511e@mail.gmail.com> <481F2600.20501@gmail.com> <24c1515f0805050823s14f4caf7s3a4ff06a70c220be@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wendy Cheng <s.wendy.cheng@gmail.com>,
	Peter Staubach <staubach@redhat.com>, linux-nfs@vger.kernel.org
To: Janne Karhunen <janne.karhunen@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:48634 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757599AbYEEPZV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 May 2008 11:25:21 -0400
In-Reply-To: <24c1515f0805050823s14f4caf7s3a4ff06a70c220be-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 05, 2008 at 11:23:37AM -0400, Janne Karhunen wrote:
> On Mon, May 5, 2008 at 11:21 AM, Wendy Cheng <s.wendy.cheng@gmail.com> wrote:
> 
> >  No. "-H" is only for different export (server IP) interfaces. Say server
> > has 10.1.1.1 and 10.1.1.2 as NFS export interfaces. If 10.1.1.1 is migrated
> > but 10.1.1.2 stays, you would like to notify the nfs clients coming in from
> > 10.1.1.1 but not the clients from 10.1.1.2, you need to structure your sm
> > directory seperately. That is the usage of "-H" (to allow admin to organize
> > client IPs).
> 
> Right.
> 
> 
> >  For a single export IP interface like you have (even you have a seperate
> > hostname), ignore "-H". I believe "sm-notify -v" should be enough -
> > otherwise we have bugs - i.e., sm-notify should be part of your nfsd
> > bring-up script.
> 
> As statd runs this directly and reads name for -v from
> MY_NAME,

Nope; see the -L option to statd.

--b.

> how exactly would you pass it MY_NAME
> given that -n is removed?
