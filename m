Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:61472 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755373Ab3JGKmE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Oct 2013 06:42:04 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r97Ag3Vi022295
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 7 Oct 2013 06:42:04 -0400
Date: Mon, 7 Oct 2013 06:00:05 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: Simo Sorce <ssorce@redhat.com>, steved@redhat.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 2/2] gssd: switch real uid instead of just fsuid when
 looking for user creds
Message-ID: <20131007060005.0d07e3fa@tlielax.poochiereds.net>
In-Reply-To: <20131005180403.12301e80@corrin.poochiereds.net>
References: <1380829760-4928-1-git-send-email-jlayton@redhat.com>
	<1380829760-4928-3-git-send-email-jlayton@redhat.com>
	<1937105088.1804058.1380916002471.JavaMail.root@redhat.com>
	<20131005180403.12301e80@corrin.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 5 Oct 2013 18:04:03 -0400
Jeff Layton <jlayton@redhat.com> wrote:

> On Fri, 4 Oct 2013 15:46:42 -0400 (EDT)
> Simo Sorce <ssorce@redhat.com> wrote:
> 
> > 
> > 
> > ----- Original Message -----
> > > The part of process_krb5_upcall that handles non-machine user creds
> > > first tries to query GSSAPI for credentials. If that fails, it then
> > > falls back to trawling through likely credcache locations to find them
> > > and then points $KRB5CCNAME at it before proceeding. There are a number
> > > of bugs in this code that this patch attempts to address.
> > > 
> > > The code that queries GSSAPI for credentials does it as root and that
> > > almost universally fails to do anything useful unless we happen to be
> > > looking for non-machine root creds. Because of this, gssd almost always
> > > falls back to having to search for credcaches "manually" and then set
> > > $KRB5CCNAME if and when they are found. The code that handles credential
> > > switching is in create_auth_rpc_client, so it's too late to be of any
> > > use here.
> > > 
> > > Worse yet, the GSSAPI code that handles finding credcaches does it based
> > > on the return from getuid(), so just switching the fsuid or even euid is
> > > insufficient. You must switch the real uid.
> > 
> > In what case does it do this ?
> > If it is unconditional this is a bug in GSSAPI and we should fix it there.
> > 
> 
> As far as I can tell (primarily from stracing and experimenting) it
> always does this. Additionally it looks like KEYRING: support might
> also depend on this.
> 

I took a closer look at this this morning and I think I see the
problem. The issue is in libkrb5 and the default definitions of the
credcache locations. For instance:

    default_ccache_name = KEYRING:persistent:%{uid}

%{uid} expands to the real uid, not the effective one. If you change
that to:

    default_ccache_name = KEYRING:persistent:%{euid}

...then it all works just by swapping the euid.

So, not a bug in libkrb5 or libgssapi per-se, but I think we're sort of
stuck with switching the real uid due to this.

The fact that the first patch in this series makes the daemon fork
before doing this should help mitigate any damage that an unprivileged
user can do.
-- 
Jeff Layton <jlayton@redhat.com>
