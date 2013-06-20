Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54668 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030330Ab3FTOt5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Jun 2013 10:49:57 -0400
Date: Thu, 20 Jun 2013 10:49:55 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Sven Geggus <lists@fuchsschwanzdomain.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Kerberized NFS-Server Problem still present in 3.10.0-rc2
Message-ID: <20130620144955.GB11728@fieldses.org>
References: <kpscp8$fo3$1@ultimate100.geggus.net>
 <20130619213412.GA2547@fieldses.org>
 <20130620080354.GA5591@geggus.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130620080354.GA5591@geggus.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 20, 2013 at 10:03:55AM +0200, Sven Geggus wrote:
> J. Bruce Fields schrieb am Mittwoch, den 19. Juni um 23:34 Uhr:
> 
> > Apologies, I don't remember the previous discussion, so, could you
> > summarize for me?
> 
> Shure!
> My original bug-report ist here:
> http://www.spinics.net/lists/linux-nfs/msg37454.html
> 
> > - you're able to reproduce/not reproduce the problem by changing
> >   *only* the kernel on the nfs server between 3.8.x and
> >   3.10.0-rc2 ?
> 
> Exactly. See also the Postings of Richard van den Toorn on the list.
> 
> Summary: Mount is locking when upgrading from 3.8.x to 3.9.x
> 
> Unfortunately I was unable to do a git bisect because somewhere on the way
> the behaviour changed from locking to "permission denied".
> 
> If you give me a hint if this behaviour should be marked as good or bad I
> can continue bisecting!
> 
> > - have you figured out exactly where the failure happens?:
> 
> No because I have not been able to do git bisect to the end.
> 
> > - which version of NFS are you using?
> 
> NFS4 with Kerberos authentication.

What happens with NFSv3?

> > Also if you haven't already it would be useful to know at exactly which
> > step of the process it's failing.  As a first step running wireshark on
> > the traffic between client and server and looking for a NULL
> > init_sec_context rpc call and seeing whether it succeeds or not, would
> > be useful.
> 
> I already posted a wireshark dump:
> http://www.spinics.net/lists/linux-nfs/msg37472.html

So it looks it did a null init_sec_context establishment and then the
server didn't reply to the first rpc call using the new context.  But
it's hard to be sure without more details--could I get the binary dump?

That might be explained by the problem fixed by
3c34ae11fac3b30629581d0bfaf80f58e82cfbfb "nfsd: fix krb5 handling of
anonymous principals", but that was already in v3.9.

--b.
