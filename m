From: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>
Subject: [NFS] Q: directory renames and cache coherency in NFS?
Date: Sun, 27 Jan 2008 10:55:25 -0500
Message-ID: <200801271555.m0RFtPiI024845@agora.fsl.cs.sunysb.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Al Viro <viro@zeniv.linux.org.uk>
To: "J. Bruce Fields" <bfields@fieldses.org>,
	Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
	nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:56996 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750932AbYA0Pz6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 27 Jan 2008 10:55:58 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JJ9rP-0006Tc-EG
	for linux-nfs@vger.kernel.org; Mon, 28 Jan 2008 02:55:55 +1100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS shares some traits with stackable file systems.  Both have some notion
of "layers": in nfs, it's client -> server -> local f/s; in a stackable f/s
it's upper -> lower.

I'm trying to understand what are the semantics of NFS when directories are
renamed on the server while a client is trying to use those directories (I
follow a similar behavior in unionfs or other stackable f/s).  Consider this
sequence of steps:

1. client looks up (or revalidates) directory D1
2. server renames D1 to D2 (D2 could be anywhere in the tree)
3. client tries to create file F in (the cached) directory D1

What happens in the last step?  Does the client get an ESTALE or some other
error?  Or does it succeed and F gets created in the renamed directory
(D2/F)?  Does the behavior differ b/t nfsv2/3/4?  Is it described the RFCs
or specs?

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

