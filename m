From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Man page update for timeo= and retrans= options.
Date: Fri, 04 Jan 2008 16:31:00 -0500
Message-ID: <1199482261.11632.12.camel@heimdal.trondhjem.org>
References: <18301.39633.368089.130622@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:50804 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753351AbYADVbF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Jan 2008 16:31:05 -0500
In-Reply-To: <18301.39633.368089.130622-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Fri, 2008-01-04 at 13:32 +1100, Neil Brown wrote:
> I've been trying to understand exactly how timeouts work in the NFS
> client and find that the man page in nfs-utils is not correct.
> 
> In particular, the implementation differentiates between TCP and UDP,
> while the man page does not make that distinction.
> 
> I have attempted an update to the man page as you can see below.  It
> is entirely possible that I have not got it completely correct (or
> comprehensible) so I'm asking for people to check that what I have
> written is correct and clear.
> 
> This I would particularly like comment on:
> 
> 1/ I have left
> 
>  Better overall performance may be achieved by increasing the
>  timeout when mounting on a busy network, to a slow server, or through
>  several routers or gateways.
> 
>  unchanged.  Is it still a reasonable thing to say?

I suppose so, however it might be worth stating that a better solution
is to use TCP.

It is also worth pointing out that for TCP, the timeo mount option is
deprecated.

> 2/ I have moved the documentation about major timeouts into the retrans=
>    section.  Does that break the description up too much?

No, that sounds like a good idea.

> 3/ the old text seems to say that after the first major-timeout, a
>   slightly different sequence of timeouts are used.  I couldn't find
>   evidence of this in the code.  Did I miss something, or is my text
>   correct?

The text stating that 'each new  timeout  cascade  restarts at twice the
initial value of the previous cascade' is wrong. AFAIK, we restart at
the initial value...

> 4/ Did this change in some ancient kernel version, and should the
>   version number of the change be documented?  e.g. is it a 2.4 / 2.6
>   difference?

I'd have to check.

> 5/ As the behaviour is quite different for UDP and TCP, should we
>   introduce a major_timeo= option which calculates an appropriate
>   retrans= based on the actual timeo= and proto= used.

No. We should deprecate use of retrans/timeo altogether for TCP except
possibly for the case of 'soft' mounts (and even then you need to be
careful). It is far too easy to flood the server with redundant RPC
requests...

Cheers
  Trond

