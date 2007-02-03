From: Brad Boyer <flar@allandria.com>
Subject: Re: [PATCH 3/14] locks: factor out generic/filesystem switch from setlock code
Date: Sat, 3 Feb 2007 13:27:50 -0800
Message-ID: <20070203212750.GA2678@cynthia.pants.nu>
References: <ad8373acbb12f165b625f6065bc0ca86f3982b7f.1170479265.git.bfields@citi.umich.edu> <1dd47bf9aeb6f19c82a59efb2f4236f23f73019d.1170479265.git.bfields@citi.umich.edu> <20070203085136.GC18828@infradead.org> <20070203051638.GA29763@cynthia.pants.nu> <20070204083731.GA29531@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070204083731.GA29531@infradead.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Sun, Feb 04, 2007 at 08:37:32AM +0000, Christoph Hellwig wrote:
> In general we want everything that's internal to be _GPL, and a symbol
> that's only for use in the lock manager falls under that category.

OK. I guess I misunderstood the purpose of the function. Thank you
for your explanation. It looked more generic than that based on a
quick read of the patch.

	Brad Boyer
	flar@allandria.com

