Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:55045 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932205Ab2EIVEV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 May 2012 17:04:21 -0400
Message-ID: <4FAADBD3.7020109@parallels.com>
Date: Thu, 10 May 2012 01:04:19 +0400
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
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

09.05.2012 23:08, J. Bruce Fields написал:
> On Wed, Apr 25, 2012 at 06:22:32PM +0400, Stanislav Kinsbursky wrote:
>> This patch set simplifies LockD start logic, makes code looks straight-forward
>> and clear.
> I've applied and pushed these out.
>
> I believe I now have everything from you except your latest grace-period
> handling rfc.  Could you check and make sure that I'm not missing
> anything else, and that I haven't messed up anything else?

Sure, Bruce.
I'll check and reply in few days.

> --b.
>
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

