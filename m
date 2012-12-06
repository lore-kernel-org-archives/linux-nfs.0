Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fn.samba.org ([216.83.154.106]:39047 "EHLO mail.samba.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754672Ab2LFVjq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Dec 2012 16:39:46 -0500
Date: Thu, 6 Dec 2012 13:39:44 -0800
From: Jeremy Allison <jra@samba.org>
To: "Theodore Ts'o" <tytso@mit.edu>, Jeremy Allison <jra@samba.org>,
        Alan Cox <alan@lxorguk.ukuu.org.uk>,
        Pavel Shilovsky <piastry@etersoft.ru>, linux-cifs@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        wine-devel@winehq.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/3] Add O_DENY* flags to fcntl and cifs
Message-ID: <20121206213944.GD24076@samba2>
Reply-To: Jeremy Allison <jra@samba.org>
References: <1354818391-7968-1-git-send-email-piastry@etersoft.ru>
 <20121206194949.7ab20d56@pyramind.ukuu.org.uk>
 <20121206195752.GA18585@samba2>
 <20121206213133.GB4821@thunk.org>
 <20121206213329.GB24076@samba2>
 <20121206213727.GC4821@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121206213727.GC4821@thunk.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 06, 2012 at 04:37:27PM -0500, Theodore Ts'o wrote:
> On Thu, Dec 06, 2012 at 01:33:29PM -0800, Jeremy Allison wrote:
> > > I'm confused; why would a userspace application need to be able to
> > > request this behavior?
> > 
> > This isn't my proposal Ted, I'm just commenting on it :-).
> 
> Ah, sorry, I thought was coming from the Samba team.  :-)

Well it sort of is, as the people working on cifsfs are also
Samba Team members, but this isn't an official "Samba" thing,
as I can't see exactly what apps would want this either (other
than Samba smbd running on top of smbd, re-exporting a cifsfs
share, pointing to a Samba server, running on a... ERROR STACK
OVERFLOW :-).

> Hmm... I see wine-devel is cc'ed; is this coming from the Wine team,
> wanting to do SMB paravirtualization?  It would be useful if the
> commit description described how these flags are intended to be used....

Indeed :-).

Jeremy.
