Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fn.samba.org ([216.83.154.106]:33097 "EHLO mail.samba.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751361Ab2LFUNu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Dec 2012 15:13:50 -0500
Date: Thu, 6 Dec 2012 12:13:47 -0800
From: Jeremy Allison <jra@samba.org>
To: Jeremy Allison <jra@samba.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Pavel Shilovsky <piastry@etersoft.ru>,
        linux-cifs@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, wine-devel@winehq.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/3] Add O_DENY* flags to fcntl and cifs
Message-ID: <20121206201347.GB18585@samba2>
Reply-To: Jeremy Allison <jra@samba.org>
References: <1354818391-7968-1-git-send-email-piastry@etersoft.ru>
 <20121206194949.7ab20d56@pyramind.ukuu.org.uk>
 <20121206195752.GA18585@samba2>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121206195752.GA18585@samba2>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 06, 2012 at 11:57:52AM -0800, Jeremy Allison wrote:
> On Thu, Dec 06, 2012 at 07:49:49PM +0000, Alan Cox wrote:
> > On Thu,  6 Dec 2012 22:26:28 +0400
> > Pavel Shilovsky <piastry@etersoft.ru> wrote:
> > 
> > > Network filesystems CIFS, SMB2.0, SMB3.0 and NFSv4 have such flags - this change can benefit cifs and nfs modules. While this change is ok for network filesystems, itsn't not targeted for local filesystems due security problems (e.g. when a user process can deny root to delete a file).
> > 
> > If I have my root fs on NFS then the same applies does it not.
> > 
> > Your patches fail to describe the security semantics and what file rights
> > I must have to apply each option. How do I track down a lock user, what
> > tools are provided ? How do the new options interact with the security
> > layer?
> > 
> > I don't have a problem with the idea, but it needs a lot more clear
> > description of how it works so the model can be checked and if need be
> > things tweaked (eg needing write to denywrite etc)
> 
> And this is where things get really ugly of course :-).
> 
> For the CIFSFS client they're expecting to be able to
> just ship them to a Windows server, where they'll
> get the (insane) Windows semantics. These semantics
> are not what would be wanted on a local filesystem.
> 
> So unless we just say "these things have Windows
> semantics" (where openers of files can lock out others
> under dubious circumstances) there'll be this horrible
> difference between (I'm assuming) the sane semantics that
> are defined for local filesystems and the insane ones
> that you get when you're connecting remotely.
> 
> I don't know a good way to fix that, but I'm pretty
> sure you don't want the Windows semantics defined
> locally :-).

You could just flags these as "ignored on local filesystems"
of course, exact semantics defined by the remote filesystem.

That's really what applications will get anyway. But it's not
condusive to writing documentation on what these things do :-).

Jeremy.
