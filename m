Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:31294 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751235Ab1BIV1b convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Feb 2011 16:27:31 -0500
Subject: Re: STMMAC driver: NFS Problem on 2.6.37
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20110209205855.GB6402@glaurung.lavos.net>
Date: Wed, 9 Feb 2011 16:26:16 -0500
Cc: deepaksi <deepak.sikri@st.com>, Armando VISCONTI <armando.visconti@st.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>, netdev@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Shiraz HASHIM <shiraz.hashim@st.com>,
        Viresh KUMAR <viresh.kumar@st.com>,
        Peppe CAVALLARO <peppe.cavallaro@st.com>, amitgoel <amit.goel@st.com>
Message-Id: <5CC01953-376D-46FC-99DA-C282332FA40F@oracle.com>
References: <4D2EC133.7010607@st.com> <2D04CF75-CA68-4BDC-99A3-FA1DD6113602@oracle.com> <4D2F4453.4040400@st.com> <4D301DD1.9070104@st.com> <593F2676-CA62-4D77-90AD-41F2FAF13EB6@oracle.com> <4D3EBA54.4020308@st.com> <EFFBD485-8B7E-44D1-A8D2-61E73BF42DF9@oracle.com> <20110209200129.GA6402@glaurung.lavos.net> <D031EAC4-68E9-4E56-8DB3-208B34C8DFD7@oracle.com> <20110209205855.GB6402@glaurung.lavos.net>
To: Brian Downing <bdowning@lavos.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Feb 9, 2011, at 3:58 PM, Brian Downing wrote:

> On Wed, Feb 09, 2011 at 03:12:22PM -0500, Chuck Lever wrote:
>> Based on your console logs, I see that the working case uses UDP to
>> contact the server's mountd, but the failing case uses TCP.  You can
>> try explicitly specifying "proto=udp" to force the use of UDP, to test
>> this theory.
> 
> This does indeed make it work again for me, thanks!
> 
>> Meanwhile, the patch description explicitly states that the default
>> mount option settings have changed.  Does it make sense to change the
>> default behavior of NFSROOT mounts to use UDP again?  I don't see
>> another way to make this process more reliable across NIC
>> initialization.  If this is considered a regression, we can make a
>> patch for 2.6.38-rc and 2.6.37.
> 
> I only use nfsroot for development, so I don't have a terribly strong
> opinion.  I would point out though that the default u-boot parameters
> for nfsrooting a lot of boards will no longer work at this point, so if
> it's not patched to work again without specifying nfs options I think
> there should at least be a note in the documentation and possibly a
> "maybe try proto=udp?" console message on failure.
> 
> I assume it's not feasable to either wait until the chosen interface's
> link is ready before trying to mount nfsroot, or retrying TCP-based
> connections a little bit more aggressively/at all?

Our goal is to use the same mount logic for both normal user space mounts and for NFSROOT (that was the purpose of the patch series this particular patch comes from).  It's exceptionally difficult to add a special case for retrying TCP connections here, as that would change the behavior of user space mounts, which often want to fail quickly, and don't need to worry about NIC initialization.

Sounds like the right thing to do is restore the default UDP behavior.  I'll cook up a patch.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

