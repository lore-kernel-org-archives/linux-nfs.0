Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f176.google.com ([209.85.192.176]:38527 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932234AbaJVUMe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Oct 2014 16:12:34 -0400
Received: by mail-pd0-f176.google.com with SMTP id fp1so4144927pdb.7
        for <linux-nfs@vger.kernel.org>; Wed, 22 Oct 2014 13:12:34 -0700 (PDT)
References: <20141017212446.GC3474@fieldses.org> <20141021103631.GB21863@infradead.org> <20141021131406.GE9863@fieldses.org> <20141022192258.GB5552@fieldses.org> <20141022194257.GC5552@fieldses.org>
Mime-Version: 1.0 (1.0)
In-Reply-To: <20141022194257.GC5552@fieldses.org>
Content-Type: text/plain;
	charset=us-ascii
Message-Id: <57662446-E474-4420-84F5-349B6B85119F@primarydata.com>
Cc: Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Christoph Hellwig <hch@infradead.org>
From: Tom Haynes <thomas.haynes@primarydata.com>
Subject: Re: [PATCH] nfsd4: fix response size estimation for OP_SEQUENCE
Date: Wed, 22 Oct 2014 13:12:12 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>




> On Oct 22, 2014, at 12:42 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
>> On Wed, Oct 22, 2014 at 03:22:58PM -0400, J. Bruce Fields wrote:
>>> On Tue, Oct 21, 2014 at 09:14:06AM -0400, J. Bruce Fields wrote:
>>> Also my tests are failing due to an unrelated crash in 18-rc1 which I
>>> want to track down before sending this in.
>> 
>> There are two bugs:
>> 
>>    - the client is sending SEEK over minorversion 1.
>>    - this sometimes causes the server to crash.
>> 
>> I'm testing a fix for the latter.
>> 
>> On the former: looks like if 4.2 support is built in, then llseek is set
>> to nfs4_file_llseek, which unconditionally calls nfs42_proc_llseek().
>> 
>> Does nfs4_file_llseek need an explicit minorversion check, or should it
>> be handled some other way?
> 
> By the way, a purely theoretical issue for now, but: on unknown
> operations the server returns either NFS4ERR_OP_ILLEGAL or
> NFS4ERR_OP_NOTSUPP depending on whether we think it's in the range of
> defined nfs4.2 operations.
> 
> That means that if a revision of the 4.2 draft adds a new operation
> beyond the current end (OP_WRITE_SAME = 70), a client would need to be
> prepared for old servers returning OP_ILLEGAL to that operation.
> 

Or if the new minor versioning rules take effect...



> Freezing the definitions of the ops and attributes we care about may not
> be quite enough to make implementing-as-we-go-along work?
> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
