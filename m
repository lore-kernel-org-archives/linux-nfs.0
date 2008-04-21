From: "Janne Karhunen" <janne.karhunen@gmail.com>
Subject: Re: [patch] fix statd -n
Date: Sun, 20 Apr 2008 20:49:52 -0400
Message-ID: <24c1515f0804201749x47bee916y9970fe1102bfb5@mail.gmail.com>
References: <24c1515f0804170938s23fe3ea3pfe77355ed01d8bbf@mail.gmail.com>
	 <20080418173646.GC19038@fieldses.org> <480902CA.1070805@redhat.com>
	 <48090356.9020703@redhat.com> <20080418203225.GD28277@fieldses.org>
	 <24c1515f0804181346g5867fa1fqfbbcd13af25027cb@mail.gmail.com>
	 <20080421000214.GA5453@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Peter Staubach" <staubach@redhat.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:36226 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751380AbYDUAtw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 20 Apr 2008 20:49:52 -0400
Received: by wa-out-1112.google.com with SMTP id m16so2704744waf.23
        for <linux-nfs@vger.kernel.org>; Sun, 20 Apr 2008 17:49:52 -0700 (PDT)
In-Reply-To: <20080421000214.GA5453@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Apr 20, 2008 at 8:02 PM, J. Bruce Fields <bfields@fieldses.org> wrote:

>  > I didn't get the idea. So the idea is to use multiple sockets,
>  > one bound to LOOPBACK and one to external interface?
>
>  I suppose so.  One socket would be for communication for the local
>  kernel nfsd, one for communication with statd peers.

Ok, but that's really quite intrusive - my goal with that
patch was to minimize the amount of changes. Sure,
we can rework larger part of it if you think is better
that way.


>  > Complicated and unclean in my opinion: one address
>  > should suffice.
>
>  The advantage is that it would require no changes to the kernel or
>  kernel interfaces, and would also solve the problem for people that
>  don't want to upgrade their kernels.

Right, but that's hardly an issue with Linux. You need
to do that twice per week anyway ;)


>  The "rpc over lo" interface to the kernel's lockd is simple enough, and
>  I'd rather not replace it with "rpc over either lo or the interface
>  specified via sysctl" unless there's a really clear advantage.
>
>  (Also, would your patch mean lockd could accept requests that could have
>  spoofed source addresses?)

Yes, but loopback can also be spoofed. And it
does already improve things by making it bind
specific interface/address instead of ANY (ports
open all around).


-- 
// Janne
