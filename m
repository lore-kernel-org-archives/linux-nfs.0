Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40530 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750813AbcCARaP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Mar 2016 12:30:15 -0500
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (Postfix) with ESMTPS id BE0E819CBF2
	for <linux-nfs@vger.kernel.org>; Tue,  1 Mar 2016 17:30:14 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (vpn-56-214.rdu2.redhat.com [10.10.56.214])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u21HUDcI005803
	for <linux-nfs@vger.kernel.org>; Tue, 1 Mar 2016 12:30:14 -0500
Subject: Re: [PATCH] nfsd: use correct byte order on rdma port.
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <1456164550-6369-1-git-send-email-steved@redhat.com>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <56D5D1A5.2040101@RedHat.com>
Date: Tue, 1 Mar 2016 12:30:13 -0500
MIME-Version: 1.0
In-Reply-To: <1456164550-6369-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/22/2016 01:09 PM, Steve Dickson wrote:
> The returned port from getservbyname() is in
> network order. Convert the port to host order
> before writing it to the portlist file.
> 
> Reported-by: Chuck Lever <chuck.lever@oracle.com>
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed.. 

steved.

> ---
>  utils/nfsd/nfssvc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
> index e8efd06..dcb430a 100644
> --- a/utils/nfsd/nfssvc.c
> +++ b/utils/nfsd/nfssvc.c
> @@ -282,7 +282,7 @@ nfssvc_set_rdmaport(const char *port)
>  	int fd;
>  
>  	if (sv)
> -		nport = sv->s_port;
> +		nport = ntohs(sv->s_port);
>  	else {
>  		char *ep;
>  		nport = strtol(port, &ep, 10);
> 
