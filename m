Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2130.oracle.com ([141.146.126.79]:44706 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751342AbeEVUIa (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 22 May 2018 16:08:30 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: [RFC] protect against denial-of-service on a 4.0 mount
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAN-5tyEo3d18aWny5U65NWGP1G_4kdrKGw2VDEO8vipCoivAQw@mail.gmail.com>
Date: Tue, 22 May 2018 13:08:24 -0700
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <594BD2F7-35FC-4E26-81D7-404194B7005A@oracle.com>
References: <CAN-5tyEo3d18aWny5U65NWGP1G_4kdrKGw2VDEO8vipCoivAQw@mail.gmail.com>
To: Olga Kornievskaia <aglo@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On May 22, 2018, at 1:03 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> 
> I'm looking for comments on the approach to deal with the following
> denial-of-service issue.
> 
> Currently, during the nfs4.0 mount, the code takes the content
> supplied by the user in the mount command for "clientaddr" and that
> becomes part of the content of the SETCLIENTID client id. There are no
> verifications that the supplied address belongs to the client
> initiating the mount.
> 
> A denial of services comes from where there are 2 clients with IP A
> and IP B (bad one). Client IP A mounts and has "IP A" in the
> SETCLIENTID. Client IP B does a mount and specified "clientaddr=IP A".
> This causes the server to invalidate the lease for the legitimate
> client IP A.

Generally if this is a concern, Kerberos can be used during
the SETCLIENTID to mutually authenticate the client and
server. Shouldn't that prevent client B from tampering with
client A's lease?


> My suggested approach to fixing it, is to have nfs-utils do a sanity
> checking that will check if the clientaddr that's suppose matches the
> IP of the machine. Then currently, if it doesn't then it will ignore
> the supplied value and use the IP of the machine. Whether this is
> desirable vs say failing the mount and forcing the user to specify the
> correct value is up for debate. Also, I'm not sure if the check for
> the value of clientaddr should be done in the kernel itself instead of
> the nfs-utils.
> 
> Below is the rough fix to the nfs-utils. Please comment.

One thing we want to be able to continue to do is specify
"clientaddr=0.0.0.0" to disable NFSv4.0 callback (and thus
delegation).


> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index 1217823..982927e 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -242,11 +242,21 @@ static int nfs_append_clientaddr_option(const
> struct sockaddr *sap,
>  struct sockaddr *my_addr = &address.sa;
>  socklen_t my_len = sizeof(address);
> 
> - if (po_contains(options, "clientaddr") == PO_FOUND)
> - return 1;
> -
>  nfs_callback_address(sap, salen, my_addr, &my_len);
> 
> + if (po_contains(options, "clientaddr") == PO_FOUND) {
> + char *addr = po_get(options, "clientaddr");
> +         char address[NI_MAXHOST];
> +
> +         if (!nfs_present_sockaddr(my_addr, my_len, address,
> + sizeof(address)))
> +                 goto out;
> +
> + if (strcmp(addr, address))
> + goto out;
> + return 1;
> + }
> +out:
>  return nfs_append_generic_address_option(my_addr, my_len,
>  "clientaddr", options);
> }
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



