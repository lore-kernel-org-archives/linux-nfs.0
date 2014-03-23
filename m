Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f178.google.com ([209.85.223.178]:64777 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751263AbaCWNYb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 23 Mar 2014 09:24:31 -0400
Received: by mail-ie0-f178.google.com with SMTP id lx4so4212750iec.23
        for <linux-nfs@vger.kernel.org>; Sun, 23 Mar 2014 06:24:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <52CB793A.1040501@gmail.com>
References: <52CA8460.6030206@gmail.com>
	<20140106202024.GD31764@fieldses.org>
	<52CB793A.1040501@gmail.com>
Date: Sun, 23 Mar 2014 21:24:31 +0800
Message-ID: <CAB6yy36XqHUw-xddMtDx6MBazBQTbfG0v5ujf5pC0mjmgm=HBQ@mail.gmail.com>
Subject: Re: [PATCH] SUNRPC: fix memory leak of peer addresses in XPRT
From: Kinglong Mee <kinglongmee@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dear Bruce,

what's the status of this patch?

thanks,
Kinglong Mee


On Tue, Jan 7, 2014 at 11:49 AM, Kinglong Mee <kinglongmee@gmail.com> wrote:
> On 01/07/2014 04:20 AM, J. Bruce Fields wrote:
>> On Mon, Jan 06, 2014 at 06:24:32PM +0800, Kinglong Mee wrote:
>>> If creating xprt failed after xs_format_peer_addresses,
>>> sunrpc must free those memory of peer addresses in xprt.
>>>
>>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>>> ---
>>>  net/sunrpc/xprtsock.c | 11 +++++++++--
>>>  1 file changed, 9 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
>>> index 25dbfa9..11ceba3 100644
>>> --- a/net/sunrpc/xprtsock.c
>>> +++ b/net/sunrpc/xprtsock.c
>>> @@ -2725,8 +2725,10 @@ static struct rpc_xprt *xs_setup_local(struct xprt_create *args)
>>>              xprt_set_bound(xprt);
>>>              xs_format_peer_addresses(xprt, "local", RPCBIND_NETID_LOCAL);
>>>              ret = ERR_PTR(xs_local_setup_socket(transport));
>>> -            if (ret)
>>> +            if (ret) {
>>> +                    xs_free_peer_addresses(xprt);
>>>                      goto out_err;
>>> +            }
>>>              break;
>>>      default:
>>>              ret = ERR_PTR(-EAFNOSUPPORT);
>>> @@ -2738,6 +2740,8 @@ static struct rpc_xprt *xs_setup_local(struct xprt_create *args)
>>>
>>>      if (try_module_get(THIS_MODULE))
>>>              return xprt;
>>> +
>>> +    xs_free_peer_addresses(xprt);
>>>      ret = ERR_PTR(-EINVAL);
>>>  out_err:
>>>      xprt_free(xprt);
>>
>> This is getting a little hairy.... Looks like xprts are alloc'd with
>> kzalloc() and xs_free_peer_addresses is a no-op if
>> xprt->address_strings[i] is NULL, so it looks safe to call
>> unconditionally after out_err?
>>
>>> @@ -2816,6 +2820,8 @@ static struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
>>>
>>>      if (try_module_get(THIS_MODULE))
>>>              return xprt;
>>> +
>>> +    xs_free_peer_addresses(xprt);
>>>      ret = ERR_PTR(-EINVAL);
>>>  out_err:
>>>      xprt_free(xprt);
>>> @@ -2893,9 +2899,10 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
>>>                              xprt->address_strings[RPC_DISPLAY_ADDR],
>>>                              xprt->address_strings[RPC_DISPLAY_PROTO]);
>>>
>>> -
>>>      if (try_module_get(THIS_MODULE))
>>>              return xprt;
>>> +
>>> +    xs_free_peer_addresses(xprt);
>>>      ret = ERR_PTR(-EINVAL);
>>>  out_err:
>>>      xprt_free(xprt);
>>> --
>>> 1.8.4.2
>>
>> And after this we'll end up with
>>
>>       xs_free_peer_addresses(xprt);
>>       xprt_free(xprt);
>>
>> in 4 different places (the above plus xs_destroy), so I might define an
>> xs_xprt_free() to do that.
>
> I have make a new patch as your suggestion.
>
> thanks,
> Kinglong Mee
>
> From 9a53cfcf2c6c9dafeace28ea0c3ac9b3e786412e Mon Sep 17 00:00:00 2001
> From: Kinglong Mee <kinglongmee@gmail.com>
> Date: Tue, 7 Jan 2014 11:43:59 +0800
> Subject: [PATCH] SUNRPC: fix memory leak of peer addresses in XPRT
>
> If creating xprt failed after xs_format_peer_addresses,
> sunrpc must free those memory of peer addresses in xprt.
>
> Add a helper function for freeing xprt named xs_xprt_free.
>
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  net/sunrpc/xprtsock.c | 18 +++++++++++-------
>  1 file changed, 11 insertions(+), 7 deletions(-)
>
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 25dbfa9..4fcdf74 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -905,6 +905,12 @@ static void xs_tcp_close(struct rpc_xprt *xprt)
>                 xs_tcp_shutdown(xprt);
>  }
>
> +static void xs_xprt_free(struct rpc_xprt *xprt)
> +{
> +       xs_free_peer_addresses(xprt);
> +       xprt_free(xprt);
> +}
> +
>  /**
>   * xs_destroy - prepare to shutdown a transport
>   * @xprt: doomed transport
> @@ -915,8 +921,7 @@ static void xs_destroy(struct rpc_xprt *xprt)
>         dprintk("RPC:       xs_destroy xprt %p\n", xprt);
>
>         xs_close(xprt);
> -       xs_free_peer_addresses(xprt);
> -       xprt_free(xprt);
> +       xs_xprt_free(xprt);
>         module_put(THIS_MODULE);
>  }
>
> @@ -2740,7 +2745,7 @@ static struct rpc_xprt *xs_setup_local(struct xprt_create *args)
>                 return xprt;
>         ret = ERR_PTR(-EINVAL);
>  out_err:
> -       xprt_free(xprt);
> +       xs_xprt_free(xprt);
>         return ret;
>  }
>
> @@ -2818,7 +2823,7 @@ static struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
>                 return xprt;
>         ret = ERR_PTR(-EINVAL);
>  out_err:
> -       xprt_free(xprt);
> +       xs_xprt_free(xprt);
>         return ret;
>  }
>
> @@ -2893,12 +2898,11 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
>                                 xprt->address_strings[RPC_DISPLAY_ADDR],
>                                 xprt->address_strings[RPC_DISPLAY_PROTO]);
>
> -
>         if (try_module_get(THIS_MODULE))
>                 return xprt;
>         ret = ERR_PTR(-EINVAL);
>  out_err:
> -       xprt_free(xprt);
> +       xs_xprt_free(xprt);
>         return ret;
>  }
>
> @@ -2988,7 +2992,7 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
>         xprt_put(xprt);
>         ret = ERR_PTR(-EINVAL);
>  out_err:
> -       xprt_free(xprt);
> +       xs_xprt_free(xprt);
>         return ret;
>  }
>
> --
> 1.8.4.2
>
>
>
