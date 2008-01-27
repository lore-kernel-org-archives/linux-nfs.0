From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [NFS] Q: directory renames and cache coherency in NFS?
Date: Sun, 27 Jan 2008 13:08:17 -0500
Message-ID: <1201457297.7346.27.camel@heimdal.trondhjem.org>
References: <200801271555.m0RFtPiI024845@agora.fsl.cs.sunysb.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, nfs@lists.sourceforge.net,
	Al Viro <viro@zeniv.linux.org.uk>
To: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:41643 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752837AbYA0SWv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 27 Jan 2008 13:22:51 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JJC9a-0006zE-4O
	for linux-nfs@vger.kernel.org; Mon, 28 Jan 2008 05:22:50 +1100
In-Reply-To: <200801271555.m0RFtPiI024845-zop+azHP2WsZjdeEBZXbMidm6ipF23ct@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Sun, 2008-01-27 at 10:55 -0500, Erez Zadok wrote:
> NFS shares some traits with stackable file systems.  Both have some notion
> of "layers": in nfs, it's client -> server -> local f/s; in a stackable f/s
> it's upper -> lower.
> 
> I'm trying to understand what are the semantics of NFS when directories are
> renamed on the server while a client is trying to use those directories (I
> follow a similar behavior in unionfs or other stackable f/s).  Consider this
> sequence of steps:
> 
> 1. client looks up (or revalidates) directory D1
> 2. server renames D1 to D2 (D2 could be anywhere in the tree)
> 3. client tries to create file F in (the cached) directory D1
> 
> What happens in the last step?  Does the client get an ESTALE or some other
> error?  Or does it succeed and F gets created in the renamed directory
> (D2/F)?  Does the behavior differ b/t nfsv2/3/4?  Is it described the RFCs
> or specs?

The general rule is that an NFSv2/v3/v4 client would expect 3 to succeed
(provided that the user has the required permissions).

The only exception would be in the case of NFSv4, if the server has set
the filesystem-wide attribute 'fh_expire_type' to the values
FH4_VOL_RENAME or FH4_VOL_ANY (i.e. volatile filehandles). In that case,
the server may return an NFS4ERR_FHEXPIRED error, in which case the
client is supposed to attempt to recover (though what mechanism it may
use to do that after a rename is a mystery to me - the spec certainly
doesn't attempt to explain).

Trond

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

