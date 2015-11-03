Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:36833 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754187AbbKCCtg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Nov 2015 21:49:36 -0500
Received: by pacfv9 with SMTP id fv9so4590471pac.3
        for <linux-nfs@vger.kernel.org>; Mon, 02 Nov 2015 18:49:36 -0800 (PST)
Date: Mon, 2 Nov 2015 18:49:27 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
To: Boaz Harrosh <ooo@electrozaur.com>
cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Christoph Lameter <cl@linux.com>, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-mm@kvack.org, osd-dev@open-osd.org
Subject: Re: [PATCH] osd fs: __r4w_get_page rely on PageUptodate for
 uptodate
In-Reply-To: <5637437C.4070306@electrozaur.com>
Message-ID: <alpine.LSU.2.11.1511021813010.1013@eggly.anvils>
References: <alpine.LSU.2.11.1510291137430.3369@eggly.anvils> <5635E2B4.5070308@electrozaur.com> <alpine.LSU.2.11.1511011513240.11427@eggly.anvils> <5637437C.4070306@electrozaur.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2 Nov 2015, Boaz Harrosh wrote:
> On 11/02/2015 01:39 AM, Hugh Dickins wrote:
> <>
> >> This patch is not correct!
> > 
> > I think you have actually confirmed that the patch is correct:
> > why bother to test PageDirty or PageWriteback when PageUptodate
> > already tells you what you need?
> > 
> > Or do these filesystems do something unusual with PageUptodate
> > when PageDirty is set?  I didn't find it.
> > 
> 
> This is kind of delicate stuff. It took me a while to get it right
> when I did it. I don't remember all the details.
> 
> But consider this option:

Thanks, yes, it helps to have a concrete example in front of us.

> 
> exofs_write_begin on a full PAGE_CACHE_SIZE, the page is instantiated
> new in page-cache is that PageUptodate(page) then? I thought not.

Right, PageUptodate must not be set until the page has been filled with
the correct data.  Nor is PageDirty or PageWriteback set at this point,
actually.

Once page is filled with the correct data, either exofs_write_end()
(which uses simple_write_end()) or (internally) exofs_commit_chunk()
is called.

> (exofs does not set that)

It's simple_write_end() or exofs_commit_chunk() which SetPageUptodate
in this case.  And after that each calls set_page_dirty(), which does
the SetPageDirty, before unlocking the page which was supplied locked
by exofs_write_begin().

So I don't see where the page is PageDirty without being PageUptodate.

> 
> Now that page I do not want to read in. The latest data is in memory.
> (Same when this page is in writeback, dirty-bit is cleared)

Understood, but that's what PageUptodate is for.

(Quite what happens if there's a write error is not so clear: I think
that typically PageError gets set and PageUptodate cleared, to read
back in from disk what's actually there - but lose the data we wanted
to write; but I can understand different filesystems making different
choices there, and didn't study exofs's choice.)

> 
> So for sure if page is dirty or writeback then we surly do not need a read.
> only if not then we need to consider the  PageUptodate(page) state.

PageUptodate is the proper flag to check, to ask if the page contains
the correct data: there is no need to consider Dirty or Writeback.

> 
> Do you think the code is actually wrong as is?

Not that I know of: just a little too complicated and confusing.

But becomes slightly wrong if my simplification to page migration
goes through, since that introduces an instant when PageDirty is set
before the new page contains the correct data and is marked Uptodate.
Hence my patch.

> 
> BTW: Very similar code is in fs/nfs/objlayout/objio_osd.c::__r4w_get_page

Indeed, the patch makes the same adjustment to that code too.

> 
> > Thanks,
> > Hugh
> > 
> <>
> 
> Thanks
> Boaz
