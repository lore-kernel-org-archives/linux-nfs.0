From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] nfs2/3 ESTALE bug on mount point (v2.6.24-rc8)
Date: Mon, 28 Jan 2008 22:48:35 -0500
Message-ID: <20080129034834.GA1190@fieldses.org>
References: <20080129010819.GD16785@fieldses.org> <200801290303.m0T33miE028199@agora.fsl.cs.sunysb.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, linux-nfs@vger.kernel.org,
	Trond.Myklebust@netapp.com
To: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:35838 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752322AbYA2Dsj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Jan 2008 22:48:39 -0500
In-Reply-To: <200801290303.m0T33miE028199-zop+azHP2WsZjdeEBZXbMidm6ipF23ct@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 28, 2008 at 10:03:48PM -0500, Erez Zadok wrote:
> In message <20080129010819.GD16785@fieldses.org>, "J. Bruce Fields" writes:
> > On Sun, Jan 27, 2008 at 11:37:59PM -0500, Erez Zadok wrote:
> 
> > > You can find both an strace and content files in
> > > 
> > > 	http://agora.fsl.cs.sunysb.edu/tmp/nfs/
> 
> Sorry.  I guess tar on /proc files doesn't really save the content of the
> files.

Hm.

> I cat'ed the content files and alo placed an updated strace in the above
> URL.  Here's the content files.  In this run, I got an ESTALE on
> /n/lower/b2:
> 
>   mkdir: cannot create directory `/n/lower/b2': Stale NFS file handle

OK, thanks.  This looks consistent with the strace I looked at.  So
utils/mountd/cache.c:nfsd_fh() is occasionally getting the wrong result
for some reason.

--b.
