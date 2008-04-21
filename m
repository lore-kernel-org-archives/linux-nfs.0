From: "Janne Karhunen" <janne.karhunen@gmail.com>
Subject: Re: [patch] fix statd -n
Date: Mon, 21 Apr 2008 10:46:00 -0400
Message-ID: <24c1515f0804210746t2d392b8ct6575f09dc7254b07@mail.gmail.com>
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
Received: from rn-out-0910.google.com ([64.233.170.188]:57357 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751505AbYDUOqC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Apr 2008 10:46:02 -0400
Received: by rn-out-0910.google.com with SMTP id e11so348823rng.17
        for <linux-nfs@vger.kernel.org>; Mon, 21 Apr 2008 07:46:01 -0700 (PDT)
In-Reply-To: <20080421000214.GA5453@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Apr 20, 2008 at 8:02 PM, J. Bruce Fields <bfields@fieldses.org> wrote:

>  > >  > Sorry, not very clear.  Perhaps statd should bind to the loopback
>  > >  > interface in addition to any other interfaces if it doesn't bind
>  > >  > to INADDR_ANY.
>  > >
>  > >  Right, that's what would make the most sense to me.  Janne, is there any
>  > >  reason that wouldn't solve your problem?
>  >
>  > I didn't get the idea. So the idea is to use multiple sockets,
>  > one bound to LOOPBACK and one to external interface?
>
>  I suppose so.  One socket would be for communication for the local
>  kernel nfsd, one for communication with statd peers.

So shall we add yet another port option for statd or talk
to portmap about the port assignment?  It's ugly any way
you put it.



-- 
// Janne
