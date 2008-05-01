From: "Janne Karhunen" <janne.karhunen@gmail.com>
Subject: Re: [patch] fix statd -n
Date: Thu, 1 May 2008 08:57:57 -0400
Message-ID: <24c1515f0805010557o5daf72f7hc3db5bf85354898e@mail.gmail.com>
References: <24c1515f0804170938s23fe3ea3pfe77355ed01d8bbf@mail.gmail.com>
	 <20080418173646.GC19038@fieldses.org> <480902CA.1070805@redhat.com>
	 <48090356.9020703@redhat.com> <20080418203225.GD28277@fieldses.org>
	 <24c1515f0804181346g5867fa1fqfbbcd13af25027cb@mail.gmail.com>
	 <20080421000214.GA5453@fieldses.org>
	 <24c1515f0804281352u2d04ac89i820dc6807dde39f1@mail.gmail.com>
	 <4817346F.5000101@netapp.com> <20080429161607.GA20420@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Wendy Cheng" <wcheng@netapp.com>,
	"Peter Staubach" <staubach@redhat.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.181]:28753 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754316AbYEAM56 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 May 2008 08:57:58 -0400
Received: by wa-out-1112.google.com with SMTP id j37so1013419waf.23
        for <linux-nfs@vger.kernel.org>; Thu, 01 May 2008 05:57:58 -0700 (PDT)
In-Reply-To: <20080429161607.GA20420@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 29, 2008 at 12:16 PM, J. Bruce Fields <bfields@fieldses.org> wrote:

>  > Do we really have to add so many lines of the code just to fix "statd
>  > -n"

Which is why I offered the small patch initially; it was
mentioned that intrusiveness does not matter if it
can be kept in userspace.


> >  ? Maybe we should go back to the basics by understanding the
>  > requirement of this command ? So why do we need it (i.e. what kind of
>  > bad things we'll see if we don't fix this) ? Some short description
>  > would help.
>
>  I recall two reasons for -n given in this thread; I think one was just
>  security (maybe you don't want statd listening on some ports, for
>  whatever reason.  The other was a code comment quoted here:

That being one..


>         http://marc.info/?l=linux-nfs&m=120854237320424&w=2
>
>
>         "This is required to support clients that ignore the mon_name in
>         the statd protocol but use the source address from the request
>         packet."

This another, and the third the fact that this way mon_name
stays the same on server failover to node that has different
name. It identifies the server instance..


>  Which I don't completely understand.  I guess it was meant as a way to
>  ensure that *outgoing* packets are sent from the correct (floating) ip
>  address?

Right.


-- 
// Janne
