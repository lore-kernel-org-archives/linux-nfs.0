From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [pnfs] [PATCH RFC v2 0/21] nfs4xdr cleanup v2
Date: Mon, 17 Aug 2009 08:47:34 -0400
Message-ID: <1250513254.8475.20.camel@heimdal.trondhjem.org>
References: <4A8571E2.8020800@panasas.com>  <4A89338D.1040207@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Benny Halevy <bhalevy@panasas.com>,
	NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:5380 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751966AbZHQMru (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Aug 2009 08:47:50 -0400
In-Reply-To: <4A89338D.1040207@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-08-17 at 13:40 +0300, Boaz Harrosh wrote:
> * So I hate it that the READ32/WRITE32 is open coded. Now it looks like nothing, it
>   should have an xdr_encode/decode naming convention, all details hidden, consistent calling
>   convention with the reset of the code.

The convention is already established. Please see 15 years worth of
NFSv2/v3 xdr code. The NFSv4 code was the exception not the rule.

Now, it is obvious what we're doing: we're writing 32-bit big endian
encoded data into a memory buffer. Furthermore, the process of
converting from cpu ordered integers into 32-bit big endian is now made
obvious, making it easily verifiable both by inspection, and using
'sparse'.
Adding wrappers to do this, is just unnecessarily obfuscating the code.

> * I hate it that I have to count (p)"++" now to look for actual code advancements.

How is that _any_ different from counting WRITE32s?

> * I hate that it is called encode_hyper that a dum like me needs to look it up in the dictionary
>   "32" and "64" will do

I don't mind changing the name of xdr_encode_hyper() to
xdr_encode_uint64 or some such alternative, however the point is that we
should have only _one_ function that encodes 64 bit integers. Not one
function that everyone else uses, and then a macro that NFSv4 uses.

> * I hated it before, but I hate it even more now that the same operation is:
>   reserved(4); p + 1

Huh? What operation?

>   I wish it could be all __be32 everywhere

??? That's up to the protocol. If the protocol uses 32-bit integers,
then we can use __be32, but if it specifies a 64-bit big endian integer
in some structure, then we need to encode for that.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
