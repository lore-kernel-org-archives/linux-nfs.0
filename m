Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:55739 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752274Ab2EKLEx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 May 2012 07:04:53 -0400
Message-ID: <4FACF249.8050305@parallels.com>
Date: Fri, 11 May 2012 15:04:41 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH 0/6] Lockd: service start cleanup patch set
References: <20120425141934.22909.53047.stgit@localhost6.localdomain6> <20120509190855.GB27077@fieldses.org>
In-Reply-To: <20120509190855.GB27077@fieldses.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09.05.2012 23:08, J. Bruce Fields wrote:
> On Wed, Apr 25, 2012 at 06:22:32PM +0400, Stanislav Kinsbursky wrote:
>> This patch set simplifies LockD start logic, makes code looks straight-forward
>> and clear.
>
> I've applied and pushed these out.
>
> I believe I now have everything from you except your latest grace-period
> handling rfc.  Could you check and make sure that I'm not missing
> anything else, and that I haven't messed up anything else?
>

Looks like you took all except patches for Trond (NFS callback containerization).
Thanks.


> --b.
>
>>
>> The following series consists of:
>>
>> ---
>>
>> Stanislav Kinsbursky (6):
>>        LockD: pass service to per-net up and down functions
>>        LockD: use existent per-net data function on service creation
>>        LockD: service creation function introduced
>>        LockD: move global usage counter manipulation from error path
>>        LockD: service start function introduced
>>        LockD: add debug message to start and stop functions
>>
>>
>>   fs/lockd/svc.c |  140 +++++++++++++++++++++++++++++++++-----------------------
>>   1 files changed, 83 insertions(+), 57 deletions(-)
>>


-- 
Best regards,
Stanislav Kinsbursky
