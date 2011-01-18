Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:29834 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752297Ab1ARTO4 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Jan 2011 14:14:56 -0500
Subject: Re: 4.1 no-pnfs mount option?
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "Matt W. Benjamin" <matt@linuxbox.com>
Cc: Daniel Muntz <Daniel.Muntz@emc.com>, rees@umich.edu,
        androsadamson@gmail.com, linux-nfs@vger.kernel.org,
        Benny Halevy <bhalevy@panasas.com>
In-Reply-To: <2129226927.80.1295376390168.JavaMail.root@thunderbeast.private.linuxbox.com>
References: <2129226927.80.1295376390168.JavaMail.root@thunderbeast.private.linuxbox.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 18 Jan 2011 14:14:35 -0500
Message-ID: <1295378075.3746.37.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2011-01-18 at 13:46 -0500, Matt W. Benjamin wrote: 
> Hi,
> 
> Isn't by mount a plausible way to select for pnfs independent of debugging?  Is it assured that a client administrator would never reasonably wish to do this?

"Why would an administrator never want to do this?" is not a helpful
question.

A more useful question is "what reason would you possibly have for
overriding the server's request that you do pNFS when your client has
pNFS support?" What makes pNFS so special that we must allow
administrators to do this on a per-mount basis?

Throwing more and more knobs into the kernel is easy. The difficult bit
is to figure out which are useful knobs, and that is why I want real use
cases... 

Trond


> ----- "Trond Myklebust" <Trond.Myklebust@netapp.com> wrote:
> 
> > > 
> > > Such a mount option could be useful for dealing with buggy servers
> > (pnfs-wise) so you
> > > could mount one server with pnfs and another without.
> > 
> > You can find ways around that. Just use 2 clients: one with pnfs
> > switched on, and one with it off.
> > 
> > I really don't want to introduce mount options upstream unless they
> > are
> > useful in the long term. One off usefulness does not pass that test.
> > 
> > -- 
> > Trond Myklebust
> > Linux NFS client maintainer
> > 
> > NetApp
> > Trond.Myklebust@netapp.com
> > www.netapp.com
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs"
> > in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

