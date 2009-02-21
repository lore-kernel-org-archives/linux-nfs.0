From: Benny Halevy <bhalevy@panasas.com>
Subject: Ping: d_obtain_alias
Date: Sat, 21 Feb 2009 09:13:21 +0200
Message-ID: <499FA991.8080909@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Christoph?

On Feb. 16, 2009, 19:31 +0200, Benny Halevy <bhalevy@panasas.com> wrote:

Christoph,

I see that in 4ea3ada2955e4519befa98ff55dd62d6dfbd1705,
you declared d_obtain_alias() as EXPORT_SYMBOL_GPL
and that it's supposed to replace d_alloc_anon which
was declared as EXPORT_SYMBOL and thus available to any
loadable module.

Do you consider d_obtain_alias() an internal API?
What exported API non-GPL'ed loadable file systems are
supposed to use now for fh_to_dentry?

Benny
