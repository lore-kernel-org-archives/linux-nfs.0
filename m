From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH] EXPORT_SYMBOL(d_obtain_alias) rather than EXPORT_SYMBOL_GPL
Date: Tue, 24 Feb 2009 12:11:42 -0800
Message-ID: <49A4547E.90607@panasas.com>
References: <499FA991.8080909@panasas.com> <20090221174046.GA27374@infradead.org> <20090221114015.7bb5c9d8.akpm@linux-foundation.org> <alpine.LFD.2.00.0902211146400.3111@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Al Viro <viro@zeniv.linux.org.uk>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.0902211146400.3111@localhost.localdomain>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 4ea3ada2955e4519befa98ff55dd62d6dfbd1705
declares d_obtain_alias() as EXPORT_SYMBOL_GPL
where it's supposed to replace d_alloc_anon which
was previously declared as EXPORT_SYMBOL and thus
available to any loadable module.

This patch reverts that, as discussed below:

On Feb. 21, 2009, 11:40 -0800, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Sat, 21 Feb 2009 12:40:46 -0500 Christoph Hellwig <hch@infradead.org> wrote:
...
>> All the nfs exported filesystem are tied intimately to the kernel,
>> so yes, this is an internal export.
>>
>> Non-GPL filesystem are illegal to distribute anyway, so I don't know why
>> you even bother.
>>
>
> Here's the patch in question:
...
> Neither the title nor the changelog mentioned anything about disabling
> non-GPL filesystems, so this effect was a mistake.  I didn't know this
> was the effect and I doubt if Linus knew and quite possibly Christoph
> and Al didn't know either.
>
> We should correct that mistake.  Afterwards, feel free to prepare and
> send out a patch titled "[patch] disable non-GPL filesystems" and we
> can discuss it.

On Feb. 21, 2009, 11:49 -0800, Linus Torvalds <torvalds@linux-foundation.org> wrote:
>
> On Sat, 21 Feb 2009, Andrew Morton wrote:
>> Here's the patch in question:
>
> .. or perhaps 9308a6128d9074e348d9f9b5822546fe12a794a9, which actually did
> the "Remove d_alloc_anon now that no users are left.".
>
> I do agree - if people are now expected to convert from d_alloc_anon() to
> d_obtain_alias(), then we can't just go and change license requirements
> under them.
>
> Some religious argument doesn't change that, or override technical
> reasoning. If people are still using d_alloc_anon(), we should either
> re-export it, or just export d_obtain_alias() in a usable form for them.
>
> 		Linus

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/dcache.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 937df0f..07e2d4a 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -1180,7 +1180,7 @@ struct dentry *d_obtain_alias(struct inode *inode)
 	iput(inode);
 	return res;
 }
-EXPORT_SYMBOL_GPL(d_obtain_alias);
+EXPORT_SYMBOL(d_obtain_alias);
 
 /**
  * d_splice_alias - splice a disconnected dentry into the tree if one exists
-- 
1.6.1.3


