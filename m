From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Ping: d_obtain_alias
Date: Sat, 21 Feb 2009 11:49:01 -0800 (PST)
Message-ID: <alpine.LFD.2.00.0902211146400.3111@localhost.localdomain>
References: <499FA991.8080909@panasas.com> <20090221174046.GA27374@infradead.org> <20090221114015.7bb5c9d8.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Christoph Hellwig <hch@infradead.org>,
	Benny Halevy <bhalevy@panasas.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20090221114015.7bb5c9d8.akpm@linux-foundation.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On Sat, 21 Feb 2009, Andrew Morton wrote:
> 
> Here's the patch in question:

.. or perhaps 9308a6128d9074e348d9f9b5822546fe12a794a9, which actually did 
the "Remove d_alloc_anon now that no users are left.".

I do agree - if people are now expected to convert from d_alloc_anon() to 
d_obtain_alias(), then we can't just go and change license requirements 
under them. 

Some religious argument doesn't change that, or override technical 
reasoning. If people are still using d_alloc_anon(), we should either 
re-export it, or just export d_obtain_alias() in a usable form for them.

		Linus
