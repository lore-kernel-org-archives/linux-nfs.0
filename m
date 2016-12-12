Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:33025 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753471AbcLLXQI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Dec 2016 18:16:08 -0500
Received: by mail-qt0-f193.google.com with SMTP id n6so11802788qtd.0
        for <linux-nfs@vger.kernel.org>; Mon, 12 Dec 2016 15:16:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161212215804.GB6002@fieldses.org>
References: <1481562529-4488-1-git-send-email-andros@netapp.com> <20161212215804.GB6002@fieldses.org>
From: Andy Adamson <androsadamson@gmail.com>
Date: Mon, 12 Dec 2016 18:16:06 -0500
Message-ID: <CAHVgHyU1kDKMwzAnzerjy7G3kL7wekt_n3qJ2Ub2EwF6kgy9jQ@mail.gmail.com>
Subject: Re: [PATCH Version 2] SVCAUTH update the rsc cache on RPC_GSS_PROC_DESTROY
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 12, 2016 at 4:58 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Mon, Dec 12, 2016 at 12:08:49PM -0500, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>>
>> The current code sets the expiry_time on the local copy of the rsc
>> cache entry - but not on the actual cache entry.
>
> I'm not following.  It looks to me like "rsci" in the below was returned
> from gss_svc_searchbyctx(), which was returned in turn from
> sunrpc_cache_lookup(), which is returning an item from the rsc cache--I
> don't see any copying.
>
>> Note that currently, the rsc cache entries are not cleaned up even
>> when nfsd is stopped.
>
> So, that sounds like a bug, but I don't understand this explanation yet.
>
>> Update the cache with the new expiry_time of now so that cache_clean will
>> clean up (free) the context to be destroyed.
>>
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>>  net/sunrpc/auth_gss/svcauth_gss.c | 32 ++++++++++++++++++++++++++++++--
>>  1 file changed, 30 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
>> index 45662d7..6033389 100644
>> --- a/net/sunrpc/auth_gss/svcauth_gss.c
>> +++ b/net/sunrpc/auth_gss/svcauth_gss.c
>> @@ -1393,6 +1393,26 @@ static void destroy_use_gss_proxy_proc_entry(struct net *net) {}
>>
>>  #endif /* CONFIG_PROC_FS */
>>
>> +static int rsc_destroy(struct sunrpc_net *sn, struct rsc *rscp)
>> +{
>> +     struct rsc new;
>> +     int ret = -ENOMEM;
>> +
>> +     memset(&new, 0, sizeof(struct rsc));
>> +     if (dup_netobj(&new.handle, &rscp->handle))
>> +             goto out;
>> +     new.h.expiry_time = get_seconds();
>> +     set_bit(CACHE_NEGATIVE, &new.h.flags);
>> +
>> +     rscp = rsc_update(sn->rsc_cache, &new, rscp);
>> +     if (!rscp)
>> +             goto out;
>> +     ret = 0;
>> +out:
>> +     rsc_free(&new);
>> +     return ret;
>> +}
>> +
>>  /*
>>   * Accept an rpcsec packet.
>>   * If context establishment, punt to user space
>> @@ -1489,10 +1509,18 @@ static void destroy_use_gss_proxy_proc_entry(struct net *net) {}
>>       case RPC_GSS_PROC_DESTROY:
>>               if (gss_write_verf(rqstp, rsci->mechctx, gc->gc_seq))
>>                       goto auth_err;
>> -             rsci->h.expiry_time = get_seconds();
>> -             set_bit(CACHE_NEGATIVE, &rsci->h.flags);
>> +             if (rsc_destroy(sn, rsci))
>> +                     goto drop;
>> +             /**
>> +              * Balance the cache_put at the end of svcauth_gss_accept.This
>> +              * will leave the refcount = 1 so that the cache_clean cache_put
>> +              * will call rsc_put.
>> +              */
>
> I'm confused by that comment.  If it's right, then it means the refcount
> is currently zero,

Didn't see this comment...

Nope.  "Balance the cache_put at the __end__ of svcauth_gss_accept".

Without the cache_get, the cache_put that gets called for all cases
handled by svcauth_gss_accept that return a non-null cache entry. So,
without this cache_get, the count would be 1, and the cache_put at the
end of svcauth_gss_accept would drop the count to zero, prompting
rsc_put and rsc_free to be called. This in turn makes the cache_put
called by cache_clean() go nuts as the refcount wraps around and
cache_put is then called 2^32 times!!

The RPCSEC_GSS_DESTROY case does not call the cache_get in svcauth_gss_accept:

svcauth_gss_accept()

.......

                svcdata->rsci = rsci;
                cache_get(&rsci->h);   <<<<<<<<<<<<<<<<<<<<<<<<<<<
here is the cache get not called in the DESTROY case.
                rqstp->rq_cred.cr_flavor = gss_svc_to_pseudoflavor(
                                        rsci->mechctx->mech_type,
                                        GSS_C_QOP_DEFAULT,
                                        gc->gc_svc);
                ret = SVC_OK;
                goto out;

        }
garbage_args:
        ret = SVC_GARBAGE;
        goto out;
auth_err:
        /* Restore write pointer to its original value: */
        xdr_ressize_check(rqstp, reject_stat);
        ret = SVC_DENIED;
        goto out;

complete:
        ret = SVC_COMPLETE;
        goto out;

drop:
        ret = SVC_DROP;
out:
        if (rsci)
                cache_put(&rsci->h, sn->rsc_cache);     <<<<<<<<<<<<
Here is the cache_put at the end
        return ret;

}


> in which case the following line is unsafe.

sorry for the unclear comments. I'll do a better job on the next version.

>
> --b.
>
>> +             cache_get(&rsci->h);
>> +
>>               if (resv->iov_len + 4 > PAGE_SIZE)
>>                       goto drop;
>> +
>>               svc_putnl(resv, RPC_SUCCESS);
>>               goto complete;
>>       case RPC_GSS_PROC_DATA:
>> --
>> 1.8.3.1
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
