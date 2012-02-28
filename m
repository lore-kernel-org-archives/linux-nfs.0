Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55626 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757294Ab2B1UF0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Feb 2012 15:05:26 -0500
Date: Tue, 28 Feb 2012 15:05:24 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: steve <steve@steve-ss.com>
Cc: Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org
Subject: Re: POSIX acls over nfs4
Message-ID: <20120228200524.GE2723@fieldses.org>
References: <4F40053A.3090301@steve-ss.com>
 <4F412E2F.9070200@steve-ss.com>
 <4F45E78E.8050501@steve-ss.com>
 <20120223063913.5736a5b1@tlielax.poochiereds.net>
 <4F4628B8.90401@steve-ss.com>
 <20120223144053.GA25010@fieldses.org>
 <4F465C3A.9080802@steve-ss.com>
 <20120223154215.GA26706@fieldses.org>
 <4F466467.3030506@steve-ss.com>
 <4F489999.30909@steve-ss.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F489999.30909@steve-ss.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Feb 25, 2012 at 09:19:37AM +0100, steve wrote:
> On 23/02/12 17:08, steve wrote:
> >On 02/23/2012 04:42 PM, J. Bruce Fields wrote:
> >>>>First, if you want an ace on a directory to be inherited by files and
> >>>>directories created under that directory, make sure you're setting
> >>>>the f
> >>>>and d flags (see nfs4_getfacl -H).
> >>>>
> >>>>Second, there's a umask problem: posix acl inheritance overrides the
> >>>>umask, but nfs4 acl inheritance isn't doing that. (The client combines
> >>>>the create mode and the umask and sets both together, there's no way
> >>>>for
> >>>>the server to even tell what the umask is.)
> >>>>
> >>>>(We should do something about this if we can: maybe modifying the
> >>>>client
> >>>>to scan the directory acl for any inheritable aces and leaving out the
> >>>>umask if they're found? It has the obvious race, but I seem to recall
> >>>>we live with that in the v3 case. Or maybe there's something more
> >>>>clever, but this comes up every now and then and I can't remember a
> >>>>better solution.)
> >>>>
> 
> Hi everyone
> 
> This really is a show stopper for us.
> 
> Would it be possible to give users the choice of being able to
> disable nfs4 acls so we can fall back to POSIX or nt acls? Or at
> least until the nfs4 team have had time to consider the situation?

The NFSv4 protocol has no support for posix acls, so this isn't an
option; possibly you're best off with v3 for some reason.  (Why the
migration to v4?)

--b.

> 
> Mounting with -o nofacl in the hope that the POSIX acl set on the
> unmounted directory would take effect, seems to have no effect.
> 
> What I'm doing at the moment is scanning the unmounted directory
> every few seconds using 'find' and changing the files to g+rw:-(
> 
> Thanks,
> Steve
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
