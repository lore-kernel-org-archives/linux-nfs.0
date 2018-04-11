Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33212 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752351AbeDKOH5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 11 Apr 2018 10:07:57 -0400
Subject: Re: [Libtirpc-devel] [PATCH 1/2] Restore using reserve ports for
 client connections
To: Thorsten Kukuk <kukuk@suse.de>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        libtirpc List <libtirpc-devel@lists.sourceforge.net>
References: <20180410213043.5545-1-steved@redhat.com>
 <1E130010-3BB3-4BB8-9521-1B6096BC615B@oracle.com>
 <44316a1b-82ff-261c-b691-31b5621fb4e7@RedHat.com>
 <20180411125903.GA28242@suse.de>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <f6415818-a74f-b496-49aa-16243c23f806@RedHat.com>
Date: Wed, 11 Apr 2018 10:07:23 -0400
MIME-Version: 1.0
In-Reply-To: <20180411125903.GA28242@suse.de>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/11/2018 08:59 AM, Thorsten Kukuk wrote:
> On Wed, Apr 11, Steve Dickson wrote:
> 
>>
>> Hey,
>>
>> On 04/10/2018 06:17 PM, Chuck Lever wrote:
>>>
>>>
>>>> On Apr 10, 2018, at 3:30 PM, Steve Dickson <steved@redhat.com> wrote:
>>>>
>>>> Commit 46e04a73 changed both clnt_com_create()
>>>> and clnt_tli_create() to avoid using reserve ports when
>>>> creating connection to the server.
>>>>
>>>> For certain legacy apps, the client has to used
>>>> reserve port to be able to communicate with its
>>>> server so using of reserve ports is restored.
>>>
>>> Hi Steve-
>>>
>>> Which legacy apps use clnt_tli_create and require this behavior?
>> yphelper, yppush and ypxfr via the clnt_create() call. At least
>> that's all I have found so far.
> 
Add rpcinfo to this list... Its used in the remote call code.

steved.

> Yes, and I need to change that like Solaris is doing it, only a
> question of time on my side :(
> 
>   Thorsten
> 
