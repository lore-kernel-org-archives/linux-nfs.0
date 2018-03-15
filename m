Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2130.oracle.com ([141.146.126.79]:32820 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750950AbeCOBSV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Mar 2018 21:18:21 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [PATCH 11/15] nfsd: Record request byte count, not count of
 vectors
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180314205250.GC7241@fieldses.org>
Date: Wed, 14 Mar 2018 21:18:03 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <32694019-887A-42AB-B8D1-0F98B905C642@oracle.com>
References: <20180313154053.21531.86316.stgit@klimt.1015granger.net>
 <20180313154437.21531.89300.stgit@klimt.1015granger.net>
 <20180314205250.GC7241@fieldses.org>
To: Bruce Fields <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Mar 14, 2018, at 4:52 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> On Tue, Mar 13, 2018 at 11:44:37AM -0400, Chuck Lever wrote:
>> 	TP_fast_assign(
>> 		__entry->xid = be32_to_cpu(rqstp->rq_xid);
>> -		do {
>> -			struct knfsd_fh fh;
>> -
>> -			fh_copy_shallow(&fh, &fhp->fh_handle);
>> -			__entry->fh_hash = knfsd_fh_hash(&fh);
>> -		} while (0);
>> +		__entry->fh_hash = knfsd_fh_hash(&fhp->fh_handle);
>> 		__entry->offset = offset;
>> 		__entry->len = len;
>> 	),
> 
> What's that about?  Why did someone originally think we needed to copy
> before hashing?

No idea. I can't find any reason why copying the FH would be necessary.
It's not as if the FH will change while the trace point is computing
the hash.

--
Chuck Lever



