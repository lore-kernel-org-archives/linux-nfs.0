From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 07/11] nfs-utils: convert nfssvc_setfds to use getaddrinfo
Date: Sat, 01 Aug 2009 07:35:50 -0400
Message-ID: <4A742896.1010005@RedHat.com>
References: <1244484044-21355-1-git-send-email-jlayton@redhat.com> <1244484044-21355-8-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, chuck.lever@oracle.com
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:32781 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751171AbZHALkD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 1 Aug 2009 07:40:03 -0400
In-Reply-To: <1244484044-21355-8-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/08/2009 02:00 PM, Jeff Layton wrote:
>  static void
>  nfssvc_versbits(unsigned int ctlbits, int minorvers4)
>  {
> @@ -180,8 +246,11 @@ nfssvc(int port, int nrservs, unsigned int versbits, int minorvers4,
>  	 * the ports get registered with portmap against correct
>  	 * versions
>  	 */
> -	nfssvc_versbits(versbits, minorvers4);
> -	nfssvc_setfds(port, protobits, haddr);
> +	if (!nfssvc_inuse()) {
> +		nfssvc_versbits(versbits, minorvers4);
> +		snprintf(buf, sizeof(buf), "%d", port);
> +		nfssvc_set_sockets(AF_INET, protobits, haddr, portstr);
portstr is not defined here.... and as far as I can tell its not
defined in any of the next 3 patches either... 

What am I missing or it is missing?

steved.

