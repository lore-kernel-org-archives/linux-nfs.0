Return-Path: linux-nfs-owner@vger.kernel.org
Received: from sentry-two.sandia.gov ([132.175.109.14]:35758 "EHLO
	sentry-two.sandia.gov" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750811Ab3E3Uvs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 May 2013 16:51:48 -0400
Message-ID: <51A7BBC8.9050300@sandia.gov>
Date: Thu, 30 May 2013 14:51:20 -0600
From: "Jim Schutt" <jaschut@sandia.gov>
MIME-Version: 1.0
To: "Chuck Lever" <chuck.lever@oracle.com>
cc: "Trond Myklebust" <Trond.Myklebust@netapp.com>,
        "Weston Andros Adamson" <dros@netapp.com>,
        "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>,
        "LKML Kernel" <linux-kernel@vger.kernel.org>
Subject: Re: 3.10-rc3 NFSv3 mount issues
References: <51A7B442.9010108@sandia.gov>
 <D74C8145-AD4D-4CFE-963C-643B8D7DBA10@oracle.com>
In-Reply-To: <D74C8145-AD4D-4CFE-963C-643B8D7DBA10@oracle.com>
Content-Type: text/plain;
 charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/30/2013 02:26 PM, Chuck Lever wrote:
> 
> On May 30, 2013, at 4:19 PM, Jim Schutt <jaschut@sandia.gov> wrote:
> 
>> Hi,
>>
>> I've been trying to test 3.10-rc3 on some diskless clients, and found
>> that I can no longer mount my root file system via NFSv3.
>>

> 
> 3.10-rc3 appears to be missing the fix for this.  See:
> 
>   http://marc.info/?l=linux-nfs&m=136855668104598&w=2
> 
> Trond, can we get this applied?
> 

That works for me.

Thanks!

-- Jim


