Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:35496 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753720AbbKBLFg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Nov 2015 06:05:36 -0500
Message-ID: <5637437C.4070306@electrozaur.com>
Date: Mon, 02 Nov 2015 13:05:32 +0200
From: Boaz Harrosh <ooo@electrozaur.com>
MIME-Version: 1.0
To: Hugh Dickins <hughd@google.com>
CC: Andrew Morton <akpm@linux-foundation.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Christoph Lameter <cl@linux.com>, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-mm@kvack.org, osd-dev@open-osd.org
Subject: Re: [PATCH] osd fs: __r4w_get_page rely on PageUptodate for uptodate
References: <alpine.LSU.2.11.1510291137430.3369@eggly.anvils> <5635E2B4.5070308@electrozaur.com> <alpine.LSU.2.11.1511011513240.11427@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1511011513240.11427@eggly.anvils>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/02/2015 01:39 AM, Hugh Dickins wrote:
<>
>> This patch is not correct!
> 
> I think you have actually confirmed that the patch is correct:
> why bother to test PageDirty or PageWriteback when PageUptodate
> already tells you what you need?
> 
> Or do these filesystems do something unusual with PageUptodate
> when PageDirty is set?  I didn't find it.
> 

This is kind of delicate stuff. It took me a while to get it right
when I did it. I don't remember all the details.

But consider this option:

exofs_write_begin on a full PAGE_CACHE_SIZE, the page is instantiated
new in page-cache is that PageUptodate(page) then? I thought not.
(exofs does not set that)

Now that page I do not want to read in. The latest data is in memory.
(Same when this page is in writeback, dirty-bit is cleared)

So for sure if page is dirty or writeback then we surly do not need a read.
only if not then we need to consider the  PageUptodate(page) state.

Do you think the code is actually wrong as is?

BTW: Very similar code is in fs/nfs/objlayout/objio_osd.c::__r4w_get_page

> Thanks,
> Hugh
> 
<>

Thanks
Boaz

