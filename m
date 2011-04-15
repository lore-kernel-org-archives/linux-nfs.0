Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lvps87-230-0-242.dedicated.hosteurope.de ([87.230.0.242]:42841
	"EHLO lvps87-230-0-242.dedicated.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752634Ab1DOKQw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Apr 2011 06:16:52 -0400
Date: Fri, 15 Apr 2011 12:16:43 +0200
From: Michael Guntsche <mike@it-loops.com>
To: "Finney, Sean" <Sean.Finney@sonyericsson.com>
Cc: "vovan@vovan.nl" <vovan@vovan.nl>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [BUG] sec=krb5 mount problem with nfs-utils 1.2.3 on client side
Message-ID: <20110415120934@it-loops.com>
References: <20110415010913@it-loops.com>
 <1302840158.2447.5.camel@vovan.net.home>
 <A50602A820F61543B29992A418BB321B66E18F8A71@seldmbx01.corpusers.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <A50602A820F61543B29992A418BB321B66E18F8A71@seldmbx01.corpusers.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 15 Apr 11 08:01, Finney, Sean wrote:
> Hi guys,
> 
> On Fri, 2011-04-15 at 06:02 +0200, Vladimir Elisseev wrote:
> > Michael,
> > 
> > I've posted an email with the same question here a few weeks ago, but I
> > haven't been able to investigate what the problem is. The only
> > difference in my setup, that servers have kernel 2.6.36 the rest is
> > exactly the same and exactly the same error. See thread with the subject
> > "rpc.svcgssd problem after updating client 1.2.2->1.2.3".
> 
> I think the problem here is the same one we were experiencing, with
> large group memberships causing invalid writes to the procfs rpc channel
> files.  If you strace rpc.svcgssd (or rpc.mountd, you should see it
> there too I think), you should see the write() calls being split into
> multiple 1024-byte sized writes, each of which get EINVAL (or -EINVAL, I
> forget) returned.
<snip>

Thank you for the information, but I got it working in the meantime.
The main problem still is that the code for some reason tries to use AES
although I tried specifying a different enctype in my kerberos config.
Nevertheless it should just work with AES as well, so where was the
problem? 
Quite simple....missing kernel support. I enabled AES support but I DID
NOT enable CTS support which is of course needed as well. So after
compiling the server and client kernels with BOTH AES and CTS support I
can no mount the NFS4 export without any issues.

I still think the error message could be a little bit more
verbose/meaningful like "Missing kernel support for X" instead of a
rather cryptic message.

Once again, sorry for the noise and I'll keep testing this setup now
more often so this hopefully does not happen again.

Kind regards,
Michael Guntsche
