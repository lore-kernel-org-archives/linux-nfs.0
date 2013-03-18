Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f50.google.com ([74.125.83.50]:61287 "EHLO
	mail-ee0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751893Ab3CRQpy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Mar 2013 12:45:54 -0400
Received: by mail-ee0-f50.google.com with SMTP id e51so2761908eek.23
        for <linux-nfs@vger.kernel.org>; Mon, 18 Mar 2013 09:45:52 -0700 (PDT)
Message-ID: <514744BD.6000205@tonian.com>
Date: Mon, 18 Mar 2013 18:45:49 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Mora, Jorge" <Jorge.Mora@netapp.com>,
        "Isaman, Fred" <Fred.Isaman@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] pnfs: do not reset to mds if wb_offset != wb_pgbase
References: <1363617532-24172-1-git-send-email-bhalevy@tonian.com>  <1363622128.4351.15.camel@leira.trondhjem.org> <51473F46.10401@tonian.com> <1363624756.4351.30.camel@leira.trondhjem.org>
In-Reply-To: <1363624756.4351.30.camel@leira.trondhjem.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-03-18 18:39, Myklebust, Trond wrote:
> On Mon, 2013-03-18 at 18:22 +0200, Benny Halevy wrote:
>> On 2013-03-18 17:55, Myklebust, Trond wrote:
>>> On Mon, 2013-03-18 at 16:38 +0200, Benny Halevy wrote:
>>>> We're seeing roughly 20% of the I/Os going to the MDS
>>>> when installing a VM over KVM in "none" caching mode (O_DIRECT).
>>>> Instrumenting the client reveled that this is caused by buffer
>>>> alignment vs. file offset alignment.
>>>> Besides being a performance problem, when the MDS caches data
>>>> this is also manifested as data corruption when data is written
>>>> first via the MDS, then via the DS, eventually the stale data is
>>>> read back from the MDS.
>>>
>>> That's why we should return the layout.
>>
>> We are not in this case.
> 
> Doh! I was thinking it was a case where we need to fence...
> 
> Actually, it shouldn't be needed: we will always do a _stable_ write of
> the data before we try to read it back in from the server, so MDS
> caching shouldn't be a problem.
> 

Writing stable to the MDS does not solve all cases.
The corruption we've seen happens like this:

write(A) to MDS
write(B) to DS
read(A) from MDS - since the MDS is caching the last data written to it.

>>>> Note that this check exists also for the file layout specific
>>>> pg_init_* functions.  The objects (ORE) and block
>>>> (bl_{read,write}_pagelist) layouts seem to deal correctly with
>>>> splitting IOs in the case where req->wb_offset != req->wb_pgbase
>>>> though this hasn't been tested wen submitting this patch.
>>>>
>>> NACK. I see no evidence that we've addressed the issues that were raised
>>> by Fred in commit 1825a0d08f22463e5a8f4b1636473efd057a3479 (NFS: prepare
>>> coalesce testing for directio).
>>> If you think that his concerns about the coalescing assumptions are no
>>> longer true, then please point to why this is the case. AFAICR that
>>> patch was added to fix corruption issues.
>>>
>>
>> We see no problems with this patch with the workloads we're testing.
>> Do you have a test that reproduces the original problem that we can try running?
> 
> I suspect it was one of the nfstests. (see
> git://git.linux-nfs.org/projects/mora/nfstest.git ) since Fred was
> working with Jorge to do the O_DIRECT testing.
> 
> Fred, Jorge?
> 
> 
