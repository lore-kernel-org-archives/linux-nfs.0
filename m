From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [RFC][PATCH] relax insecure option on mountd
Date: Tue, 27 Oct 2009 06:38:50 -0400
Message-ID: <20091027063850.03578ce7@tlielax.poochiereds.net>
References: <3C8019BD-4231-428F-B94C-5257111F9E96@openrbg.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: Robert Gordon <rbg-dkEPNP4dzOJBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49664 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752900AbZJ0Kis (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Oct 2009 06:38:48 -0400
In-Reply-To: <3C8019BD-4231-428F-B94C-5257111F9E96-dkEPNP4dzOJBDgjK7y7TUQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 26 Oct 2009 15:56:27 -0500
Robert Gordon <rbg-dkEPNP4dzOJBDgjK7y7TUQ@public.gmane.org> wrote:

> In nfs-utils 1.2.0, I noticed that the insecure option validates that  
> the client port is a
> subset of IPPORT_RESERVED as opposed to just validating it is a valid
> reserved port. The following proposed patch would correct that issue.
> 
> Signed-off-by: Robert Gordon <rbg-dkEPNP4dzOJBDgjK7y7TUQ@public.gmane.org>
> 
> --- ./utils/mountd/auth.c.orig
> +++ ./utils/mountd/auth.c
> @@ -169,7 +169,6 @@ auth_authenticate_internal(char *what, s
>   		}
>   	}
>   	if (!(exp->m_export.e_flags & NFSEXP_INSECURE_PORT) &&
> -		    (ntohs(caller->sin_port) <  IPPORT_RESERVED/2 ||
>   		     ntohs(caller->sin_port) >= IPPORT_RESERVED)) {
>   		*error = illegal_port;
>   		return NULL;
> 

Acked-by: Jeff Layton <jlayton@redhat.com>
