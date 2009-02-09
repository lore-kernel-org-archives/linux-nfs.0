Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:57211 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750983AbZBIFQo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Feb 2009 00:16:44 -0500
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1LWOVc-0003L5-79
	for linux-nfs@vger.kernel.org; Mon, 09 Feb 2009 16:16:40 +1100
Message-ID: <498FB7BA.6020402@melbourne.sgi.com>
Date: Mon, 09 Feb 2009 15:57:30 +1100
From: Greg Banks <gnb@melbourne.sgi.com>
To: howard chen <howachen@gmail.com>
References: <b66ddc900902082040m24aef720ybab2fd6646377246@mail.gmail.com>
In-Reply-To: <b66ddc900902082040m24aef720ybab2fd6646377246@mail.gmail.com>
Cc: nfs@lists.sourceforge.net
Subject: Re: [NFS] Advise on NFS performance tunning.
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

howard chen wrote:
> Are there any way I can tune my NFS setup?
>
> e.g.
>
> 1. adding more memory to server?
> 2. adding more memory to client?
> 3. upgrade to NFS v4?
> ...
>
> NFS mount option:
> async,noatime,noexec,nosuid,hard,intr,udp,retry=3,rsize=32768,wsize=32768
> NFS version: 3
>
>   
http://mirror.linux.org.au/pub/linux.conf.au/2008/slides/130-lca2008-nfs-tuning-secrets-d7.odp

See in particular slides 27-30, 71-74, 86-88.

You mention increasing the server's RAM; this might help if you're
thrashing the server's dentry or pages caches.  Unfortunately I don't
know of a sensible or easy way to check this, except by comparing the
working set size to RAM.

Bumping up actimeo on the client could be a useful way to reduce the
amount of GETATTR traffic.

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.


------------------------------------------------------------------------------
Create and Deploy Rich Internet Apps outside the browser with Adobe(R)AIR(TM)
software. With Adobe AIR, Ajax developers can use existing skills and code to
build responsive, highly engaging applications that combine the power of local
resources and data with the reach of the web. Download the Adobe AIR SDK and
Ajax docs to start building applications today-http://p.sf.net/sfu/adobe-com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

