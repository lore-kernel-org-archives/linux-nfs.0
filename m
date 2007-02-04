From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 3/14] locks: factor out generic/filesystem switch from setlock code
Date: Sun, 4 Feb 2007 08:37:32 +0000
Message-ID: <20070204083731.GA29531@infradead.org>
References: <ad8373acbb12f165b625f6065bc0ca86f3982b7f.1170479265.git.bfields@citi.umich.edu> <1dd47bf9aeb6f19c82a59efb2f4236f23f73019d.1170479265.git.bfields@citi.umich.edu> <20070203085136.GC18828@infradead.org> <20070203051638.GA29763@cynthia.pants.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	Marc Eshel <eshel@almaden.ibm.com>
To: Brad Boyer <flar@allandria.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070203051638.GA29763@cynthia.pants.nu>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Fri, Feb 02, 2007 at 09:16:38PM -0800, Brad Boyer wrote:
> Any particular reason?

In general we want everything that's internal to be _GPL, and a symbol
that's only for use in the lock manager falls under that category.

