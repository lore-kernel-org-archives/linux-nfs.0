From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [RFC][PATCH] relax insecure option on mountd (ver 2)
Date: Mon, 16 Nov 2009 13:26:19 -0500
Message-ID: <4B01994B.3010202@RedHat.com>
References: <DE1C4ECC-6D4A-4EA6-A4FB-BE76E31C4A40@openrbg.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Robert Gordon <rbg-dkEPNP4dzOJBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46445 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751927AbZKPS0Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Nov 2009 13:26:16 -0500
In-Reply-To: <DE1C4ECC-6D4A-4EA6-A4FB-BE76E31C4A40-dkEPNP4dzOJBDgjK7y7TUQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/26/2009 05:40 PM, Robert Gordon wrote:
> In nfs-utils 1.2.0, I noticed that the insecure option validates that
> the client port is a
> subset of IPPORT_RESERVED as opposed to just validating it is a valid
> reserved port. The following proposed patch would correct that issue.
> 
> Signed-off-by: Robert Gordon <rbg-dkEPNP4dzOJBDgjK7y7TUQ@public.gmane.org>
> 
> --- ./utils/mountd/auth.c.orig
> +++ ./utils/mountd/auth.c
> @@ -169,8 +169,7 @@ auth_authenticate_internal(char *what, s
>          }
>      }
>      if (!(exp->m_export.e_flags & NFSEXP_INSECURE_PORT) &&
> -            (ntohs(caller->sin_port) <  IPPORT_RESERVED/2 ||
> -             ntohs(caller->sin_port) >= IPPORT_RESERVED)) {
> +             ntohs(caller->sin_port) >= IPPORT_RESERVED) {
>          *error = illegal_port;
>          return NULL;
>      }
> 
Committed...

steved.
