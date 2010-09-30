Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:43457 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753188Ab0I3I0Y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Sep 2010 04:26:24 -0400
Message-ID: <4CA449AE.4020809@panasas.com>
Date: Thu, 30 Sep 2010 10:26:22 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Steve Dickson <SteveD@redhat.com>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: pnfs git tree status pnfs-all-2.6.36-rc6-2010-09-29
References: <4C7BDD8C.40509@panasas.com> <4CA31DC3.8070300@panasas.com> <4CA3C1E2.2050701@RedHat.com>
In-Reply-To: <4CA3C1E2.2050701@RedHat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-09-30 00:46, Steve Dickson wrote:
> 
> 
> On 09/29/2010 07:06 AM, Benny Halevy wrote:
>> This version includes Fred's pnfs-submit RFC patches (v5).
>> and is rebased onto v2.6.36-rc6
>>
>> Cumulative patches can be generated from
>> git://linux-nfs.org/~bhalevy/linux-pnfs.git
>> using
>> git diff v2.6.36-rc6 pnfs-all-2.6.36-rc6-2010-09-29
>>
> So only the 2.6.36-rc kernels are being supported? 
> No 2.6.35 kernels?

Latest and greatest for 2.6.35 is at pnfs-all-2.6.35-2010-09-14

One patch merged since pnfs-all-2.6.35-2010-08-24:

	Benny Halevy be619de5 pnfs: mark commit data as PNFS_NO_RPC in pnfs_try_to_commit

> 
> steved.
