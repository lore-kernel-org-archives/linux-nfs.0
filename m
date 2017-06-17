Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f181.google.com ([209.85.216.181]:33875 "EHLO
        mail-qt0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752246AbdFQKBz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Jun 2017 06:01:55 -0400
Received: by mail-qt0-f181.google.com with SMTP id c10so85193468qtd.1
        for <linux-nfs@vger.kernel.org>; Sat, 17 Jun 2017 03:01:55 -0700 (PDT)
Message-ID: <1497693712.4684.4.camel@redhat.com>
Subject: Re: [PATCH v2 19/19] sunrpc: Disable splice for krb5i
From: Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
Date: Sat, 17 Jun 2017 06:01:52 -0400
In-Reply-To: <20170616152254.14210.48071.stgit@klimt.1015granger.net>
References: <20170616151535.14210.34926.stgit@klimt.1015granger.net>
         <20170616152254.14210.48071.stgit@klimt.1015granger.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2017-06-16 at 11:22 -0400, Chuck Lever wrote:
> Running a multi-threaded 8KB fio test (70/30 mix), three or four out
> of twelve of the jobs fail when using krb5i. The failure is an EIO
> on a read.
> 
> Troubleshooting confirmed the EIO results when the client fails to
> verify the MIC of an NFS READ reply. Bruce suggested the problem
> could be due to the data payload changing between the time the
> reply's MIC was computed on the server and the time the reply was
> actually sent.
> 
> krb5p gets around this problem by disabling RQ_SPLICE_OK.
> 
> "iozone -i0 -i1 -s128m -y1k -az -I", export is tmpfs, mount is
> sec=krb5i,vers=3,proto=rdma. The important numbers are the
> read / reread column.
> 
> Here's without the RQ_SPLICE_OK patch:
> 
>               kB  reclen    write  rewrite    read    reread
>           131072       1     7546     7929     8396     8267
>           131072       2    14375    14600    15843    15639
>           131072       4    19280    19248    21303    21410
>           131072       8    32350    31772    35199    34883
>           131072      16    36748    37477    49365    51706
>           131072      32    55669    56059    57475    57389
>           131072      64    74599    75190    74903    75550
>           131072     128    99810   101446   102828   102724
>           131072     256   122042   122612   124806   125026
>           131072     512   137614   138004   141412   141267
>           131072    1024   146601   148774   151356   151409
>           131072    2048   180684   181727   293140   292840
>           131072    4096   206907   207658   552964   549029
>           131072    8192   223982   224360   454493   473469
>           131072   16384   228927   228390   654734   632607
> 
> And here's with it:
> 
>               kB  reclen    write  rewrite    read    reread
>           131072       1     7700     7365     7958     8011
>           131072       2    13211    13303    14937    14414
>           131072       4    19001    19265    20544    20657
>           131072       8    30883    31097    34255    33566
>           131072      16    36868    34908    51499    49944
>           131072      32    56428    55535    58710    56952
>           131072      64    73507    74676    75619    74378
>           131072     128   100324   101442   103276   102736
>           131072     256   122517   122995   124639   124150
>           131072     512   137317   139007   140530   140830
>           131072    1024   146807   148923   151246   151072
>           131072    2048   179656   180732   292631   292034
>           131072    4096   206216   208583   543355   541951
>           131072    8192   223738   224273   494201   489372
>           131072   16384   229313   229840   691719   668427
> 
> I would say that there is not much difference in this test.
> 
> For good measure, here's the same test with sec=krb5p:
> 
>               kB  reclen    write  rewrite    read    reread
>           131072       1     5982     5881     6137     6218
>           131072       2    10216    10252    10850    10932
>           131072       4    12236    12575    15375    15526
>           131072       8    15461    15462    23821    22351
>           131072      16    25677    25811    27529    27640
>           131072      32    31903    32354    34063    33857
>           131072      64    42989    43188    45635    45561
>           131072     128    52848    53210    56144    56141
>           131072     256    59123    59214    62691    62933
>           131072     512    63140    63277    66887    67025
>           131072    1024    65255    65299    69213    69140
>           131072    2048    76454    76555   133767   133862
>           131072    4096    84726    84883   251925   250702
>           131072    8192    89491    89482   270821   276085
>           131072   16384    91572    91597   361768   336868
> 
> BugLink: https://bugzilla.linux-nfs.org/show_bug.cgi?id=307
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  net/sunrpc/auth_gss/svcauth_gss.c |    2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
> index a54a7a3..ab329f4 100644
> --- a/net/sunrpc/auth_gss/svcauth_gss.c
> +++ b/net/sunrpc/auth_gss/svcauth_gss.c
> @@ -838,6 +838,8 @@ u32 svcauth_gss_flavor(struct auth_domain *dom)
>  	struct xdr_netobj mic;
>  	struct xdr_buf integ_buf;
>  
> +	clear_bit(RQ_SPLICE_OK, &rqstp->rq_flags);
> +
>  	/* Did we already verify the signature on the original pass through? */
>  	if (rqstp->rq_deferred)
>  		return 0;
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

This seems like the right thing to do, IMO. It's nice to avoid copies
where we can, but this is just one of the places where we can't, at
least with the way things stand now. It is a pity we don't have a way to
CoW these things though.

Reviewed-by: Jeff Layton <jlayton@redhat.com>
