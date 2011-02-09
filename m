Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from glaurung.lavos.net ([69.162.133.92]:49709 "EHLO
	glaurung.lavos.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750794Ab1BJGbq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Feb 2011 01:31:46 -0500
Date: Wed, 9 Feb 2011 20:58:55 +0000
From: Brian Downing <bdowning@lavos.net>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: deepaksi <deepak.sikri@st.com>, Armando VISCONTI <armando.visconti@st.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>, netdev@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Shiraz HASHIM <shiraz.hashim@st.com>,
        Viresh KUMAR <viresh.kumar@st.com>,
        Peppe CAVALLARO <peppe.cavallaro@st.com>, amitgoel <amit.goel@st.com>
Subject: Re: STMMAC driver: NFS Problem on 2.6.37
Message-ID: <20110209205855.GB6402@glaurung.lavos.net>
References: <4D2EC133.7010607@st.com> <2D04CF75-CA68-4BDC-99A3-FA1DD6113602@oracle.com> <4D2F4453.4040400@st.com> <4D301DD1.9070104@st.com> <593F2676-CA62-4D77-90AD-41F2FAF13EB6@oracle.com> <4D3EBA54.4020308@st.com> <EFFBD485-8B7E-44D1-A8D2-61E73BF42DF9@oracle.com> <20110209200129.GA6402@glaurung.lavos.net> <D031EAC4-68E9-4E56-8DB3-208B34C8DFD7@oracle.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <D031EAC4-68E9-4E56-8DB3-208B34C8DFD7@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Feb 09, 2011 at 03:12:22PM -0500, Chuck Lever wrote:
> Based on your console logs, I see that the working case uses UDP to
> contact the server's mountd, but the failing case uses TCP.  You can
> try explicitly specifying "proto=udp" to force the use of UDP, to test
> this theory.

This does indeed make it work again for me, thanks!

> Meanwhile, the patch description explicitly states that the default
> mount option settings have changed.  Does it make sense to change the
> default behavior of NFSROOT mounts to use UDP again?  I don't see
> another way to make this process more reliable across NIC
> initialization.  If this is considered a regression, we can make a
> patch for 2.6.38-rc and 2.6.37.

I only use nfsroot for development, so I don't have a terribly strong
opinion.  I would point out though that the default u-boot parameters
for nfsrooting a lot of boards will no longer work at this point, so if
it's not patched to work again without specifying nfs options I think
there should at least be a note in the documentation and possibly a
"maybe try proto=udp?" console message on failure.

I assume it's not feasable to either wait until the chosen interface's
link is ready before trying to mount nfsroot, or retrying TCP-based
connections a little bit more aggressively/at all?

-bcd
