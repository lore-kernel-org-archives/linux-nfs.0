From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 1/5] NFS: Enable NFSv4 callback server to listen on AF_INET6 sockets
Date: Mon, 25 Aug 2008 12:16:00 -0400
Message-ID: <2E06E166-E115-4EA0-A6BC-F10F76673482@oracle.com>
References: <20080822163939.20488.92983.stgit@manray.1015granger.net> <20080822164201.20488.61180.stgit@manray.1015granger.net> <20080822231801.GA12995@fieldses.org> <76bd70e30808221934o22de4d51vca758957f565f256@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <trond.myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:60773 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753140AbYHYQRy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Aug 2008 12:17:54 -0400
In-Reply-To: <76bd70e30808221934o22de4d51vca758957f565f256-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug 22, 2008, at Aug 22, 2008, 10:34 PM, Chuck Lever wrote:
> On Fri, Aug 22, 2008 at 7:18 PM, J. Bruce Fields  
> <bfields@fieldses.org> wrote:
>> On Fri, Aug 22, 2008 at 12:42:02PM -0400, Chuck Lever wrote:
>>> Allow the NFS callback server to listen for requests via an AF_INET6
>>> or AF_INET socket.
>>>
>>> The NFS callback server determines the listener's address family  
>>> from
>>> the address the client uses to contact the server.  The server will
>>> always call the client back using the same address family.
>>
>> Won't the server determine that from the callback address which the
>> client provides in the setclientid?
>
> A client has to have IPv6 networking to mount an IPv6 server.
> Otherwise both will use IPv4.  Do you think we should worry about the
> case where a client provides a callback address in a different address
> family from the server's address?
>
> But I suppose it would be more precise to call nfs_callback_up() using
> the family of the passed-in clientaddr= mount option instead of the
> passed-in addr= option.  That will require discovering the address
> family of the clientaddr string.
>
> We could convert the clientaddr string into a sockaddr temporarily (we
> don't already do that... it's converted into a universal address
> string, but not into a sockaddr).

I thought about this more over the weekend.

We've got a similar problem here that we have with starting just a TCP  
or UDP listener for lockd based on what transport protocols were  
requested on the mount command line.

The NFSv4 callback server (and lockd, and probably NFSD) should start  
either a single AF_INET or a single AF_INET6 listener, not both.   
Right now, the callback server's address family is selected based on  
mount options for the first mount request.  But we only want one of  
these listeners for all mount points on a system, and it should be one  
that covers all the needed address families, no matter which address  
family was used during the first mount request.

So these services need to start a listener not based on mount options,  
but on what kind of networking is available on the host.  If IPV6 is  
available in the kernel, I think, an AF_INET6 listener should be  
started; otherwise, start an AF_INET listener.

I think the only externally visible issue with doing this is how  
addresses are presented in kernel log and error messages.  If the  
functions which generate presentation format address strings are smart  
enough to recognize a mapped IPv4 address and present it in dotted- 
quad format, that should be enough.

Thoughts/opinions?

>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>>
>>> fs/nfs/callback.c |   11 ++++++-----
>>> fs/nfs/callback.h |    4 ++--
>>> fs/nfs/client.c   |    2 +-
>>> 3 files changed, 9 insertions(+), 8 deletions(-)
>>>
>>> diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
>>> index 6a09760..59948ef 100644
>>> --- a/fs/nfs/callback.c
>>> +++ b/fs/nfs/callback.c
>>> @@ -97,7 +97,7 @@ nfs_callback_svc(void *vrqstp)
>>> /*
>>>  * Bring up the callback thread if it is not already up.
>>>  */
>>> -int nfs_callback_up(void)
>>> +int nfs_callback_up(const sa_family_t family)
>>> {
>>>      struct svc_serv *serv = NULL;
>>>      int ret = 0;
>>> @@ -106,7 +106,7 @@ int nfs_callback_up(void)
>>>      if (nfs_callback_info.users++ || nfs_callback_info.task !=  
>>> NULL)
>>>              goto out;
>>>      serv = svc_create(&nfs4_callback_program,  
>>> NFS4_CALLBACK_BUFSIZE,
>>> -                             AF_INET, NULL);
>>> +                             family, NULL);
>>>      ret = -ENOMEM;
>>>      if (!serv)
>>>              goto out_err;
>>> @@ -116,7 +116,8 @@ int nfs_callback_up(void)
>>>      if (ret <= 0)
>>>              goto out_err;
>>>      nfs_callback_tcpport = ret;
>>> -     dprintk("Callback port = 0x%x\n", nfs_callback_tcpport);
>>> +     dprintk("NFS: Callback listener port = %u (af %u)\n",
>>> +                     nfs_callback_tcpport, family);
>>>
>>>      nfs_callback_info.rqst = svc_prepare_thread(serv, &serv- 
>>> >sv_pools[0]);
>>>      if (IS_ERR(nfs_callback_info.rqst)) {
>>> @@ -149,8 +150,8 @@ out:
>>>      mutex_unlock(&nfs_callback_mutex);
>>>      return ret;
>>> out_err:
>>> -     dprintk("Couldn't create callback socket or server thread;  
>>> err = %d\n",
>>> -             ret);
>>> +     dprintk("NFS: Couldn't create callback socket or server  
>>> thread; "
>>> +             "err = %d\n", ret);
>>>      nfs_callback_info.users--;
>>>      goto out;
>>> }
>>> diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
>>> index bb25d21..85d8102 100644
>>> --- a/fs/nfs/callback.h
>>> +++ b/fs/nfs/callback.h
>>> @@ -63,10 +63,10 @@ extern __be32 nfs4_callback_getattr(struct  
>>> cb_getattrargs *args, struct cb_getat
>>> extern __be32 nfs4_callback_recall(struct cb_recallargs *args,  
>>> void *dummy);
>>>
>>> #ifdef CONFIG_NFS_V4
>>> -extern int nfs_callback_up(void);
>>> +extern int nfs_callback_up(const sa_family_t family);
>>> extern void nfs_callback_down(void);
>>> #else
>>> -#define nfs_callback_up()    (0)
>>> +#define nfs_callback_up(x)   (0)
>>> #define nfs_callback_down()  do {} while(0)
>>> #endif
>>>
>>> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
>>> index fc6a95d..5f8889f 100644
>>> --- a/fs/nfs/client.c
>>> +++ b/fs/nfs/client.c
>>> @@ -120,7 +120,7 @@ static struct nfs_client  
>>> *nfs_alloc_client(const struct nfs_client_initdata *cl_
>>>      clp->rpc_ops = cl_init->rpc_ops;
>>>
>>>      if (cl_init->rpc_ops->version == 4) {
>>> -             if (nfs_callback_up() < 0)
>>> +             if (nfs_callback_up(cl_init->addr->sa_family) < 0)
>>>                      goto error_2;
>>>              __set_bit(NFS_CS_CALLBACK, &clp->cl_res_state);
>>>      }
>>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux- 
>> nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>
>
>
> -- 
> "If you simplify your English, you are freed from the worst follies of
> orthodoxy."
> -- George Orwell
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




