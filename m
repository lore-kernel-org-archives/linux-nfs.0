From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] gssd: have gssd deal with scopeid field in upcall
Date: Fri, 11 Dec 2009 16:22:33 -0500
Message-ID: <4B22B819.6090504@RedHat.com>
References: <1260305091-19523-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64330 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758850AbZLKVWc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Dec 2009 16:22:32 -0500
In-Reply-To: <1260305091-19523-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/08/2009 03:44 PM, Jeff Layton wrote:
> Recent kernels (2.6.32) have started displaying the scopeid for some
> addresses in the upcall. gssd doesn't know how to deal with them. Change
> gssd to use getaddrinfo instead of inet_pton since that can deal with
> scopeid's in addresses. That also allows us to elminate the port
> conversion in read_service_info.
> 
> If getaddrinfo returns an address with a non-zero sin6_scope_id however,
> reject it. getnameinfo ignores that field and just uses the sin6_addr
> part when resolving. But, two addresses that differ only in
> sin6_scope_id could refer to completely different hosts.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
Committed... 

I tested this at the same time at the same time I tested Chuck's
mounting patches... 

steved.
