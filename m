Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43360 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751888AbdFOU50 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 15 Jun 2017 16:57:26 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Jeff Layton" <jlayton@redhat.com>
Cc: "Trond Myklebust" <trond.myklebust@primarydata.com>,
        "Anna Schumaker" <anna.schumaker@netapp.com>, mszeredi@redhat.com,
        bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] NFS: nfs_rename() - revalidate directories on
 -ERESTARTSYS
Date: Thu, 15 Jun 2017 16:57:23 -0400
Message-ID: <C3B2B67D-E66B-431B-A77F-F0171741A75E@redhat.com>
In-Reply-To: <1497558869.4607.15.camel@redhat.com>
References: <cover.1497541002.git.bcodding@redhat.com>
 <32ef5d3ded4fe75bb6fc6e1a1aebdd0297257d9e.1497541002.git.bcodding@redhat.com>
 <1497550694.4607.10.camel@redhat.com>
 <1497553607.4607.13.camel@poochiereds.net>
 <4D7B208E-553B-4170-8081-12DE3881A04C@redhat.com>
 <1497558869.4607.15.camel@redhat.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 15 Jun 2017, at 16:34, Jeff Layton wrote:

> Yeah, I think a smp_wmb() there, paired with the implied barrier in the
> atomic_dec_and_test in rpc_put_task?

Yes, that should do it.

>>>> No need for a whole int for a flag and these do get allocated. Make
>>>> it a
>>>> bool?
>>
>> or
>>
>> unsigned int : 1
>>
>> which seems to be often used -- see nfs4_opendata.  The cancelled flag
>> could
>> be changed there as well I suppose.
>
> I'd prefer a bool, but it's really up to Trond and Anna, I suppose.

If Anna or Trond will tell us how they'd like it, I can follow up with a
patch to make them all consistent.

Ben
