From: "Janne Karhunen" <janne.karhunen@gmail.com>
Subject: Re: [patch] fix statd -n
Date: Fri, 18 Apr 2008 16:39:48 -0400
Message-ID: <24c1515f0804181339r46ce3348y93c91c87c7cc624a@mail.gmail.com>
References: <24c1515f0804170938s23fe3ea3pfe77355ed01d8bbf@mail.gmail.com>
	 <20080418173646.GC19038@fieldses.org>
	 <24c1515f0804181111x465d7083o4b78e1ba36b51cb@mail.gmail.com>
	 <480902FA.7060609@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: "Peter Staubach" <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.183]:54792 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752175AbYDRUjt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2008 16:39:49 -0400
Received: by wa-out-1112.google.com with SMTP id m16so1151896waf.23
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2008 13:39:48 -0700 (PDT)
In-Reply-To: <480902FA.7060609@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 18, 2008 at 4:22 PM, Peter Staubach <staubach@redhat.com> wrote:

> > In my case I used -n to push NSM/NLM comms to
> > clusters specific NFS service address (that just
> > happens to migrate all around). -n is the only way
> > to do this: otherwise it will bind to INADDR_ANY
> > on node that has gazillion interfaces/addresses..
> >
>
>  What happens on systems with more than one network interface?

Using -n breaks and without it it uses loopback
at least on this system - but that's just luck I
guess. And, of course, without -n it's bound to
ANY which leaves ports wide open all around.


-- 
// Janne
