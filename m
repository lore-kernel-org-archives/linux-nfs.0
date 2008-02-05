From: Rasmus Rohde <rohde-3mLe3WyXyAE@public.gmane.org>
Subject: Re: [NFS] [PATCH] Make UDF exportable
Date: Tue, 05 Feb 2008 20:26:01 +0100
Message-ID: <1202239561.12188.53.camel__20803.9172729061$1202239667$gmane$org@localhost.localdomain>
References: <1201726404.2976.8.camel@localhost.localdomain>
	<20080205102955.GA28347@infradead.org>
	<1202233464.12188.43.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-fsdevel@vger.kernel.org, jack@suse.cz,
	nfs@lists.sourceforge.net
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:46876 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756881AbYBET0j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Feb 2008 14:26:39 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JMTRA-0006KA-EM
	for linux-nfs@vger.kernel.org; Wed, 06 Feb 2008 06:26:32 +1100
In-Reply-To: <1202233464.12188.43.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> +static struct dentry *udf_fh_to_parent(struct super_block *sb,
> +				       struct fid *fid, int fh_len, int fh_type)
> +{
> +	if (fh_len != 5 || fh_type != FILEID_UDF_WITHOUT_PARENT)
                                                   ^^^^^^^

Argh - this should have been WITH so the line reads:

if (fh_len != 5 || fh_type != FILEID_UDF_WITH_PARENT)

I'll just hold back a little reposting a new patch if other comments
should happen to show up.


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

