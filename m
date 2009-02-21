From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Ping: d_obtain_alias
Date: Sat, 21 Feb 2009 12:40:46 -0500
Message-ID: <20090221174046.GA27374@infradead.org>
References: <499FA991.8080909@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <499FA991.8080909@panasas.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


All the nfs exported filesystem are tied intimately to the kernel,
so yes, this is an internal export.

Non-GPL filesystem are illegal to distribute anyway, so I don't know why
you even bother.

On Sat, Feb 21, 2009 at 09:13:21AM +0200, Benny Halevy wrote:
> Christoph?
> 
> On Feb. 16, 2009, 19:31 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
> 
> Christoph,
> 
> I see that in 4ea3ada2955e4519befa98ff55dd62d6dfbd1705,
> you declared d_obtain_alias() as EXPORT_SYMBOL_GPL
> and that it's supposed to replace d_alloc_anon which
> was declared as EXPORT_SYMBOL and thus available to any
> loadable module.
> 
> Do you consider d_obtain_alias() an internal API?
> What exported API non-GPL'ed loadable file systems are
> supposed to use now for fh_to_dentry?
> 
> Benny
---end quoted text---
