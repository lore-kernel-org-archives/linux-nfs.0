Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:38167 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750744AbcBVSdd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Feb 2016 13:33:33 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.2 \(3112\))
Subject: Re: [PATCH] nfsd: use correct byte order on rdma port.
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1456164550-6369-1-git-send-email-steved@redhat.com>
Date: Mon, 22 Feb 2016 13:33:17 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <34C24F04-CBFE-4226-8D7E-F4F526F1C661@oracle.com>
References: <1456164550-6369-1-git-send-email-steved@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Feb 22, 2016, at 1:09 PM, Steve Dickson <SteveD@redhat.com> wrote:
> 
> The returned port from getservbyname() is in
> network order. Convert the port to host order
> before writing it to the portlist file.

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>

/etc/services has:

nfsrdma    20049/tcp
nfsrdma    20049/udp
nfsrdma    20049/sctp

which RFC 5666 defines, but I couldn't find in the
IANA protocols registry.

 struct servent *sv = getservbyname("nfsrdma", "tcp");

Is weird.


> Reported-by: Chuck Lever <chuck.lever@oracle.com>
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
> utils/nfsd/nfssvc.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
> index e8efd06..dcb430a 100644
> --- a/utils/nfsd/nfssvc.c
> +++ b/utils/nfsd/nfssvc.c
> @@ -282,7 +282,7 @@ nfssvc_set_rdmaport(const char *port)
> 	int fd;
> 
> 	if (sv)
> -		nport = sv->s_port;
> +		nport = ntohs(sv->s_port);
> 	else {
> 		char *ep;
> 		nport = strtol(port, &ep, 10);
> -- 
> 2.5.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever




