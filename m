From: "Mr. James W. Laferriere" <babydr@baby-dragons.com>
Subject: Re: make NFS work with 64KB page-size
Date: Wed, 18 Jun 2003 21:26:24 -0400 (EDT)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.56.0306182124270.29031@filesrv1.baby-dragons.com>
References: <16112.60959.588900.824473@napali.hpl.hp.com>
 <16113.5317.341448.162576@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net,
	Linux Kernel Maillist <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16113.5317.341448.162576@gargle.gargle.HOWL>
List-ID: <nfs.lists.sourceforge.net>

	Hello Neil ,  Hth ,  JimL

+++ ./net/sunrpc/svc.c	2003-06-19 11:38:30.000000000 +1000
...snip...
-	int pages = 2 + (size+ PAGE_SIZE -1) / PAGE_SIZE;
+	int page;
	    ^^^^ s/b pages ?

On Thu, 19 Jun 2003, Neil Brown wrote:
> On Wednesday June 18, davidm@napali.hpl.hp.com wrote:
> > NFS currently bugs out on kernels with a page size of 64KB.  The
> > reason is a mismatch between RPCSVC_MAXPAGES and a calculation in
> > svc_init_buffer().  I'm not entirely certain which calculation is the
> > right one, but if I understand the code correctly, RPCSVC_MAXPAGES is
> > right and svc_init_buffer() is wrong.  The patch below fixes the
> > latter.
>
> I think the +2 is right.
>
> For read/readdir the reply can be slightly larger than the "payload",
> (headers, etc) so we need one payload, plus one for the rest of the
> reply, plus one to hold the request.
>
> For write, the request can be large than the payload, so again we need
> payload + 1 (for request) + 1 (for reply).
> Something like the following.
> NeilBrown
-- 
       +------------------------------------------------------------------+
       | James   W.   Laferriere | System    Techniques | Give me VMS     |
       | Network        Engineer |     P.O. Box 854     |  Give me Linux  |
       | babydr@baby-dragons.com | Coudersport PA 16915 |   only  on  AXP |
       +------------------------------------------------------------------+
