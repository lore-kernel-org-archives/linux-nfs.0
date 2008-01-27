From: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>
Subject: Re: [NFS] Q: directory renames and cache coherency in NFS?
Date: Sun, 27 Jan 2008 13:29:26 -0500
Message-ID: <200801271829.m0RITQkQ002462@agora.fsl.cs.sunysb.edu>
References: <1201457297.7346.27.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>,
	nfs@lists.sourceforge.net, Al Viro <viro@zeniv.linux.org.uk>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:50428 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751403AbYA0S3u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 27 Jan 2008 13:29:50 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JJCGL-00070R-4G
	for linux-nfs@vger.kernel.org; Mon, 28 Jan 2008 05:29:49 +1100
In-reply-to: Your message of "Sun, 27 Jan 2008 13:08:17 EST."
	<1201457297.7346.27.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In message <1201457297.7346.27.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>, Trond Myklebust writes:
> 
> On Sun, 2008-01-27 at 10:55 -0500, Erez Zadok wrote:
> > NFS shares some traits with stackable file systems.  Both have some notion
> > of "layers": in nfs, it's client -> server -> local f/s; in a stackable f/s
> > it's upper -> lower.
> > 
> > I'm trying to understand what are the semantics of NFS when directories are
> > renamed on the server while a client is trying to use those directories (I
> > follow a similar behavior in unionfs or other stackable f/s).  Consider this
> > sequence of steps:
> > 
> > 1. client looks up (or revalidates) directory D1
> > 2. server renames D1 to D2 (D2 could be anywhere in the tree)
> > 3. client tries to create file F in (the cached) directory D1
> > 
> > What happens in the last step?  Does the client get an ESTALE or some other
> > error?  Or does it succeed and F gets created in the renamed directory
> > (D2/F)?  Does the behavior differ b/t nfsv2/3/4?  Is it described the RFCs
> > or specs?
> 
> The general rule is that an NFSv2/v3/v4 client would expect 3 to succeed
> (provided that the user has the required permissions).
[...]

And by "succeed", you mean that the new file F will be created in D2, right?

Thanks,
Erez.

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

