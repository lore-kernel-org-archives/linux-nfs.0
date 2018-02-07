Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2120.oracle.com ([141.146.126.78]:44188 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750726AbeBGV7p (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Feb 2018 16:59:45 -0500
Subject: Re: [PATCH] nfs: system crashes after NFS4ERR_MOVED recovery
To: Trond Myklebust <trondmy@primarydata.com>,
        "Anna.Schumaker@Netapp.com" <Anna.Schumaker@Netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
References: <307dc174-b2d0-461a-fc76-193711f150d2@Oracle.com>
 <1518037638.56541.2.camel@primarydata.com>
 <1518038401.56541.6.camel@primarydata.com>
From: Bill Baker <Bill.Baker@Oracle.com>
Message-ID: <f62ee109-ef13-22e6-b2c8-9348e8c356b6@Oracle.com>
Date: Wed, 7 Feb 2018 16:00:02 -0600
MIME-Version: 1.0
In-Reply-To: <1518038401.56541.6.camel@primarydata.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/07/2018 03:20 PM, Trond Myklebust wrote:
> On Wed, 2018-02-07 at 16:07 -0500, Trond Myklebust wrote:
>> Hi Bill,
>>
>> On Wed, 2018-02-07 at 14:53 -0600, Bill Baker wrote:
>>> nfs4_update_server unconditionally releases the nfs_client for the
>>> source server. If migration fails, this can cause the source
>>> server's
>>> nfs_client struct to be left with a low reference count, resulting
>>> in
>>> use-after-free.
>>>
<snip>
>> That looks almost right. Isn't there now a reference leak if
>> nfs4_set_client() returns -ELOOP? I think that is really down to an
>> existing bug in nfs4_set_client() rather than in your fix, however
> 
> Sorry... I should probably have been more explicit about where the bug
> is: nfs4_set_client() should probably be calling nfs_put_client() on
> its copy of 'clp' before returning -ELOOP.
> 
>> the
>> fix does re-expose that bug.
> 
> By which I mean that the two bugs currently cancel each other out for
> the case of ELOOP. By fixing one bug, but not the other, we're undoing
> the cancellation... ☺

Hi Trond,

Thank you for your quick feedback, let me go do some more inspection.



-- 
Bill Baker - Oracle Linux NFS
