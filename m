Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60626 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751576Ab1CQRo6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Mar 2011 13:44:58 -0400
Date: Thu, 17 Mar 2011 13:44:53 -0400
To: NeilBrown <neilb@suse.de>
Cc: peter.staubach@emc.com, Trond.Myklebust@netapp.com, bjschuma@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: Use of READDIRPLUS on large directories
Message-ID: <20110317174453.GC30180@fieldses.org>
References: <20110316155528.31913c58@notabene.brown>
 <5E6794FC7B8FCA41A704019BE3C70E8B068397B4@MX31A.corp.emc.com>
 <20110317084038.6d4ea49d@notabene.brown>
 <20110317115522.29020461@notabene.brown>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110317115522.29020461@notabene.brown>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Mar 17, 2011 at 11:55:22AM +1100, NeilBrown wrote:
> Strangely, when I try NFSv4 I don't get what I would expect.
> 
> "ls" on an unpatched 2.6.38 takes over 5 seconds rather than around 4.
> With the patch it does back down to about 2. (still NFSv3 at 1.5).
> Why would NFSv4 be slower?
>  On v3 we make 44 READDIRPLUS calls and 284 READDIR calls - total of  328
>        READDIRPLUS have about 30 names, READDIR have about 100
>  On v4 we make 633 READDIR calls - nearly double.
>        Early packed contain about 19 name, later ones about 70
> 
> Is nfsd (2.6.32) just not packing enough answers in the reply?
> Client asks for a dircount of 16384 and a maxcount of 32768, and gets
> packets which are about 4K long - I guess that is PAGE_SIZE ??

>From nfsd4_encode_readdir():

	maxcount = PAGE_SIZE;
	if (maxcount > readdir->rd_maxcount)
		maxcount = readdir->rd_maxcount;

Unfortunately, I don't think the xdr encoding is equipped to deal with
page boundaries.  It should be.

--b.
