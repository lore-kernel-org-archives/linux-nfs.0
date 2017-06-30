Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:31505 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751605AbdF3PwZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Jun 2017 11:52:25 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH nfs-utils v2 05/12] getport: recognize "vsock" netid
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170630132120.31578-6-stefanha@redhat.com>
Date: Fri, 30 Jun 2017 11:52:15 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>,
        Abbas Naderi <abiusx@google.com>,
        Steve Dickson <steved@redhat.com>
Message-Id: <952499A1-FBBA-4FD8-97A6-B0014FA5065D@oracle.com>
References: <20170630132120.31578-1-stefanha@redhat.com> <20170630132120.31578-6-stefanha@redhat.com>
To: Stefan Hajnoczi <stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Stefan-


> On Jun 30, 2017, at 9:21 AM, Stefan Hajnoczi <stefanha@redhat.com> wrote:
> 
> Neither libtirpc nor getprotobyname(3) know about AF_VSOCK.

Why?

Basically you are building a lot of specialized
awareness in applications and leaving the
network layer alone. That seems backwards to me.


> For similar
> reasons as for "rdma"/"rmda6", translate "vsock" manually in getport.c.

rdma/rdma6 are specified by standards, and appear
in the IANA Network Identifiers database:

https://www.iana.org/assignments/rpc-netids/rpc-netids.xhtml

Is there a standard netid for vsock? If not,
there needs to be some discussion with the nfsv4
Working Group to get this worked out.

Because AF_VSOCK is an address family and the RPC
framing is the same as TCP, the netid should be
something like "tcpv" and not "vsock". I've
complained about this before and there has been
no response of any kind.

I'll note that rdma/rdma6 do not use alternate
address families: an IP address is specified and
mapped to a GUID by the underlying transport.
We purposely did not expose GUIDs to NFS, which
is based on AF_INET/AF_INET6.

rdma co-exists with IP. vsock doesn't have this
fallback.

It might be a better approach to use well-known
(say, link-local or loopback) addresses and let
the underlying network layer figure it out.

Then hide all this stuff with DNS and let the
client mount the server by hostname and use
normal sockaddr's and "proto=tcp". Then you don't
need _any_ application layer changes.

Without hostnames, how does a client pick a
Kerberos service principal for the server?

Does rpcbind implement "vsock" netids?

Does the NFSv4.0 client advertise "vsock" in
SETCLIENTID, and provide a "vsock" callback
service?


> It is now possible to mount a file system from the host (hypervisor)
> over AF_VSOCK like this:
> 
>  (guest)$ mount.nfs 2:/export /mnt -v -o clientaddr=3,proto=vsock
> 
> The VM's cid address is 3 and the hypervisor is 2.

The mount command is supposed to supply "clientaddr"
automatically. This mount option is exposed only for
debugging purposes or very special cases (like
disabling NFSv4 callback operations).

I mean the whole point of this exercise is to get
rid of network configuration, but here you're
adding the need to additionally specify both the
proto option and the clientaddr option to get this
to work. Seems like that isn't zero-configuration
at all.

Wouldn't it be nicer if it worked like this:

(guest)$ cat /etc/hosts
129.0.0.2  localhyper
(guest)$ mount.nfs localhyper:/export /mnt

And the result was a working NFS mount of the
local hypervisor, using whatever NFS version the
two both support, with no changes needed to the
NFS implementation or the understanding of the
system administrator?


> Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
> ---
> support/nfs/getport.c | 16 ++++++++++++----
> 1 file changed, 12 insertions(+), 4 deletions(-)
> 
> diff --git a/support/nfs/getport.c b/support/nfs/getport.c
> index 081594c..0b857af 100644
> --- a/support/nfs/getport.c
> +++ b/support/nfs/getport.c
> @@ -217,8 +217,7 @@ nfs_get_proto(const char *netid, sa_family_t *family, unsigned long *protocol)
> 	struct protoent *proto;
> 
> 	/*
> -	 * IANA does not define a protocol number for rdma netids,
> -	 * since "rdma" is not an IP protocol.
> +	 * IANA does not define protocol numbers for non-IP netids.
> 	 */
> 	if (strcmp(netid, "rdma") == 0) {
> 		*family = AF_INET;
> @@ -230,6 +229,11 @@ nfs_get_proto(const char *netid, sa_family_t *family, unsigned long *protocol)
> 		*protocol = NFSPROTO_RDMA;
> 		return 1;
> 	}
> +	if (strcmp(netid, "vsock") == 0) {
> +		*family = AF_VSOCK;
> +		*protocol = 0;
> +		return 1;
> +	}
> 
> 	nconf = getnetconfigent(netid);
> 	if (nconf == NULL)
> @@ -258,14 +262,18 @@ nfs_get_proto(const char *netid, sa_family_t *family, unsigned long *protocol)
> 	struct protoent *proto;
> 
> 	/*
> -	 * IANA does not define a protocol number for rdma netids,
> -	 * since "rdma" is not an IP protocol.
> +	 * IANA does not define protocol numbers for non-IP netids.
> 	 */
> 	if (strcmp(netid, "rdma") == 0) {
> 		*family = AF_INET;
> 		*protocol = NFSPROTO_RDMA;
> 		return 1;
> 	}
> +	if (strcmp(netid, "vsock") == 0) {
> +		*family = AF_VSOCK;
> +		*protocol = 0;
> +		return 1;
> +	}
> 
> 	proto = getprotobyname(netid);
> 	if (proto == NULL)
> -- 
> 2.9.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



