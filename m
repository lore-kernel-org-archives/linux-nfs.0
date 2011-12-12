Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35825 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751810Ab1LLQEk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Dec 2011 11:04:40 -0500
Date: Mon, 12 Dec 2011 11:04:39 -0500
To: Benny Halevy <bhalevy@tonian.com>
Cc: Tigran Mkrtchyan <kofemann@googlemail.com>, linux-nfs@vger.kernel.org,
        Tigran Mkrtchyan <kofemann@gmail.com>
Subject: Re: [PATH v3 1/5] nfsd41: handle current stateid in open and close
Message-ID: <20111212160439.GE18185@fieldses.org>
References: <1323621708-25138-1-git-send-email-tigran.mkrtchyan@desy.de>
 <1323621708-25138-2-git-send-email-tigran.mkrtchyan@desy.de>
 <4EE61BE4.9060808@tonian.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4EE61BE4.9060808@tonian.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 12, 2011 at 05:21:08PM +0200, Benny Halevy wrote:
> On 2011-12-11 18:41, Tigran Mkrtchyan wrote:
> > @@ -1411,9 +1441,11 @@ static struct nfsd4_operation nfsd4_ops[] = {
> >  	},
> >  	[OP_CLOSE] = {
> >  		.op_func = (nfsd4op_func)nfsd4_close,
> > -		.op_flags = OP_MODIFIES_SOMETHING,
> > +		.op_flags = OP_MODIFIES_SOMETHING | CONSUMES_CURRENT_STATEID,
> 
> Looks like this also requires PROVIDES_CURRENT_STATEID
> (or just ditch the flag so there can't be disagreement between the two :)

Please, yes, let's just eliminate the redundant flags.

--b.
