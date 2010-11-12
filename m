From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 3/3] pnfs-submit: callbacks cannot use an nfs_client that
 is being freed
Date: Fri, 12 Nov 2010 12:08:15 +0200
Message-ID: <4CDD120F.9060203@panasas.com>
References: <1289484640-4100-1-git-send-email-andros@netapp.com>	<1289484640-4100-2-git-send-email-andros@netapp.com>	<1289484640-4100-3-git-send-email-andros@netapp.com>	<1289484640-4100-4-git-send-email-andros@netapp.com>	<4CDBEE06.1050309@panasas.com> <AANLkTi=55LGD+s+tg5d1wVyMdL9c-SmCguNLW_8veR8X@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: iisaman@netapp.com, linux-nfs@vger.kernel.org
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og111.obsmtp.com ([64.18.0.22]:47542 "HELO
	exprod5og111.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752891Ab0KLKIU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Nov 2010 05:08:20 -0500
In-Reply-To: <AANLkTi=55LGD+s+tg5d1wVyMdL9c-SmCguNLW_8veR8X-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2010-11-12 10:13, William A. (Andy) Adamson wrote:
> On Thu, Nov 11, 2010 at 8:22 AM, Benny Halevy <bhalevy@panasas.com> wrote:
>> On 2010-11-11 16:10, andros@netapp.com wrote:
>>> From: Andy Adamson <andros@netapp.com>
>>>
>>> Guarantee that the nfs_client exists when referenced to by callback processing
>>> by not procssing callbacks on an nfs_client in the process of being freed.
>>>
>>> Signed-off-by: Andy Adamson <andros@netapp.com>
>>> ---
>>>  fs/nfs/client.c |    8 ++++++--
>>>  1 files changed, 6 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> 
>>> index dbf43e7..86657ee 100644
>>> --- a/fs/nfs/client.c
>>> +++ b/fs/nfs/client.c
>>> @@ -392,7 +392,9 @@ struct nfs_client *nfs_find_client(const struct sockaddr *addr, u32 nfsversion)
>>>               if (!nfs_sockaddr_match_ipaddr(addr, clap))
>>>                       continue;
>>>
>>> -             atomic_inc(&clp->cl_count);
>>> +             /* Don't return an nfs_client that is being freed */
>>> +             if (!atomic_inc_not_zero(&clp->cl_count))
>>> +                     continue;
>>>               spin_unlock(&nfs_client_lock);
>>>               return clp;
>>>       }
>>> @@ -425,7 +427,9 @@ struct nfs_client *nfs_find_client_next(struct nfs_client *clp)
>>>               if (!nfs_sockaddr_match_ipaddr(sap, clap))
>>>                       continue;
>>>
>>> -             atomic_inc(&clp->cl_count);
>>> +             /* Don't return an nfs_client that is being freed */
>>> +             if (!atomic_inc_not_zero(&clp->cl_count))
>>> +                     continue;
>>>               spin_unlock(&nfs_client_lock);
>>>               return clp;
>>>       }
>>
>> Hmm, nfs_put_client deletes the client when cl_count reaches zero
>> so how can cl_count be zero while clp is listed?
> 
> 
> For some reason, I missed the lock part of atomic_dec_and_lock in
> nfs_put_client which removes the nfs_client from the list under the
> lock. We don't need this patch.
> 
> What's weird about the back channel server processing is that the RPC
> layer pg_authenticate (nfs_callback_authenticate) call in
> svc_process_common finds an nfs_client struct based solely the
> callback client address and so may find the wrong nfs_client struct
> (nfsv4.0 instead of v4.1, or wrong session). So the nfs_client has to
> be put at the end of pg_authenticate and another nfs_find_client call
> is needed in the dispatcher routines after decoding. This means the
> callback server could start processing a callback and have the
> nfs_client struct freed between the pg_authenticate call and the
> dispatcher operation call, or it could have found the wrong nfs_client
> in the first place.

Seems bad enough to fix :)

Benny

> 
> If the nfs_client is not found in pg_authenticate, the request is
> simply dropped (SVC_DROP). But if an nfs_client is not found in the
> dispatcher routines NFS4ERR_BADSESSION is returned for v4.1 requests
> and NFS4ERR_BADHANDLE for v4.0 requests.
> 
> I guess there's not much we can do about this.
> 
> -->Andy
> 
>> Benny
>>
>> In put_nfs_client
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
