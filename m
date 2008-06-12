From: Neil Brown <neilb@suse.de>
Subject: Re: .Xauthority going stale (but not really)
Date: Thu, 12 Jun 2008 10:02:52 +1000
Message-ID: <18512.26540.511674.417268@notabene.brown>
References: <alpine.DEB.1.10.0806110849250.11896@qygrfg01.brgvxre.pu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Tobias Oetiker <tobi-7K0TWYW2a3pyDzI6CaY1VQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:49034 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753884AbYFLADZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Jun 2008 20:03:25 -0400
In-Reply-To: message from Tobias Oetiker on Wednesday June 11
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wednesday June 11, tobi-7K0TWYW2a3pyDzI6CaY1VQ@public.gmane.org wrote:
> Experts,
> 
> I have a strange problem on a diskless client. At ramdom intervals
> (hours) when I try to open an xterm I get the message
> 
>  > xterm
>  No protocol specified
>  xterm Xt error: Can't open display: :13.0
> 
> Doing an strace on xterm I find that it gets a 'stale nfs handle'
> when trying to open .Xauthority.
> 
> If I do a
> 
>  cat .Xauthority >/dev/null
> 
> things go back to normal and I can open xterms again ...
> 
> so how can it be, that xterm gets a stale nfs handle error while
> cat can read the file just fine and after cat did it it works for
> xterm as well ?

xterm is setuid root.  cat is not.

The filesystem is exported in a way the causes 'root' accesses to be
treated as accessed by 'nobody'.  If the NFS server is Linux, then the
export option "no_root_squash" can fix this.

If the .Xauthority file is in cache on the client, xterm will be able
to read it with no problem.  If not, it will send a request to the
server for root to be able to read the file, and the server will
reject the request.

It should really return EACCES rather than ESTALE though ... what is
the NFS server?

NeilBrown
