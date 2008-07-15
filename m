From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: [PATCH] mount: enable retry for nfs23 to set the correct protocol for mount.
Date: Tue, 15 Jul 2008 11:11:02 -0400
Message-ID: <76bd70e30807150811p56feb02bo6e4a366d5577b398@mail.gmail.com>
References: <18556.40594.897682.204554@notabene.brown>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Steve Dickson" <SteveD@redhat.com>, linux-nfs@vger.kernel.org
To: "Neil Brown" <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:36377 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752531AbYGOPLO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2008 11:11:14 -0400
Received: by yw-out-2324.google.com with SMTP id 9so2610346ywe.1
        for <linux-nfs@vger.kernel.org>; Tue, 15 Jul 2008 08:11:03 -0700 (PDT)
In-Reply-To: <18556.40594.897682.204554-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 15, 2008 at 8:56 AM, Neil Brown <neilb@suse.de> wrote:
> This is the promised patch that adds mountproto=tcp to the string
> mount options if needed.
> We still get a 90second timeout, but at least it works rather than
> saying "mount.nfs: internal error".
>
> It seems to me that it would be best to avoid the first call to mount
> altogether.  Simply always do a probe_both and then do a mount based
> on the results of that.
> Is there a good reason not to?

If I understand the question correctly, I think it doesn't because in
the most common cases, this isn't necessary.  The mount options are
usually adequate, and most servers support all the necessary NFS
versions and transport protocols.  This saves ephemeral ports and uses
less network traffic.

> BTW, I tested this by running
>    iptables -A INPUT -p udp --dport 111 -j REJECT
>
> on the NFS server.
> Accessing an NFS server over an SSH tunnel would also be a good test
> that people are using in real life (IRL as my son says...).
>
> NeilBrown
>
>
> From cec4bf512cce4686ed5dd25a9bb489f9e521721d Mon Sep 17 00:00:00 2001
> From: Neil Brown <neilb@suse.de>
> Date: Tue, 15 Jul 2008 22:38:17 +1000
>
> If an NFS server is only listening on TCP for portmap (as apparently
> MS-Windows-Server2003R2SP2 does), mount doesn't cope.  There is retry
> logic in case the initial choice of version/etc doesn't work, but it
> doesn't cope with mountd needing tcp.
> So:
>  Fix probe_port so that a TIMEDOUT error doesn't simply abort
>    but probes with other protocols (e.g. tcp).

That seems reasonable and will update the behavior for both legacy and
text-based mounts.

But should you teach connect_to() to specifically handle ECONNREFUSED
as well?  I don't see why there would be a long timeout in that case.

>  Fix rewrite_mount_options to extract the mountproto option before
>    doing a probe, then set mountproto  (and mount prot) based
>    on the result.

Yes, it should have been doing that anyway.  There's a patch queued up
in my IPv6 series that addresses this along with other issues, but
it's reasonable to fix it now.

>  Enable retry if the mount call returns EIO, as that is what happens
>    if the UDP requests to portmap get no response.

I would rather see this one addressed in the kernel.  I think the EIO
return is a kernel bug.  If the server doesn't support a particular
transport protocol for portmap, mountd, or NFS, the mount(2) system
call should always return EPROTONOSUPPORT.

>
> Signed-off-by: Neil Brown <neilb@suse.de>
> ---
>  utils/mount/network.c |    6 ++++--
>  utils/mount/stropts.c |   31 +++++++++++++++++++++++++++++--
>  2 files changed, 33 insertions(+), 4 deletions(-)
>
> diff --git a/utils/mount/network.c b/utils/mount/network.c
> index ab7f6d0..cde6b2c 100644
> --- a/utils/mount/network.c
> +++ b/utils/mount/network.c
> @@ -408,11 +408,10 @@ static int probe_port(clnt_addr_t *server, const unsigned long *versions,
>                                 }
>                                if (clnt_ping(saddr, prog, *p_vers, *p_prot, NULL))
>                                        goto out_ok;
> -                               if (rpc_createerr.cf_stat == RPC_TIMEDOUT)
> -                                       goto out_bad;
>                        }
>                }
>                if (rpc_createerr.cf_stat != RPC_PROGNOTREGISTERED &&
> +                   rpc_createerr.cf_stat != RPC_TIMEDOUT &&
>                    rpc_createerr.cf_stat != RPC_PROGVERSMISMATCH)
>                        goto out_bad;
>
> @@ -421,6 +420,9 @@ static int probe_port(clnt_addr_t *server, const unsigned long *versions,
>                                continue;
>                        p_prot = protos;
>                }
> +               if (rpc_createerr.cf_stat == RPC_TIMEDOUT)
> +                       goto out_bad;
> +
>                if (vers || !*++p_vers)
>                        break;
>        }
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index 967fd69..f06e313 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -386,6 +386,17 @@ static struct mount_options *rewrite_mount_options(char *str)
>        option = po_get(options, "mountvers");
>        if (option)
>                mnt_server.pmap.pm_vers = atoi(option);
> +       option = po_get(options, "mountproto");
> +       if (option) {
> +               if (strcmp(option, "tcp") == 0) {
> +                       mnt_server.pmap.pm_prot = IPPROTO_TCP;
> +                       po_remove_all(options, "mountproto");
> +               }
> +               if (strcmp(option, "udp") == 0) {
> +                       mnt_server.pmap.pm_prot = IPPROTO_UDP;
> +                       po_remove_all(options, "mountproto");
> +               }
> +       }
>
>        option = po_get(options, "port");
>        if (option) {
> @@ -454,6 +465,20 @@ static struct mount_options *rewrite_mount_options(char *str)
>
>        }
>
> +       if (mnt_server.pmap.pm_prot == IPPROTO_TCP)
> +               snprintf(new_option, sizeof(new_option) - 1,
> +                        "mountproto=tcp");
> +       else
> +               snprintf(new_option, sizeof(new_option) - 1,
> +                        "mountproto=udp");
> +       if (po_append(options, new_option) == PO_FAILED)
> +               goto err;
> +
> +       snprintf(new_option, sizeof(new_option) - 1,
> +                "mountport=%lu", mnt_server.pmap.pm_port);
> +       if (po_append(options, new_option) == PO_FAILED)
> +               goto err;
> +
>        errno = 0;
>        return options;
>
> @@ -560,9 +585,11 @@ static int nfs_try_nfs23mount(struct nfsmount_info *mi)
>
>        /*
>         * The kernel returns EOPNOTSUPP if the RPC bind failed,
> -        * and EPROTONOSUPPORT if the version isn't supported.
> +        * and EPROTONOSUPPORT if the version isn't supported,
> +        * and EIO if the protocol doesn't work.
>         */
> -       if (errno != EOPNOTSUPP && errno != EPROTONOSUPPORT)
> +       if (errno != EOPNOTSUPP && errno != EPROTONOSUPPORT &&
> +           errno != EIO)
>                return 0;
>
>        return nfs_retry_nfs23mount(mi);
> --
> 1.5.6.2
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>



-- 
 "Alright guard, begin the unnecessarily slow-moving dipping mechanism."
--Dr. Evil
