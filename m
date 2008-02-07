From: Rasmus Rohde <rohde-3mLe3WyXyAE@public.gmane.org>
Subject: Re: [NFS] [PATCH] Make UDF exportable
Date: Thu, 07 Feb 2008 08:06:37 +0100
Message-ID: <1202367997.17388.6.camel__39426.7706120901$1202368058$gmane$org@localhost.localdomain>
References: <1201726404.2976.8.camel@localhost.localdomain>
	<20080205102955.GA28347@infradead.org>
	<1202233464.12188.43.camel@localhost.localdomain>
	<20080206180850.GD3475@duck.suse.cz>
	<1202331482.2727.8.camel@localhost.localdomain>
	<20080207054515.GA14585@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	Jan Kara <jack@suse.cz>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:54447 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753302AbYBGHG7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Feb 2008 02:06:59 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JN0qT-0001hN-IO
	for linux-nfs@vger.kernel.org; Thu, 07 Feb 2008 18:06:53 +1100
In-Reply-To: <20080207054515.GA14585@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ok - I have checked get_parent and it works as expected.
I used the "Neil Brown"-test mentioned elsewhere in this thread and
added a few printk's to make sure we actually got the code covered.

> There's still a few trivial warnings from scripts/checkpatch.pl that
> should be fixed up:
Fixed that. Sorry for not running checkpatch.pl before submitting.

Before posting the last and hopefully final patch I'd like to know what
Jan says about open coding the lookup for ..
It will mean a lot of code duplication and I think it makes good sense
for udf_find_entry to be able to handle ..


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

