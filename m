Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:42165 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759324Ab0HEUij convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Aug 2010 16:38:39 -0400
From: "Gilliam, PaulX J" <paulx.j.gilliam@intel.com>
To: Yudong Gao <stgyd@umich.edu>
CC: "linux-cachefs@redhat.com" <linux-cachefs@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Thu, 5 Aug 2010 13:38:37 -0700
Subject: RE: fscache.
Message-ID: <0A97A441BFADC74EA1E299A79C69DF9213F0FE8371@orsmsx504.amr.corp.intel.com>
References: <AANLkTi=2KYZ-8qaXMG=C_s617q3k1Ocs7h1gyd8=RpY6@mail.gmail.com>
 	<AANLkTimr9QfF0+MJ47hUihJgSLVOfquR=Atp4iV5D2gr@mail.gmail.com>
 	<97A00951-577C-4365-AA38-3C6E2D03B372@netapp.com>
 <AANLkTimi9CSa=XfoKBMCm-XAKcVQKVi0bEXgtA+XHexE@mail.gmail.com>
 	<1280956937.2865.13.camel@heimdal.trondhjem.org>
 <AANLkTi=FivAoO+Rqin82h885_8bj1=Ck5mjqPqV2rif4@mail.gmail.com>
 	<1280969564.2865.23.camel@heimdal.trondhjem.org>
 <AANLkTinq-q5f5QjCBiXuZMJY6dHajpDPZ7aO55ipNZcE@mail.gmail.com>
 	<1280971521.2865.30.camel@heimdal.trondhjem.org>
 <AANLkTinD=CVHU9wMhmKRZk4YgaA4kZ1bZVKn5DSNF2jr@mail.gmail.com>
 <AANLkTik4QjtVTZNovJOCFkCrsYrQcTD3qW-h-p0EXQgt@mail.gmail.com>
In-Reply-To: <AANLkTik4QjtVTZNovJOCFkCrsYrQcTD3qW-h-p0EXQgt@mail.gmail.com>
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Yudong,

There is a email list just for fscache, cachefiles and cachefs:
	linux-cachefs@redhat.com
It gets a lot less traffic than linux-nfs@vger.kernel.org and I don't know if one can find the same level of expertise monitoring it, I have seen David Howells there.  He is the author of fcache, cachefiles and cachefs.

-=# Paul Gilliam #=-


>-----Original Message-----
>From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
>owner@vger.kernel.org] On Behalf Of Yudong Gao
>Sent: Thursday, August 05, 2010 1:14 PM
>To: Trond Myklebust
>Cc: Andy Adamson; linux-nfs@vger.kernel.org
>Subject: Re: Write delegation
>
>Hi Trond,
>
>I just find the function nfs_fscache_set_inode_cookie() that checks
>the access flag and allows only read-only files to use the cache.
>
>Thanks!
>
>best,
>
>Yudong
>
>On Thu, Aug 5, 2010 at 11:10 AM, Yudong Gao <stgyd@umich.edu> wrote:
>> I see. I was kind of confused before. Sorry about that.
>>
>> I am trying to figure out how this read-only is supported in the
>> source code. When a page is read from the network through
>> nfs_readpage(), it will be cached to fscache, as implemented in
>> nfs_readpage_release(). The code in nfs_readpage_release() only checks
>> whether fscache is available, and if so, the page will be cached to
>> fscache.
>>
>> If a page is modified locally in memory (the page cache), then it
>> becomes dirty. But since the fscache is read-only, the copy of the
>> page in fscache becomes stale. When the file is close, the dirty page
>> will be written back to the server. Later when it is not used for a
>> while, it will be removed from the page cache. Here I suppose the copy
>> in fscache will not be deleted, or fscache becomes useless: it can
>> only mirror the pages in the page cache and does not provide extra
>> cache. And actually in the source code, I can not find the code to
>> uncache the page in fscache().
>>
>> So far so good. But if later this page is read again, the behavior
>> becomes strange. The nfs_readpage() checks first try to read the page
>> from fscache. In this case, it will read the stale page and oops!
>>
>> I think the problem here is that when a page become dirty in page
>> cache, it should be removed from fscache. So my question is where is
>> this implemented?
>>
>> Thanks a lot!
>>
>> best,
>>
>> Yudong
>>
>> On Wed, Aug 4, 2010 at 6:25 PM, Trond Myklebust
>> <trond.myklebust@fys.uio.no> wrote:
>>> On Wed, 2010-08-04 at 18:22 -0700, Yudong Gao wrote:
>>>
>>>> But for the integration with NFS, it is confusing. The
>>>> fscache_write_page() is called only in one place:
>>>> nfs_readpage_release(). So a NFS page is only written to fscache after
>>>> it is read from the server in nfs_readpage. So my question is, if a
>>>> page is locally modified, when its data is propagated to fscache? I
>>>> check the nfs_write_begin() and nfs_write_end() but cannot find any
>>>> relative implementation.
>>>
>>> See my previous answer. fscache only supports read-only files in NFS.
>>>
>>> Trond
>>>
>>>
>>
>--
>To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
