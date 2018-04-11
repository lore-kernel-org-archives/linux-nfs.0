Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53602 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752997AbeDKNji (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 11 Apr 2018 09:39:38 -0400
Subject: Re: [PATCH 2/2] Restore creating listening connection to server
 connections
To: Chuck Lever <chuck.lever@oracle.com>
Cc: libtirpc List <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <20180410213043.5545-1-steved@redhat.com>
 <20180410213043.5545-2-steved@redhat.com>
 <AEE2F42D-04C5-45AA-BC4B-773ED41B238E@oracle.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <565f3f27-4435-3bf4-3ebe-29f87cae9c8f@RedHat.com>
Date: Wed, 11 Apr 2018 09:39:37 -0400
MIME-Version: 1.0
In-Reply-To: <AEE2F42D-04C5-45AA-BC4B-773ED41B238E@oracle.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey,

On 04/10/2018 06:29 PM, Chuck Lever wrote:
> 
> 
>> On Apr 10, 2018, at 3:30 PM, Steve Dickson <steved@redhat.com> wrote:
>>
>> Commit 46e04a73 changed svc_com_create() to avoid using
>> reserve ports but removed the listen() call which
>> could break, undocumented expectations, of legacy
>> server apps.
>>
>> Reserve ports are not needed for listening ports, so
>> the new  __binddynport() is used to avoid squatting
>> on ports that are assigned to other network services,
>> but it is important to say backwards compatible
>> with the legacy glibc code so the the listen()
>> call is added back.
> 
> svc_tli_create should already perform a call to __binddynport()
> and to listen(2). That's why those calls were removed from
> svc_com_create().
> 
Fair enough... I did miss that call to svc_tli_create().

It appears the callers of svc_com_create() are no longer used
at least in nfs-utils. It appears to be the old SUN RPC API
and we using the TIRPC API.

steved.
