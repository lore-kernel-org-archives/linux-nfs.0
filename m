Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:35445 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751608AbaAGOmI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Jan 2014 09:42:08 -0500
Message-ID: <52CC123C.7000806@netapp.com>
Date: Tue, 7 Jan 2014 09:42:04 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/3] READ_PLUS rough draft
References: <1389045433-22990-1-git-send-email-Anna.Schumaker@netapp.com> <20140106223201.GA3342@fieldses.org>
In-Reply-To: <20140106223201.GA3342@fieldses.org>
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/06/2014 05:32 PM, J. Bruce Fields wrote:
> On Mon, Jan 06, 2014 at 04:57:10PM -0500, Anna Schumaker wrote:
>> These patches are my initial implementation of READ_PLUS.  I still have a
>> few issues to work out before they can be applied, but I wanted to submit
>> them anyway to get feedback before going much further.  These patches were
>> developed on top of my earlier SEEK and WRITE_PLUS patches, and probably
>> won't apply cleanly without them (I am willing to reorder things if necessary!).
>>
>> On the server side, I handle the cases where a file is 100% hole, 100% data
>> or hole followed by data.  Any holes after a data segment will be expanded
>> to zeros on the wire.
> 
> I assume that for "a file" I should read "the requested range of the
> file"?

Yes.

> 
> hole+data+hole should also be doable, shouldn't it?  I'd think the real
> problem would be multiple data extents.

It might be, but I haven't tried it yet.  I can soon!

> 
>> This is due to a limitation in the the NFSD
>> encode-to-page function that will adjust pointers to point to the xdr tail
>> after reading a file to the "pages" section.  Bruce, do you have any
>> suggestions here?
> 
> The server xdr encoding needs a rewrite.  I'll see if I can ignore you
> all and put my head down and get a version of that posted this week.

:)

> 
> That should make it easier to return all the data, though it will turn
> off zero-copy in the case of multiple data extents.
> 
> If we want READ_PLUS to support zero copy in the case of multiple
> extents then I think we need a new data structure to represent the
> resulting rpc reply.  An xdr buf only knows how to insert one array of
> pages in the middle of the data.  Maybe a list of xdr bufs?
> 
> But that's an annoying job and possibly a premature optimization.
> 
> It might be useful to first understand the typical distribution of holes
> in a file and how likely various workloads are to produce reads with
> multiple holes in the middle.

I already have a few performance numbers, but nothing that can be trusted due to the number of debugging printk()s I used to make sure the client decoded everything correctly.  My plan is to collect the following information using:  v4.0, v4.1, v4.2 (SEEK), v4.2 (SEEK + WRITE_PLUS), and v4.2 (SEEK + WRITE_PLUS + READ_PLUS).

Anna

> 
> --b.
> 
>>
>> The client side needs to punch holes after decoding page information, since
>> data on pages will be aligned at the start of the page array.  So a file that
>> is <HOLE><DATA> will store the hole information, decode the data, and then
>> punch the hole before returning.  I think it would be better to use the
>> provided offset field to decode everything to their final locations, but I'm
>> struggling to come up with a clean way of doing so using the code that is
>> already there.
>>
>> Let me know what you all think!
>> Anna
>>
>> Anna Schumaker (3):
>>   NFSD: Implement READ_PLUS support
>>   SUNRPC: This patch adds functions for shifting page data
>>   NFS: Client side changes for READ_PLUS
>>
>>  fs/nfs/nfs4client.c        |   2 +-
>>  fs/nfs/nfs4proc.c          |  23 +++++-
>>  fs/nfs/nfs4xdr.c           | 191 +++++++++++++++++++++++++++++++++++++++++++++
>>  fs/nfsd/Kconfig            |  14 ++++
>>  fs/nfsd/nfs4proc.c         |   9 +++
>>  fs/nfsd/nfs4xdr.c          | 177 ++++++++++++++++++++++++++++++++++++-----
>>  include/linux/nfs4.h       |   1 +
>>  include/linux/nfs_fs_sb.h  |   1 +
>>  include/linux/sunrpc/xdr.h |   1 +
>>  net/sunrpc/xdr.c           | 115 ++++++++++++++++++++++++++-
>>  10 files changed, 511 insertions(+), 23 deletions(-)
>>
>> -- 
>> 1.8.5.2
>>

