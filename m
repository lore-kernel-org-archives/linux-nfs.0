From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] [PATH 08/19] jfs: new export ops
Date: Mon, 10 Sep 2007 15:45:33 -0400
Message-ID: <20070910194533.GA18793@fieldses.org>
References: <20070830131632.GI6834@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org,
	Neil Brown <neilb@suse.de>
To: Christoph Hellwig <hch@lst.de>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070830131632.GI6834@lst.de>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Thu, Aug 30, 2007 at 03:16:32PM +0200, Christoph Hellwig wrote:
> Trivial switch over to the new generic helpers.
> -	    	result = ERR_PTR(-ESTALE);
> -		goto out_iput;
> +		iput(inode);
> +	    	return ERR_PTR(-ESTALE);

For some reason you're introducing a bunch of whitespace damage on lines
like that last one.  Would you mind running these through checkpatch.pl
or whatever and then resending?

Other than that I can't find any problem, and it seems like an obvious
improvement, though I'd like to see Neil take a look.  Do you want these
added to the nfsd patches for 2.6.24?

--b.
