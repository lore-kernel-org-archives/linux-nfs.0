From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [NFS] [PATCH] nfs4: allow nfsv4 acls on non-regular-files
Date: Tue, 15 Jan 2008 16:48:09 -0500
Message-ID: <1200433689.20976.0.camel@heimdal.trondhjem.org>
References: <20080108174645.GH22155@fieldses.org>
	<200801082126.m08LQTZm021972@agora.fsl.cs.sunysb.edu>
	<20080115214319.GC5028@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>, nfs@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:37988 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752541AbYAOVtN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jan 2008 16:49:13 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JEteh-0004EW-Ah
	for linux-nfs@vger.kernel.org; Wed, 16 Jan 2008 08:49:11 +1100
In-Reply-To: <20080115214319.GC5028@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Tue, 2008-01-15 at 16:43 -0500, J. Bruce Fields wrote:
> From: J. Bruce Fields <bfields@citi.umich.edu>
> 
> The rfc doesn't give any reason it shouldn't be possible to set an
> attribute on a non-regular file.  And if the server supports it, then it
> shouldn't be up to us to prevent it.

Applied. Thanks Bruce!

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

