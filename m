Return-Path: <schumaker.anna@gmail.com>
Sender: Anna Schumaker <schumakeranna@gmail.com>
Subject: Re: [PATCH 2/2] NFS: nfs_rename() - revalidate directories on
 -ERESTARTSYS
To: Benjamin Coddington <bcodding@redhat.com>,
 Jeff Layton <jlayton@redhat.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
 Anna Schumaker <anna.schumaker@netapp.com>, mszeredi@redhat.com,
 bfields@redhat.com, linux-nfs@vger.kernel.org
References: <cover.1497541002.git.bcodding@redhat.com>
 <32ef5d3ded4fe75bb6fc6e1a1aebdd0297257d9e.1497541002.git.bcodding@redhat.com>
 <1497550694.4607.10.camel@redhat.com>
 <1497553607.4607.13.camel@poochiereds.net>
 <4D7B208E-553B-4170-8081-12DE3881A04C@redhat.com>
 <1497558869.4607.15.camel@redhat.com>
 <C3B2B67D-E66B-431B-A77F-F0171741A75E@redhat.com>
From: Anna Schumaker <schumaker.anna@gmail.com>
Message-ID: <d501e58f-8f58-701e-1b4a-959a7a695665@gmail.com>
Date: Thu, 15 Jun 2017 17:06:48 -0400
MIME-Version: 1.0
In-Reply-To: <C3B2B67D-E66B-431B-A77F-F0171741A75E@redhat.com>
Content-Type: text/plain; charset=utf-8
List-ID: <linux-nfs.vger.kernel.org>



On 06/15/2017 04:57 PM, Benjamin Coddington wrote:
> On 15 Jun 2017, at 16:34, Jeff Layton wrote:
> 
>> Yeah, I think a smp_wmb() there, paired with the implied barrier in the
>> atomic_dec_and_test in rpc_put_task?
> 
> Yes, that should do it.
> 
>>>>> No need for a whole int for a flag and these do get allocated. Make
>>>>> it a
>>>>> bool?
>>>
>>> or
>>>
>>> unsigned int : 1
>>>
>>> which seems to be often used -- see nfs4_opendata.  The cancelled flag
>>> could
>>> be changed there as well I suppose.
>>
>> I'd prefer a bool, but it's really up to Trond and Anna, I suppose.
> 
> If Anna or Trond will tell us how they'd like it, I can follow up with a
> patch to make them all consistent.

My preference is for a bool

Anna

> 
> Ben
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
