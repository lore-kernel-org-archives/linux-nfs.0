Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43266 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932430Ab2B2MoE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Feb 2012 07:44:04 -0500
Date: Wed, 29 Feb 2012 07:44:01 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: steve <steve@steve-ss.com>
Cc: Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org
Subject: Re: POSIX acls over nfs4
Message-ID: <20120229124401.GA9160@fieldses.org>
References: <4F45E78E.8050501@steve-ss.com>
 <20120223063913.5736a5b1@tlielax.poochiereds.net>
 <4F4628B8.90401@steve-ss.com>
 <20120223144053.GA25010@fieldses.org>
 <4F465C3A.9080802@steve-ss.com>
 <20120223154215.GA26706@fieldses.org>
 <4F466467.3030506@steve-ss.com>
 <4F489999.30909@steve-ss.com>
 <20120228200524.GE2723@fieldses.org>
 <4F4D61B6.5090304@steve-ss.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F4D61B6.5090304@steve-ss.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 29, 2012 at 12:22:30AM +0100, steve wrote:
> We are authenticating against Samba4, so our domain user accounts
> are under Kerberos.

Kerberos works fine with v3.

--b.

> We could wait for the s4 cifs fileserver and
> winbind to be ready but would rather stick with nfs for our Linux
> clients. Simple reason being that it beats cifs on speed, especially
> when the lan is busy.
> 
> Is there an option to turn off the nfs4 acl's? I see that there is a
> -o noacl mount option but it seems to have no effect for us.
> 
> Guys, basically we don't know where to turn next. We have this issue
> open here, and on the samba and openSUSE lists. Is there anyway we
> can get together to thrash this out?
> 
> Thanks so much for replying.
> Cheers,
> Steve pp the Spanish team at lcb
> 
> 
> >
> >--b.
> >
> >>Mounting with -o nofacl in the hope that the POSIX acl set on the
> >>unmounted directory would take effect, seems to have no effect.
> >>
> >>What I'm doing at the moment is scanning the unmounted directory
> >>every few seconds using 'find' and changing the files to g+rw:-(
> >>
> >>Thanks,
> >>Steve
> >>--
> >>To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >>the body of a message to majordomo@vger.kernel.org
> >>More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
