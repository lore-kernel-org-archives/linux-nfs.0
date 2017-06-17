Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:23111 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751995AbdFQRX6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Jun 2017 13:23:58 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v2 19/19] sunrpc: Disable splice for krb5i
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170617150705.GA27917@infradead.org>
Date: Sat, 17 Jun 2017 13:23:24 -0400
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <A573E1EB-48DB-4E4A-B710-34914B0CF016@oracle.com>
References: <20170616151535.14210.34926.stgit@klimt.1015granger.net> <20170616152254.14210.48071.stgit@klimt.1015granger.net> <20170617150705.GA27917@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jun 17, 2017, at 11:07 AM, Christoph Hellwig <hch@infradead.org> wrote:
> 
> On Fri, Jun 16, 2017 at 11:22:54AM -0400, Chuck Lever wrote:
>> Running a multi-threaded 8KB fio test (70/30 mix), three or four out
>> of twelve of the jobs fail when using krb5i. The failure is an EIO
>> on a read.
> 
> Just curious: what is the backing fs that you tested with?  I'd be
> curious if you see this on XFS for example.

I was able to reproduce this with a tmpfs share and
with an XFS share on NVMe LUNs.


--
Chuck Lever



