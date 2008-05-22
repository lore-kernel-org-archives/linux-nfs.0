From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] NFSv3 + SVN + Apache2 gives stale filehandles
	and	FORBIDDEN responses
Date: Thu, 22 May 2008 17:41:36 -0400
Message-ID: <20080522214136.GB18822@fieldses.org>
References: <Pine.LNX.4.62.0805201425430.18549@office2.c1.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Allard Hoeve <allard-DW70C6hi67U@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:48676 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760139AbYEVVlx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 May 2008 17:41:53 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JzIXl-0006RN-H1
	for linux-nfs@vger.kernel.org; Fri, 23 May 2008 07:41:49 +1000
In-Reply-To: <Pine.LNX.4.62.0805201425430.18549-FHjt3+7qfYHBZBx2VKNGNcSTQT6m/s+e@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 20, 2008 at 04:07:39PM +0200, Allard Hoeve wrote:
> 
> Hello all,
> 
> I'm currently experiencing the following on Debian Etch (nfsv3, 2.6.24.2):
> 
> http://linux-nfs.org/pipermail/nfsv4/2008-April/008423.html
> 
> It is properly summarized by J. Bruce Fields at:
> 
> http://linux-nfs.org/pipermail/nfsv4/2008-April/008452.html
> 
> I can reproduce this easily.
> 
> Let's assume three hosts:
> 
> * Host A is where development happens, this has a separate checkout
> * Host B is where the checkout gets updated (shellserver) on an NFS mount
> * Host C is where the webserver resides, Apache serves from the an NFS
>     mount that points to the same server as B's NFS mount points to
> 
> This setup is easily created if you have two hosts and access to an SVN 
> server.
> 
> To reproduce:
> 
> 1) I update the testfile on host A and commit it.
> 2) I update the checkout with svn commit on host B.
> 3) No I test the file on host C:
>     a) I try to access the file on host C through the webserver: permission
>        denied (stale NFS handle)
>     b) I try to stat the file: cannot stat 'test': Stale NFS file handle
> 4) A simple 'cat test' gives me the new contents of 'test' and solves the
>      problem. The file is now 'stat'-able and downloadable through the
>      webserver.
> 
> Where should I start to solve the problem? From the threads above, I seem 
> to understand that fixing this in userspace (Apache2 / stat) would require 
> some work and that the solution lies in the NFS client? This would require 
> me hacking the NFS kernel code.  *shivers* :)
> 
> Or maybe there already is someone working on the problem? *crosses 
> fingers*. I could test patches, etc if you'd like.x

The only proposal I've heard to address this involves fixing the client
to retry a lookup one time.  The steps of that project as I understand
it are:

	1. Digest this message from Al Viro into language the rest of us
	   can understand:
	   http://thread.gmane.org/gmane.linux.kernel/676019/focus=676145
	2. Implement the result.

Looks difficult but fun....

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

