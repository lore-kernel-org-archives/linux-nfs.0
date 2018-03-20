Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:43370 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751269AbeCTOwz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Mar 2018 10:52:55 -0400
Date: Tue, 20 Mar 2018 10:52:54 -0400
To: David Howells <dhowells@redhat.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 10/10] nfsd: clients don't need to break their own
 delegations
Message-ID: <20180320145254.GB4288@fieldses.org>
References: <1521470194-24840-11-git-send-email-bfields@redhat.com>
 <1521470194-24840-1-git-send-email-bfields@redhat.com>
 <29167.1521552951@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <29167.1521552951@warthog.procyon.org.uk>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 20, 2018 at 01:35:51PM +0000, David Howells wrote:
> J. Bruce Fields <bfields@redhat.com> wrote:
> 
> > @@ -139,6 +139,9 @@ struct cred {
> >  	struct key	*thread_keyring; /* keyring private to this thread */
> >  	struct key	*request_key_auth; /* assumed request_key authority */
> >  #endif
> > +#ifdef CONFIG_FILE_LOCKING
> > +	void		*lease_breaker; /* identify NFS client breaking a delegation */
> > +#endif
> >  #ifdef CONFIG_SECURITY
> >  	void		*security;	/* subjective LSM security */
> >  #endif
> 
> Sorry, but ewww.

I'm sure you're right, but, to make sure I understand:

> Two reasons for that comment:
> 
>  (1) The cred struct may get retained long past where you expect if it gets
>      attached to another process or a file descriptor.

How would that happen in the case of a knfsd thread?

>  (2) The ->lease_breaker pointer needs lifetime management in cred.c.  It will
>      potentially get copied around and may need cleaning up.

Hm, OK.

> Can you stick your breaker identity in a key struct as Jeff suggested?

Probably so.  I'm unfamiliar with the keyring code.  How would you
recommend doing that?

--b.
