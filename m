Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([209.198.142.2]:56026 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754417Ab2ALTha (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Jan 2012 14:37:30 -0500
Message-ID: <4F0F3679.7090304@opengridcomputing.com>
Date: Thu, 12 Jan 2012 13:37:29 -0600
From: Tom Tucker <tom@opengridcomputing.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Dan Carpenter <dan.carpenter@oracle.com>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: Re: [patch] svcrdma: endian bug in send_write_chunks()
References: <20120112064722.GB2408@elgon.mountain>   <20120112162141.GC6563@fieldses.org>  <1326395759.6198.7.camel@lade.trondhjem.org>  <4F0F3380.4000406@opengridcomputing.com> <1326396510.6198.12.camel@lade.trondhjem.org>
In-Reply-To: <1326396510.6198.12.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 1/12/12 1:28 PM, Trond Myklebust wrote:
> On Thu, 2012-01-12 at 13:24 -0600, Tom Tucker wrote:
>> On 1/12/12 1:15 PM, Trond Myklebust wrote:
>>> On Thu, 2012-01-12 at 11:21 -0500, J. Bruce Fields wrote:
>>>> On Thu, Jan 12, 2012 at 09:47:22AM +0300, Dan Carpenter wrote:
>>>>> Sparse complains because arg_ch->rs_length is declared as network
>>>>> endian but we're treating it as CPU endian.
>>>> This looks like it would actually change behavior on a little endian
>>>> architecture, so how did this work before?
>>>>
>>>>>  From some quick grepping, I see assignments both of the form
>>>> 	...rs_length = ntohl(...)
>>>>
>>>> and
>>>>
>>>> 	...rs_length = htonl(...)
>>>>
>>>> but only see one declaration for a field named rs_length.
>>>>
>>>> So my best guess would be that the code is ugly but working as is, and
>>>> needs cleanup by someone who knows how this field was intended to be
>>>> used.
>>> It looks to me as if rs_handle and rs_offset are being similarly abused.
>>> Basically, we need a serious clean up in svc_rdma_marshall.c to separate
>>> out those variables that are in XDR-encoded form and those that are not.
>>>
>> The abuse is taking place because the marshal/unmarshall is being done
>> in-place and it seemed wasteful at the time to add a chunk of memory to
>> preserve the aesthetic. A union would 'work', but you still wouldn't
>> 'know' whether the data was NBO or not by where it was -- which seems like
>> the intent of the __beXX in the first place.
> These are not variables that are used in hundreds of different places:
> why not just do the conversion from big-endian to cpu-endian when you
> actually need to use them?

That would work fine actually. At the time, I was trying to put all that 
marshalling logic in that one file and reuse the already present 
client-side header file that copies that stuff when it decodes it.

I'll dig around a little bit and see what might be the simplest way to 
clean this up.

Tom


