Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43666 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933129AbcHaL7s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 31 Aug 2016 07:59:48 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Paolo Abeni" <pabeni@redhat.com>
Cc: netdev@vger.kernel.org,
        "Trond Myklebust" <trond.myklebust@primarydata.com>,
        "Anna Schumaker" <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "Jeff Layton" <jlayton@poochiereds.net>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        "Jan Stancek" <jstancek@redhat.com>
Subject: Re: [PATCH net] sunrpc: fix UDP memory accounting
Date: Wed, 31 Aug 2016 07:59:44 -0400
Message-ID: <6E1705D6-2E2A-4924-83C4-E90CBCFBBBB1@redhat.com>
In-Reply-To: <1472643951.4775.6.camel@redhat.com>
References: <32a391a2469b4161dc2375c6b6374b8229b3dd37.1472126188.git.pabeni@redhat.com>
 <F9224521-4FC7-4647-8BB8-C92A841EE23D@redhat.com>
 <1472643951.4775.6.camel@redhat.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 31 Aug 2016, at 7:45, Paolo Abeni wrote:

> On Tue, 2016-08-30 at 12:28 -0400, Benjamin Coddington wrote:
>> On 25 Aug 2016, at 12:42, Paolo Abeni wrote:
>>
>>> The commit f9b2ee714c5c ("SUNRPC: Move UDP receive data path
>>> into a workqueue context"), as a side effect, moved the
>>> skb_free_datagram() call outside the scope of the related socket
>>> lock, but UDP sockets require such lock to be held for proper
>>> memory accounting.
>>> Fix it by replacing skb_free_datagram() with
>>> skb_free_datagram_locked().
>>>
>>> Fixes: f9b2ee714c5c ("SUNRPC: Move UDP receive data path into a
>>> workqueue context")
>>> Reported-and-tested-by: Jan Stancek <jstancek@redhat.com>
>>> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
>>
>> Thanks for finding this. A similar fix in 2009 for svcsock.c was done by
>> Eric Dumazet:
>> 9d410c796067 ("net: fix sk_forward_alloc corruption")
>>
>> skb_free_datagram_locked() is used for all xprt types in svcsock.c,
>> should we use
>> it for the xs_local_transport as well in xprtsock.c?
>
> AFAICS a similar fix is _not_ needed for xs_local_transport(), since it
> uses AF_LOCAL sockets and such family does not support protocol's memory
> accounting.

This fixes the WARNING reported by Jan Stancek here:
http://marc.info/?l=linux-nfs&m=146616830928019&w=2

Reviewed-by: Benjamin Coddington <bcodding@redhat.com>

Ben
