Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:9432 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753068AbaJVTdQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Oct 2014 15:33:16 -0400
Message-ID: <54480679.70501@Netapp.com>
Date: Wed, 22 Oct 2014 15:33:13 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>, Chuck Lever <chuck.lever@oracle.com>,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] nfsd4: fix response size estimation for OP_SEQUENCE
References: <20141017212446.GC3474@fieldses.org> <20141021103631.GB21863@infradead.org> <20141021131406.GE9863@fieldses.org> <20141022192258.GB5552@fieldses.org>
In-Reply-To: <20141022192258.GB5552@fieldses.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/22/14 15:22, J. Bruce Fields wrote:
> On Tue, Oct 21, 2014 at 09:14:06AM -0400, J. Bruce Fields wrote:
>> Also my tests are failing due to an unrelated crash in 18-rc1 which I
>> want to track down before sending this in.
> 
> There are two bugs:
> 
> 	- the client is sending SEEK over minorversion 1.
> 	- this sometimes causes the server to crash.
> 
> I'm testing a fix for the latter.
> 
> On the former: looks like if 4.2 support is built in, then llseek is set
> to nfs4_file_llseek, which unconditionally calls nfs42_proc_llseek().
> 
> Does nfs4_file_llseek need an explicit minorversion check, or should it
> be handled some other way?

The client should be checking for CAP_SEEK, which should only be set on NFS v4.2.  I'll look into this!
> 
> --b.
> 

