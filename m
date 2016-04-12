Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:26014 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751181AbcDLUHU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Apr 2016 16:07:20 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: server commit commit 9d11b51ce7c1
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20160412200501.GA22336@fieldses.org>
Date: Tue, 12 Apr 2016 16:07:16 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <E2D584AA-8C50-47BE-ABEC-F8F24C74CA4B@oracle.com>
References: <6023A91E-B305-403D-8982-BF29265AEC2B@oracle.com> <20160412200501.GA22336@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Apr 12, 2016, at 4:05 PM, Bruce Fields <bfields@fieldses.org> wrote:
> 
> On Tue, Apr 12, 2016 at 03:32:18PM -0400, Chuck Lever wrote:
>> commit 9d11b51ce7c150a69e761e30518f294fc73d55ff
>> Author:     Chuck Lever <chuck.lever@oracle.com>
>> AuthorDate: Thu Jul 9 16:45:18 2015 -0400
>> Commit:     J. Bruce Fields <bfields@redhat.com>
>> CommitDate: Mon Jul 20 14:58:47 2015 -0400
>> 
>>    svcrdma: Fix send_reply() scatter/gather set-up
>> 
>> be applied to stable kernels? It is a small patch
>> that fixes a bug that has been in the NFS/RDMA
>> code since 2010.
> 
> Of course, anyone can mail a patch to stable@vger.kernel.org with a cc:
> to me, if you notice I overlooked something.

OK, I thought these patches always had to go through
the respective maintainers, though perhaps that is a
preference that is particular to each maintainer.

I will check it out.


--
Chuck Lever



