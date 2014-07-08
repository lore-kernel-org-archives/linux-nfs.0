Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49387 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751190AbaGHOr6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jul 2014 10:47:58 -0400
Date: Tue, 8 Jul 2014 10:47:57 -0400
To: Cedric Blancher <cedric.blancher@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4 delegations criteria? Fwd: Tuning Linux NFSv4 for high
 latency connections?
Message-ID: <20140708144757.GA23212@fieldses.org>
References: <CALXu0UeS=8tCj13a6O=W8wVr8Ke+CLpd6fUNqB35dYB2kj4hmw@mail.gmail.com>
 <CALXu0Uf9XOoZk8LQPcktWr=i6SAe903O0eLQYiLTFNWx=vxY=g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CALXu0Uf9XOoZk8LQPcktWr=i6SAe903O0eLQYiLTFNWx=vxY=g@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 07, 2014 at 06:24:41PM +0200, Cedric Blancher wrote:
> Anyone?
> 
> Ced
> 
> On 23 April 2014 23:03, Cedric Blancher <cedric.blancher@gmail.com> wrote:
> > What are the criteria for grating a file delegation in NFSv4?

They're generally implementation-specific.

> > Are file
> > delegations retained even if a process closes a file and the next
> > process in the chain opens it again (e.g. in a shell script)?

Yes, they can be.

> >
> > Ced
> >
> > PS: Who again grants NFSv4 delegations? Server or client?

The server.

> > Do
> > delegations work when data are appended at the end of a file?

The holder of a write delegation can append, yes.

The rfc's (3530 and 5661) have some more details.

I suspect the Solaris server supports write delegations.  The Linux
server doesn't.

Hard to tell the reason for the performance difference you describe,
though, you'd probably need to gather some statistics.

--b.

> >
> > ---------- Forwarded message ----------
> > From: Cedric Blancher <cedric.blancher@gmail.com>
> > Date: 23 April 2014 20:01
> > Subject: Tuning Linux NFSv4 for high latency connections?
> > To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
> >
> >
> > Are there any options to improve the Linux NFSv4 performance over a
> > high latency connection?
> >
> > We currently use Solaris/Illumos as NFSv4 server and client over a
> > cross continental Internet connection. Latency is terrible (~220ms)
> > but the counter this by running work in parallel so the latency is
> > mostly mitigated.
> >
> > We now wish to migrate (short: Away from Oracle because support is
> > basically unbearable) to Linux (tested SuSE 13.1 and current Fedora)
> > and build times are 17 times (!!!) SLOWER than on Solaris/Illumos.
> >
> > Are there any tunables besides actimeo=300?
> >
> > Ced
> > --
> > Cedric Blancher <cedric.blancher@gmail.com>
> > Institute Pasteur
> >
> >
> > --
> > Cedric Blancher <cedric.blancher@gmail.com>
> > Institute Pasteur
> 
> 
> 
> -- 
> Cedric Blancher <cedric.blancher@gmail.com>
> Institute Pasteur
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
