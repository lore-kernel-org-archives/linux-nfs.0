From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] Export especific file extension
Date: Tue, 28 Jul 2009 12:21:21 -0400
Message-ID: <20090728162121.GH19497@fieldses.org>
References: <4A6E0E9F.3010009@gmail.com> <4A6E281F.4020209@hp.com>
	<4A6EDBC9.6040008@gmail.com> <4A6EFB00.2080308@hp.com>
	<4A6EFEE9.1070708@gmail.com> <4A6F02F5.9090002@hp.com>
	<4A6F0DCB.3090903@gmail.com> <4A6F2018.1040808@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>,
	=?utf-8?Q?F=C3=A1bio_Jr=2E?= <fjuniorlista@gmail.com>
To: Rob Gardner <rob.gardner@hp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:57313 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752873AbZG1Qpb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Jul 2009 12:45:31 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1MVpnW-0006mT-TB
	for linux-nfs@vger.kernel.org; Wed, 29 Jul 2009 02:45:06 +1000
In-Reply-To: <4A6F2018.1040808@hp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 28, 2009 at 09:58:16AM -0600, Rob Gardner wrote:
> You could go into the kernel and hack a filter into say, the nfs lookup 
> code, and cause lookup failures for files named '*.jpg' on certain 
> exports. That would scale, though would take quite a bit more work.

This sounds more like a problem that should be solved on the application
side....

E.g. surely there's a way to configure apache (or whatever) to map paths
like $foo.jpg to /nfs/image-server/$foo.jpg?

--b.

------------------------------------------------------------------------------
Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30-Day 
trial. Simplify your report design, integration and deployment - and focus on 
what you do best, core application coding. Discover what's new with 
Crystal Reports now.  http://p.sf.net/sfu/bobj-july
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

