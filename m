Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:47467 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751278AbdJEIg7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 5 Oct 2017 04:36:59 -0400
Date: Thu, 5 Oct 2017 10:36:57 +0200
From: Jan Kara <jack@suse.cz>
To: linux-nfs@vger.kernel.org, linux-mm@kvack.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Subject: Why is NFS using a_ops->freepage?
Message-ID: <20171005083657.GA28132@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

I'm doing some work in page cache handling and I have noticed that NFS is
the only user of mapping->a_ops->freepage callback. From a quick look I
don't see why isn't NFS using ->releasepage / ->invalidatepage callback as
all other filesystems do? I agree you would have to set PagePrivate bit for
those to get called for the directory mapping however that would seem like
a cleaner thing to do anyway - in fact you do have private data in the
page.  Just they are not pointed to by page->private but instead are stored
as page data... Am I missing something?

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
