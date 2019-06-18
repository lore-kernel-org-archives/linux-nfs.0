Return-Path: <SRS0=MRfd=UR=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 80F89C31E5B
	for <linux-nfs@archiver.kernel.org>; Tue, 18 Jun 2019 20:27:28 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4E62320863
	for <linux-nfs@archiver.kernel.org>; Tue, 18 Jun 2019 20:27:28 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725909AbfFRU11 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 18 Jun 2019 16:27:27 -0400
Received: from zeniv.linux.org.uk ([195.92.253.2]:51764 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730607AbfFRU11 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Jun 2019 16:27:27 -0400
Received: from viro by ZenIV.linux.org.uk with local (Exim 4.92 #3 (Red Hat Linux))
        id 1hdKhN-0003PQ-66; Tue, 18 Jun 2019 20:27:21 +0000
Date:   Tue, 18 Jun 2019 21:27:21 +0100
From:   Al Viro <viro@zeniv.linux.org.uk>
To:     Christoph Hellwig <hch@lst.de>
Cc:     Andrew Morton <akpm@linux-foundation.org>,
        Sami Tolvanen <samitolvanen@google.com>,
        Kees Cook <keescook@chromium.org>,
        Nick Desaulniers <ndesaulniers@google.com>,
        linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 3/4] jffs2: pass the correct prototype to read_cache_page
Message-ID: <20190618202721.GD17978@ZenIV.linux.org.uk>
References: <20190520055731.24538-1-hch@lst.de>
 <20190520055731.24538-4-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190520055731.24538-4-hch@lst.de>
User-Agent: Mutt/1.11.3 (2019-02-01)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, May 20, 2019 at 07:57:30AM +0200, Christoph Hellwig wrote:
> Fix the callback jffs2 passes to read_cache_page to actually have the
> proper type expected.  Casting around function pointers can easily
> hide typing bugs, and defeats control flow protection.

FWIW, this
unsigned char *jffs2_gc_fetch_page(struct jffs2_sb_info *c,
                                   struct jffs2_inode_info *f,
                                   unsigned long offset,
                                   unsigned long *priv)
{
        struct inode *inode = OFNI_EDONI_2SFFJ(f);
        struct page *pg;

        pg = read_cache_page(inode->i_mapping, offset >> PAGE_SHIFT,
                             (void *)jffs2_do_readpage_unlock, inode);
        if (IS_ERR(pg))
                return (void *)pg;

        *priv = (unsigned long)pg;
        return kmap(pg);
}
looks like crap.  And so does this:
void jffs2_gc_release_page(struct jffs2_sb_info *c,
                           unsigned char *ptr,
                           unsigned long *priv)
{
        struct page *pg = (void *)*priv;

        kunmap(pg);
        put_page(pg);
}

	First of all, there's only one caller for each of those, and both
are direct calls.  So passing struct page * around that way is ridiculous.
What's more, there is no reason not to do kmap() in caller (i.e. in
jffs2_garbage_collect_dnode()).  That way jffs2_gc_fetch_page() would
simply be return read_cache_page(....), and in the caller we'd have

        struct page *pg;
        unsigned char *pg_ptr;
...
        mutex_unlock(&f->sem);
        pg = jffs2_gc_fetch_page(c, f, start);
        if (IS_ERR(pg)) {
		mutex_lock(&f->sem);
                pr_warn("read_cache_page() returned error: %ld\n", PTR_ERR(pg));
                return PTR_ERR(pg);
        }
	pg_ptr = kmap(pg);
	mutex_lock(&f->sem);
...
	kunmap(pg);
	put_page(pg);

and that's it, preserving the current locking and with saner types...
