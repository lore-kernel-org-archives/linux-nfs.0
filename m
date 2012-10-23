Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:9254 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751789Ab2JWOpM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Oct 2012 10:45:12 -0400
Message-ID: <5086AD74.4070905@RedHat.com>
Date: Tue, 23 Oct 2012 10:45:08 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jim Rees <rees@umich.edu>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Added more compile warning options
References: <1350939654-25126-1-git-send-email-steved@redhat.com> <20121022214332.GA14793@umich.edu>
In-Reply-To: <20121022214332.GA14793@umich.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Jim,

On 22/10/12 17:43, Jim Rees wrote:
> Steve Dickson wrote:
> 
>   To ensure the code compiles cleaner, the following warning options
>   are now set
>       -Wall -Wextra -Wstrict-prototypes -Wstrict-aliasing
>       -Wconversion -Wsign-conversion -Wmissing-prototypes
>       -Wsign-conversion -pedantic -Wmissing-prototypes
> 
> You only need to specify them once.  You've got sign-conversion and
> missing-prototypes twice.  
Yeah... I noticed that after I posted the patch... This was more
of an RFC patch than anything... I just wanted to get people's opinion...

> Also I think -pedantic is going too far.
Why? The one patch its used for does the following:

-gss_OID g_mechOid = GSS_C_NULL_OID;;
+gss_OID g_mechOid = GSS_C_NULL_OID;

Which seems reasonable... What do you see that I don't?

steved.

