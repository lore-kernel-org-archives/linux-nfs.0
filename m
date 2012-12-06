Return-Path: linux-nfs-owner@vger.kernel.org
Received: from li9-11.members.linode.com ([67.18.176.11]:37221 "EHLO
	imap.thunk.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753179Ab2LFVhf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Dec 2012 16:37:35 -0500
Date: Thu, 6 Dec 2012 16:37:27 -0500
From: "Theodore Ts'o" <tytso@mit.edu>
To: Jeremy Allison <jra@samba.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Pavel Shilovsky <piastry@etersoft.ru>,
        linux-cifs@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, wine-devel@winehq.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/3] Add O_DENY* flags to fcntl and cifs
Message-ID: <20121206213727.GC4821@thunk.org>
References: <1354818391-7968-1-git-send-email-piastry@etersoft.ru>
 <20121206194949.7ab20d56@pyramind.ukuu.org.uk>
 <20121206195752.GA18585@samba2>
 <20121206213133.GB4821@thunk.org>
 <20121206213329.GB24076@samba2>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121206213329.GB24076@samba2>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 06, 2012 at 01:33:29PM -0800, Jeremy Allison wrote:
> > I'm confused; why would a userspace application need to be able to
> > request this behavior?
> 
> This isn't my proposal Ted, I'm just commenting on it :-).

Ah, sorry, I thought was coming from the Samba team.  :-)

Hmm... I see wine-devel is cc'ed; is this coming from the Wine team,
wanting to do SMB paravirtualization?  It would be useful if the
commit description described how these flags are intended to be used....

       		   	     	       	     - Ted
