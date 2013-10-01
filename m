Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:38361 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754834Ab3JABl6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Sep 2013 21:41:58 -0400
Message-ID: <524A2847.5080000@panasas.com>
Date: Mon, 30 Sep 2013 18:41:27 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Benny Halevy <bhalevy@primarydata.com>,
        Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC v0 05/49] pnfsd: introduce pnfsd header files
References: <52447EA0.7070004@primarydata.com> <1380220810-12909-1-git-send-email-bhalevy@primarydata.com> <20130929114327.GB25750@infradead.org> <52481939.7060405@primarydata.com> <20130929121345.GA21083@infradead.org> <52481B11.2080407@primarydata.com>
In-Reply-To: <52481B11.2080407@primarydata.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/29/2013 05:20 AM, Benny Halevy wrote:
> Makes sense.  Thanks.
>
> Bruce - are you ok with moving the pnfs interface definitions to
> include/linux/exportfs.h along with struct export_operations?
>

I disagree this is a bloat. It is big enough as it is. For code clarity
and maintenance we should split. Yes they are related but then
lots of stuff are related but we want to keep them separate compact
 and readable. why put everything in the same file, it does not make
any sense.

You have a library exportfs that exports a few related but different
interfaces, In fact this header is not exported from exportfs it is
the type system that defines the pnfs operations. They are so
big and verbose they call for a separate header.

> In fact we can actually extend struct export_operations rather
> than adding pnfs_export_operations...
>

This is a great waist of space. Any FS that does not support
pnfs, Which is currently all but exofs, will have 7 NULLs instead
of one.
And putting a struct pnfs_export_operations pointer inside
struct export_operations gives you nothing but an extra dereference
and funny looking code. Current system is just the most simple and
most efficient. Why the extra complexity?

> Benny

Cheers
Boaz


