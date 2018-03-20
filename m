Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:60296 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753336AbeCTNfx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Mar 2018 09:35:53 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1521470194-24840-11-git-send-email-bfields@redhat.com>
References: <1521470194-24840-11-git-send-email-bfields@redhat.com> <1521470194-24840-1-git-send-email-bfields@redhat.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: dhowells@redhat.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 10/10] nfsd: clients don't need to break their own delegations
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Tue, 20 Mar 2018 13:35:51 +0000
Message-ID: <29167.1521552951@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields <bfields@redhat.com> wrote:

> @@ -139,6 +139,9 @@ struct cred {
>  	struct key	*thread_keyring; /* keyring private to this thread */
>  	struct key	*request_key_auth; /* assumed request_key authority */
>  #endif
> +#ifdef CONFIG_FILE_LOCKING
> +	void		*lease_breaker; /* identify NFS client breaking a delegation */
> +#endif
>  #ifdef CONFIG_SECURITY
>  	void		*security;	/* subjective LSM security */
>  #endif

Sorry, but ewww.

Two reasons for that comment:

 (1) The cred struct may get retained long past where you expect if it gets
     attached to another process or a file descriptor.

 (2) The ->lease_breaker pointer needs lifetime management in cred.c.  It will
     potentially get copied around and may need cleaning up.

Can you stick your breaker identity in a key struct as Jeff suggested?

David
