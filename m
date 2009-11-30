From: Neil Brown <neilb@suse.de>
Subject: Re: [nfs-utils PATCH] retry on EPERM from NFSv4 mount attempt
Date: Tue, 1 Dec 2009 08:59:16 +1100
Message-ID: <20091201085916.7c1bb644@notabene.brown>
References: <19211.7054.291514.185591@notabene.brown>
	<4B0BEDDB.1010203@RedHat.com>
	<4B13C48E.5020009@RedHat.com>
	<20091130181858.GA6348@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:39316 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752196AbZK3V5m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Nov 2009 16:57:42 -0500
In-Reply-To: <20091130181858.GA6348@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 30 Nov 2009 13:18:58 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> Note we want to do more than one of these; in particular:
> 
> >    1) Start servers with '-N 4' when there is no root configured.  
> 
> This is required.  The current behavior is a bug, and we must not
> start servers with v4 support without having a pseudoroot.

Yes, you could describe the current behaviour as a bug, but I don't
think it necessarily follows than encouraging the use of "-N 4" is an
appropriate resolution to the bug.  I agree with Steve that that would
seem like a backwards step.

Completing the auto-pseudo-root work and getting that active would also
fix the bug, and would do it in a more forward-looking way.

So while there may be a case of advising people (in a FAQ?) that using 
-N4 might be appropriate if no fsid=root is configured, I don't think
there is any point in trying to make it a default through making
any changes to the nfs-utils packages.

> >    2) Change the kernel to return NFS4ERR_SERVERFAULT when there is no
> >       root configured. 
> >       * I see this is yet another errno the mounting code has to deal with..
> >         We are up to two errnos, do we really want to add a third?  
>
> I think SERVERFAULT is a little more accurate, but I'm open to argument.

I think SERVERFAULT is the only vaguely relevant error permitted by the
RFC, so it think that should be returned.
As I said previously, I think mount.nfs should fall-back from v4 to v3
on any error when no specific version has been requested.

NeilBrown
