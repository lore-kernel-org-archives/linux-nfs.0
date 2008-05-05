From: "Janne Karhunen" <janne.karhunen@gmail.com>
Subject: Re: [patch] fix statd -n
Date: Mon, 5 May 2008 12:14:22 -0400
Message-ID: <24c1515f0805050914s6320bebei78be3cae4a8278e0@mail.gmail.com>
References: <24c1515f0805010628k6b57598btb27116c719b99fad@mail.gmail.com>
	 <24c1515f0805021724q7dfe5294r702a9c8ffde01129@mail.gmail.com>
	 <20080505144538.GB8259@fieldses.org> <481F20B6.8080603@gmail.com>
	 <24c1515f0805050801m66cce68k94073914ba26511e@mail.gmail.com>
	 <481F2600.20501@gmail.com>
	 <24c1515f0805050823s14f4caf7s3a4ff06a70c220be@mail.gmail.com>
	 <20080505152519.GE8259@fieldses.org>
	 <24c1515f0805050828o3aa5b33aod2a6e4e0b5b6c9dc@mail.gmail.com>
	 <481F2F00.8000303@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	"Peter Staubach" <staubach@redhat.com>, linux-nfs@vger.kernel.org
To: "Wendy Cheng" <s.wendy.cheng@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.177]:24202 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754148AbYEEQOX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 May 2008 12:14:23 -0400
Received: by wa-out-1112.google.com with SMTP id j37so778582waf.23
        for <linux-nfs@vger.kernel.org>; Mon, 05 May 2008 09:14:22 -0700 (PDT)
In-Reply-To: <481F2F00.8000303@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 5, 2008 at 12:00 PM, Wendy Cheng <s.wendy.cheng@gmail.com> wrote:

> > >  > As statd runs this directly and reads name for -v from
> > >  > MY_NAME,
> > >
> > >  Nope; see the -L option to statd.
> > >
> >
> > So the let the user worry approach. Statd does not
> > notify anyone and user is supposed to do it with
> > sm-notify manually. This will work, but -n looks
> > cleaner me..
>
>  Or we can do this ...
>  If user specified "statd -n", we run "sm-notify -v" command for them ? So
> we don't need to fork the code but also keep someone happy ?

Ok, so -n remains..


>  Give me one day to see whether it is doable ?

Given above 1.1.* probably works already, but
it does not address the ANY bind - but do you
even wish that to be addressed?


-- 
// Janne
