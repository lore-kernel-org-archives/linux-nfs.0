Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:44502 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753352Ab2EDInW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 May 2012 04:43:22 -0400
Message-ID: <4FA3969A.5080205@parallels.com>
Date: Fri, 4 May 2012 12:43:06 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH v3 0/2] SUNRPC: separate per-net data creation from service
References: <20120502120536.8794.22210.stgit@localhost.localdomain> <20120502215837.GA12089@fieldses.org> <20120503142735.GA16940@fieldses.org>
In-Reply-To: <20120503142735.GA16940@fieldses.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03.05.2012 18:27, J. Bruce Fields wrote:
> On Wed, May 02, 2012 at 05:58:37PM -0400, J. Bruce Fields wrote:
>> Thanks, applying.
>
> Whoops, no--I'm hitting the BUG at net/sunrpc/svc.c:558 (the first of
> the two BUG_ON()s in svc_destroy()) when restarting nfsd.  Could you
> look into this?
>

My fault. Sorry. Investigating.

> --b.
>
>>
>> --b.
>>
>> On Wed, May 02, 2012 at 04:08:29PM +0400, Stanislav Kinsbursky wrote:
>>> creation
>>>
>>> v3: "SUNRPC: new svc_bind() routine introduced" patch was squashed with the
>>>      "SUNRPC: check rpcbind clients usage counter before decrement" patch.
>>>
>>> v2: Increase per-net usage counted in lockd_up_net().
>>>
>>> This is a cleanup patch set.
>>> It will be followed my LockD start/stop cleanup patch set and NFS callback
>>> service containerization patch set (yes, I forgot to implement it).
>>>
>>> Today per-net data is created with service, and then is service is starting in
>>> other network namespace. And thus it's destroyed with service too. Moreover,
>>> network context for destroying of per-net data is taken from current process.
>>> This is correct, but code looks ugly.
>>> This patch set separates per-net data allocation from service allocation and
>>> destruction.
>>> IOW, per-net data have to be destroyed by service users - not service itself.
>>>
>>> BTW, NFSd code become uglier with this patch set. Sorry.
>>> But I assume, that these new ugly parts will be replaced later by NFSd service
>>> containerization code.
>>>
>>> The following series implements...
>>>
>>> ---
>>>
>>> Stanislav Kinsbursky (2):
>>>        SUNRPC: new svc_bind() routine introduced
>>>        SUNRPC: move per-net operations from svc_destroy()
>>>
>>>
>>>   fs/lockd/svc.c             |   33 +++++++++++++++++++++------------
>>>   fs/nfs/callback.c          |   11 +++++++++++
>>>   fs/nfsd/nfsctl.c           |    4 ++++
>>>   fs/nfsd/nfssvc.c           |   16 ++++++++++++++++
>>>   include/linux/sunrpc/svc.h |    1 +
>>>   net/sunrpc/rpcb_clnt.c     |   12 +++++++-----
>>>   net/sunrpc/svc.c           |   23 ++++++++++-------------
>>>   7 files changed, 70 insertions(+), 30 deletions(-)
>>>


-- 
Best regards,
Stanislav Kinsbursky
