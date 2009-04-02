From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH v2 40/47] nfsd41: cb_sequence callback
Date: Thu, 02 Apr 2009 22:34:55 +0300
Message-ID: <49D5135F.6040709@panasas.com>
References: <49CDDFC2.4070402@panasas.com> <1238229281-11516-1-git-send-email-bhalevy@panasas.com> <20090401043932.GC29339@fieldses.org> <49D47B9C.9030502@panasas.com> <20090402185107.GG5560@fieldses.org> <49D50FE8.8020303@panasas.com> <20090402192734.GI5560@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Ricardo Labiaga <ricardo.labiaga@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:26798 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753639AbZDBTfB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 15:35:01 -0400
In-Reply-To: <20090402192734.GI5560@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr. 02, 2009, 22:27 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> On Thu, Apr 02, 2009 at 10:20:08PM +0300, Benny Halevy wrote:
>> On Apr. 02, 2009, 21:51 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
>>> On Thu, Apr 02, 2009 at 11:47:24AM +0300, Benny Halevy wrote:
>>>> On Apr. 01, 2009, 7:39 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
>>>>>> @@ -503,6 +589,38 @@ nfsd4_probe_callback(struct nfs4_client *clp)
>>>>>>  	return;
>>>>>>  }
>>>>>>  
>>>>>> +#if defined(CONFIG_NFSD_V4_1)
>>>>>> +/*
>>>>>> + * FIXME: cb_sequence should support referring call lists, cachethis, and
>>>>>> + * multiple slots
>>>>>> + */
>>>>>> +static int
>>>>>> +nfs41_cb_sequence_setup(struct nfs4_client *clp, struct nfsd4_cb_sequence *args)
>>>>>> +{
>>>>>> +	u32 *ptr = (u32 *)clp->cl_sessionid.data;
>>>>>> +
>>>>>> +	dprintk("%s: %u:%u:%u:%u\n", __func__,
>>>>>> +		ptr[0], ptr[1], ptr[2], ptr[3]);
>>>>>> +
>>>>>> +	mutex_lock(&clp->cl_cb_mutex);
>>>>> We shouldn't be holding a mutex across a callback.  Why is this needed?
>>>> Just a simple way to limit concurrency to 1 and not deal with
>>>> multiple slots on the callback path.
>>> OK.  We should work out some sort of asynchronous equivalent.
>> OK.
>>
>>> How is the client side currently waiting on slots?
>> Currently it has a single slot and a single
>> (NFS41_BC_MIN_CALLBACKS) preallocated rpc_rqst.
>> If it gets more calls than that, concurrently, it will
>> drop its end of the line using 
>> set_bit(XPRT_CLOSE_WAIT, &xprt->state)
>>
>> (Ricardo, please keep me honest :)
> 
> I was wondering about the rpc client as used on the nfs client, not the

you mean rpc client as used on the nfs server? :)

> nfs client/callback server.
> 
> --b.
