Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:52042 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750942AbcCAAsq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Feb 2016 19:48:46 -0500
Date: Mon, 29 Feb 2016 19:48:44 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jason L Tibbitts III <tibbs@math.uh.edu>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS: nfs4_reclaim_open_state: Lock reclaim failed! log spew
Message-ID: <20160301004844.GA11952@fieldses.org>
References: <ufafuwhlr72.fsf@epithumia.math.uh.edu>
 <20160225195827.GC23315@fieldses.org>
 <ufaegbvdslg.fsf@epithumia.math.uh.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <ufaegbvdslg.fsf@epithumia.math.uh.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 29, 2016 at 05:06:35PM -0600, Jason L Tibbitts III wrote:
> >>>>> "JBF" == J Bruce Fields <bfields@fieldses.org> writes:
> 
> >> Unfortunately I did not grab any of that traffic (I just wanted it to
> >> stop).  This happens to me periodically so I'll be sure to do that
> >> when it hits again.
> 
> JBF> OK, that'd be helpful.
> 
> I waited a bit and it's happened again from a few clients.  I captured
> some traffic from one of them and it's just an endless stream of
> Call/Reply:
> 
>   8 0.002842000 172.21.86.135 -> 172.21.86.78 NFS 406 V4 Call
>   9 0.003493000 172.21.86.78 -> 172.21.86.135 NFS 518 V4 Reply (Call In  8)
>  10 0.003536000 172.21.86.135 -> 172.21.86.78 NFS 406 V4 Call
>  11 0.004168000 172.21.86.78 -> 172.21.86.135 NFS 518 V4 Reply (Call In 10)
>  12 0.004252000 172.21.86.135 -> 172.21.86.78 NFS 406 V4 Call
>  13 0.004854000 172.21.86.78 -> 172.21.86.135 NFS 518 V4 Reply (Call In 12)
>  14 0.004931000 172.21.86.135 -> 172.21.86.78 NFS 406 V4 Call
>  15 0.005613000 172.21.86.78 -> 172.21.86.135 NFS 518 V4 Reply (Call In 14)
> 
> 
> Here's a call:
> 
>         GSS Service: rpcsec_gss_svc_privacy (3)

Argh, it's all encrypted, so we all we have to go on is the size of the
request and reply:

> GSS-Wrap
>     Length: 236
...
> And here's a reply:
...
> GSS-Wrap
>     Length: 392

Anyway, just knowing the error may be enough for us to work out the
problem--I just need to dig a little more.

> The calls and replies all appear to be identical.  Sorry for the length
> of those but I wouldn't want to trim anything that might be important.
> 
> JBF> Unfortunately what would probably be *most* helpful would be the
> JBF> traffic that lead up to this--by the time the client and server get
> JBF> into this loop the interesting problem may have already
> JBF> happened--but just seeing the loop may be useful too.
> 
> Yeah, there's basically no chance of capturing that, and I have no way
> to make it happen.  I can't just snarf all of the NFS traffic, and once
> this starts it generates so many packets....

The best you could do is capture all traffic and throw away all but the
last few seconds (see the ring buffer stuff in tshark) and write a
script that kills the capture as soon as it notices you've hit this
condition.  Anyway, possibly still impractical and not worth the trouble
at this point anyway.

> Note that this doesn't appear to be caused by something like a kerberos
> ticket; the user last logged in well under the maximum ticket renewal
> time, and SSSD has been dutifully renewing them.

OK, thanks.

--b.
