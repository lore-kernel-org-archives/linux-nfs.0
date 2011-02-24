Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:63161 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755229Ab1BXSeM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Feb 2011 13:34:12 -0500
Subject: Re: STMMAC driver: NFS Problem on 2.6.37
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20110224133627.GO920@DLHLAP0379>
Date: Thu, 24 Feb 2011 10:33:08 -0800
Cc: Brian Downing <bdowning@lavos.net>, Deepak SIKRI <deepak.sikri@st.com>,
        Armando VISCONTI <armando.visconti@st.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Viresh KUMAR <viresh.kumar@st.com>,
        Peppe CAVALLARO <peppe.cavallaro@st.com>, amitgoel <amit.goel@st.com>
Message-Id: <CFD8EE5F-D6D4-4621-81F4-11CA4FD22F9F@oracle.com>
References: <2D04CF75-CA68-4BDC-99A3-FA1DD6113602@oracle.com> <4D2F4453.4040400@st.com> <4D301DD1.9070104@st.com> <593F2676-CA62-4D77-90AD-41F2FAF13EB6@oracle.com> <4D3EBA54.4020308@st.com> <EFFBD485-8B7E-44D1-A8D2-61E73BF42DF9@oracle.com> <20110209200129.GA6402@glaurung.lavos.net> <D031EAC4-68E9-4E56-8DB3-208B34C8DFD7@oracle.com> <20110209205855.GB6402@glaurung.lavos.net> <5CC01953-376D-46FC-99DA-C282332FA40F@oracle.com> <20110224133627.GO920@DLHLAP0379>
To: Shiraz Hashim <shiraz.hashim@st.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Feb 24, 2011, at 5:36 AM, Shiraz Hashim wrote:

> On Thu, Feb 10, 2011 at 05:26:16AM +0800, Chuck Lever wrote:
>> 
>> On Feb 9, 2011, at 3:58 PM, Brian Downing wrote:
>> 
>>> On Wed, Feb 09, 2011 at 03:12:22PM -0500, Chuck Lever wrote:
>>>> Based on your console logs, I see that the working case uses UDP to
>>>> contact the server's mountd, but the failing case uses TCP.  You can
>>>> try explicitly specifying "proto=udp" to force the use of UDP, to test
>>>> this theory.
>>> 
>>> This does indeed make it work again for me, thanks!
>>> 
>>>> Meanwhile, the patch description explicitly states that the default
>>>> mount option settings have changed.  Does it make sense to change the
>>>> default behavior of NFSROOT mounts to use UDP again?  I don't see
>>>> another way to make this process more reliable across NIC
>>>> initialization.  If this is considered a regression, we can make a
>>>> patch for 2.6.38-rc and 2.6.37.
>>> 
>>> I only use nfsroot for development, so I don't have a terribly strong
>>> opinion.  I would point out though that the default u-boot parameters
>>> for nfsrooting a lot of boards will no longer work at this point, so if
>>> it's not patched to work again without specifying nfs options I think
>>> there should at least be a note in the documentation and possibly a
>>> "maybe try proto=udp?" console message on failure.
>>> 
>>> I assume it's not feasable to either wait until the chosen interface's
>>> link is ready before trying to mount nfsroot, or retrying TCP-based
>>> connections a little bit more aggressively/at all?
>> 
>> Our goal is to use the same mount logic for both normal user
>> space mounts and for NFSROOT (that was the purpose of the patch
>> series this particular patch comes from).  It's
>> exceptionally difficult to add a special case for retrying TCP
>> connections here, as that would change the behavior of user
>> space mounts, which often want to fail quickly, and don't need
>> to worry about NIC initialization.
>> 
>> Sounds like the right thing to do is restore the default UDP behavior.  I'll cook up a patch.
> 
> Is there some patch available for this now.

Yes, it was posted a couple of weeks ago (sorry, I don't have an exact reference).  I will ping Trond again about getting this upstream.

> There is one more observation (on 2.6.37), when I pass
> nfsroot=$(ip):$(rootpath),udp , then it works fine.
> If I pass proto=udp then it doesn't work. Is there any difference
> between the two methods ?

It may be that proto=udp has an effect only on the transport used for NFS requests, but not for the MNT request.  "udp" means "proto=udp,mountproto=udp."

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



