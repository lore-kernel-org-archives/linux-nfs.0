Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33130 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755274AbbKCPkH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Nov 2015 10:40:07 -0500
Received: by pabfh17 with SMTP id fh17so21551730pab.0
        for <linux-nfs@vger.kernel.org>; Tue, 03 Nov 2015 07:40:06 -0800 (PST)
Date: Tue, 3 Nov 2015 07:39:53 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
To: Boaz Harrosh <boaz@plexistor.com>
cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Christoph Lameter <cl@linux.com>, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-mm@kvack.org, osd-dev@open-osd.org
Subject: Re: [PATCH] osd fs: __r4w_get_page rely on PageUptodate for
 uptodate
In-Reply-To: <56387D3C.5020003@plexistor.com>
Message-ID: <alpine.LSU.2.11.1511030734300.1856@eggly.anvils>
References: <alpine.LSU.2.11.1510291137430.3369@eggly.anvils> <5635E2B4.5070308@electrozaur.com> <alpine.LSU.2.11.1511011513240.11427@eggly.anvils> <5637437C.4070306@electrozaur.com> <alpine.LSU.2.11.1511021813010.1013@eggly.anvils>
 <56387D3C.5020003@plexistor.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 3 Nov 2015, Boaz Harrosh wrote:
> On 11/03/2015 04:49 AM, Hugh Dickins wrote:
> > On Mon, 2 Nov 2015, Boaz Harrosh wrote:
> >>
> >> Do you think the code is actually wrong as is?
> > 
> > Not that I know of: just a little too complicated and confusing.
> > 
> > But becomes slightly wrong if my simplification to page migration
> > goes through, since that introduces an instant when PageDirty is set
> > before the new page contains the correct data and is marked Uptodate.
> > Hence my patch.
> > 
> >>
> >> BTW: Very similar code is in fs/nfs/objlayout/objio_osd.c::__r4w_get_page
> > 
> > Indeed, the patch makes the same adjustment to that code too.
> > 
> 
> OK thanks. Let me setup and test your patch. On top of 4.3 is good?
> I'll send you a tested-by once I'm done.

Great, thanks Boaz, that will help a lot.  On top of 4.3 very good.

(Of course, that will not test the rare page migration race I shall
introduce later; but it will test that you're doing the right thing
with this change at your end, when you will be safe against the race.)

Hugh
