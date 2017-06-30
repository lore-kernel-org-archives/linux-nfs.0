Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38742 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751545AbdF3PBR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Jun 2017 11:01:17 -0400
Subject: Re: [PATCH nfs-utils v2 05/12] getport: recognize "vsock" netid
To: Stefan Hajnoczi <stefanha@redhat.com>, linux-nfs@vger.kernel.org
Cc: Jeff Layton <jlayton@redhat.com>, Abbas Naderi <abiusx@google.com>
References: <20170630132120.31578-1-stefanha@redhat.com>
 <20170630132120.31578-6-stefanha@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <6a9210af-b1e3-c768-2be8-8c6f761e82d0@RedHat.com>
Date: Fri, 30 Jun 2017 11:01:13 -0400
MIME-Version: 1.0
In-Reply-To: <20170630132120.31578-6-stefanha@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/30/2017 09:21 AM, Stefan Hajnoczi wrote:
> Neither libtirpc nor getprotobyname(3) know about AF_VSOCK.  For similar
> reasons as for "rdma"/"rmda6", translate "vsock" manually in getport.c.
> 
> It is now possible to mount a file system from the host (hypervisor)
> over AF_VSOCK like this:
> 
>   (guest)$ mount.nfs 2:/export /mnt -v -o clientaddr=3,proto=vsock
> 
> The VM's cid address is 3 and the hypervisor is 2.
So this is how vsocks are going to look... 
There is not going to be a way to lookup an vsock address?
Since the format of the clientaddr parameter shouldn't
that be documented in the man page?

I guess a general question, is this new mount type
documented anywhere? 

steved.
> 
> Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
> ---
>  support/nfs/getport.c | 16 ++++++++++++----
>  1 file changed, 12 insertions(+), 4 deletions(-)
> 
> diff --git a/support/nfs/getport.c b/support/nfs/getport.c
> index 081594c..0b857af 100644
> --- a/support/nfs/getport.c
> +++ b/support/nfs/getport.c
> @@ -217,8 +217,7 @@ nfs_get_proto(const char *netid, sa_family_t *family, unsigned long *protocol)
>  	struct protoent *proto;
>  
>  	/*
> -	 * IANA does not define a protocol number for rdma netids,
> -	 * since "rdma" is not an IP protocol.
> +	 * IANA does not define protocol numbers for non-IP netids.
>  	 */
>  	if (strcmp(netid, "rdma") == 0) {
>  		*family = AF_INET;
> @@ -230,6 +229,11 @@ nfs_get_proto(const char *netid, sa_family_t *family, unsigned long *protocol)
>  		*protocol = NFSPROTO_RDMA;
>  		return 1;
>  	}
> +	if (strcmp(netid, "vsock") == 0) {
> +		*family = AF_VSOCK;
> +		*protocol = 0;
> +		return 1;
> +	}
>  
>  	nconf = getnetconfigent(netid);
>  	if (nconf == NULL)
> @@ -258,14 +262,18 @@ nfs_get_proto(const char *netid, sa_family_t *family, unsigned long *protocol)
>  	struct protoent *proto;
>  
>  	/*
> -	 * IANA does not define a protocol number for rdma netids,
> -	 * since "rdma" is not an IP protocol.
> +	 * IANA does not define protocol numbers for non-IP netids.
>  	 */
>  	if (strcmp(netid, "rdma") == 0) {
>  		*family = AF_INET;
>  		*protocol = NFSPROTO_RDMA;
>  		return 1;
>  	}
> +	if (strcmp(netid, "vsock") == 0) {
> +		*family = AF_VSOCK;
> +		*protocol = 0;
> +		return 1;
> +	}
>  
>  	proto = getprotobyname(netid);
>  	if (proto == NULL)
> 
