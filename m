Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx142.netapp.com ([216.240.21.19]:3904 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754193AbbBEQxn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Feb 2015 11:53:43 -0500
Message-ID: <54D3A015.7040207@Netapp.com>
Date: Thu, 5 Feb 2015 11:53:41 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Christoph Hellwig <hch@infradead.org>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 2/4] NFSD: Add READ_PLUS support for data segments
References: <1422477777-27933-1-git-send-email-Anna.Schumaker@Netapp.com> <1422477777-27933-3-git-send-email-Anna.Schumaker@Netapp.com> <20150205141325.GC4522@infradead.org> <54D394EC.9030902@Netapp.com> <20150205162326.GA18977@infradead.org> <54D39DC2.9060808@Netapp.com> <20150205164832.GB4289@fieldses.org>
In-Reply-To: <20150205164832.GB4289@fieldses.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/05/2015 11:48 AM, J. Bruce Fields wrote:
> On Thu, Feb 05, 2015 at 11:43:46AM -0500, Anna Schumaker wrote:
>> On 02/05/2015 11:23 AM, Christoph Hellwig wrote:
>>> On Thu, Feb 05, 2015 at 11:06:04AM -0500, Anna Schumaker wrote:
>>>>> If the READ_PLUS implementation can't use the splice read path it's
>>>>> probably a loss for most workloads.
>>>>>
>>>>
>>>> I'll play around with the splice path, but I don't think it was designed for encoding multiple read segments.
>>>
>>> The problem is that the typical case of all data won't use splice
>>> every with your patches as the 4.2 client will always send a READ_PLUS.
>>>
>>> So we'll have to find a way to use it where it helps.  While we might be
>>> able to add some hacks to only use splice for the first segment I guess
>>> we just need to make the splice support generic enough in the long run.
>>>
>>
>> I should be able to use splice if I detect that we're only returning a single DATA segment easily enough.
> 
> Oh, good thought, yes maybe that would be enough.
> 
> But I still wish he had more evidence here.

I'm planning to do some performance testing with this change:

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index e2a4702..f516694 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3876,7 +3876,10 @@ nfsd4_encode_read_plus_data(struct nfsd4_compoundres *resp, struct nfsd4_read *r
        maxcount = min_t(unsigned long, maxcount, read->rd_length);
        maxcount = min_t(unsigned long, maxcount, hole_pos - read->rd_offset);
 
-       err = nfsd4_encode_readv(resp, read, file, &maxcount);
+       if ((read->rd_offset == 0) && (read->rd_length == maxcount))
+               err = nfsd4_encode_splice_read(resp, read, file, &maxcount);
+       else
+               err = nfsd4_encode_readv(resp, read, file, &maxcount);
 
        *p++ = cpu_to_be32(NFS4_CONTENT_DATA);
        p = xdr_encode_hyper(p, read->rd_offset);

> 
> --b.
> 

