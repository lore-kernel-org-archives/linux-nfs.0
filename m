Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795136169;
	b=YfYatL4JV/TsCYMHkODpwoPTkVzeLC3Y2U5CaDG8CYwCeMOaSP5CSyvk7OibJtDYl9O3
	 pxM+jxz2vtq8q0SEsq9vx6TKfOoLFwGUbQsRzIW+uWmso4o2RQ7eyl7Yge3GIYpAWKMqT
	 JDVTi6Q18cRFNVgAnRwizJmilBuVl+r+VVLeybs2TEfynxqkzzbUUmUFKkvUdAhuQYCFt
	 K7ZuyOE2QeQ0GaikPT49h1iVNwVchvveyM2p6YpGXeCB7GkOsKpowfbah6YprkjmYHFBG
	 8mkza4r4eWnBsYTWRHqM8SnASRm9qedekhKnOYoi3RgmIg6GYqjIAZ1tEJr1MEGL7Ow==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795136169;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=BuyRrzXg5siAbsdhn6Z8SOrFnWem70AegHBAQnzCnag=;
	b=Mb9hsj6PLEDTHuVdAyLXaLdIucLBQz5AmqxTPRY03fQ4N7EX0VI1BmZ6fZ6U0J1Ect4B
	 eVOH2sJ5DhwkN2hLooVwYCp8QJkwyzCC1CUKkIk0e01Nyj3k2ngj6sqvnlxRoAYZNnobm
	 A8oShhTP3mxIAirKf1QgKajDhwbNh6yGHOAMEN5nw/iPts0BABdTfW7jNhrr5+hyw29W4
	 Y+j2DcHKGm/or9g7szwtQp4o1j+5iq4coPCuzmYvtaBeMYfw7txpEZipIv7L46uA3Udi7
	 J0mR3YS3qJxpva9GYHGhg9YMZPzqZdUB7Z8U5rl0Ao4fyx/5Ro+4HiuSCKe0bn9jYeQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=WNji0FfO;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E109A606A320
	for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 00:56:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=WNji0FfO
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C8DDC1F000CA;
	Fri, 20 Nov 2026 00:56:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795136168;
	bh=BuyRrzXg5siAbsdhn6Z8SOrFnWem70AegHBAQnzCnag=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=WNji0FfOadIy6ukMLcPOlob7COyFOwABCSPnA6lWK2GStivUHLFbUfYeoDwyQ+hHa
	 umgstF5OBeL93qFEtpnWnhcBYU2AS1ax6qVXm69OHUUE9M7JVjlREXMC76014INLWe
	 5JyG5YMIVxjL01h16nWZAatl3Ecm0JvBsBySjfFRiS8EuNos0MW6XJ6+lHe2D7pO8I
	 6rx/pu9r28U7XUkgRuHoW0+dwzH9PLF27FuI5K2vHW5lEVwdpwbbmn7ou7W+33vofV
	 xUEvaM9ZSP9EpVVAGvTNoU+9l9kP/pEMkXhmrLdObUGjD/lK8vQB1n0i2U/Hrex8vQ
	 73mr1YsVy8Dzw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 0BC5AF40066;
	Thu, 19 Nov 2026 19:56:06 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Thu, 19 Nov 2026 19:56:07 -0500
X-ME-Sender: <xms:ppr_av9up4D9zh1eXCbvKZSBYXe0gVteFmW_583MKs8R9go9mLPWlw>
    <xme:ppr_amgwpoWHkHgc-6Ta4ARV-3r-_ndkq8AosJ83yfZRZQuunG2Nk0t29XkORSZ4z
    MTSGsUlZJE6YMPfOF0cEh2ZGD0fS75wE9asmuAy_eSvH34aZqpFYDxy>
X-ME-Proxy-Cause: dmFkZTEeSkhP5B2ip5BXZbmyoj4Q7Qf9v5a71JtED9DzL3L7dg1ikS0ZQeoWIm4mHBMJ/P
    Z7513dSIpIVW+RDCGnEUOd/6/LAY1Xmy/osEiLYD5/pISa/GWYfxJyaxwg6yslJmOT+DcV
    z45zz/7I5E1B9gwvOKizJ1Uch/Wf2IzJw5Dcjj4CnxbIisv5vb7QsIa1lW7g20vnERFruI
    p7adAKXA2Q0WyBSKJ7gODR4C/C7QMabfqnfj1G6BG+MhTMOHnhXEhb2oJ8X1Qbv7Wj/sRE
    7G41HdcF3X4zHkPzq06teS9ls3YcbOSiQY+06uUZV0FmZtyqgipCsmkzI7h5qGyC3bfGbz
    mKXb+jKIuqMfRjpKA2aRLDnEFjGHMXwlnmC3pVXrx55vWMWEDPFO1Z7t6TWuWkVu2kBai5
    VXYpffK0YQhZcxTk8hvLxj4ZThW6GHdWRDN+2ygqzoVezG/6JsbicrwAnKXsMlurYln60l
    g5qPO1rg58UBsBDstcPPvuqpUC2UEz+aL415Kw5eiJbC4T1FDq76LIo5lBoTM1PcrnPT1A
    9z/jheB2sxdU9tuQqqODTKR7NdFauO+PbnJ3RWUXQeDIhZWkRMdkEO604DfRg8F9AUdwSc
    PCAiAP5Dd9CuEaxSx9XgicKBZx9+nqyf2IaWCo4RlQt2SBSMCcPVy0m/UT6A
X-ME-Proxy: <xmx:ppr_alRPpMl8bqcAX2DAnSyOe-3EUlDqOFV7UsHLLTVXbCHHE6ZHWg>
    <xmx:ppr_aoxclOiKpFviqVxA4RUUh8NZmsYaYpXLggpR_vh6KxG5N82fKg>
    <xmx:ppr_ahe-nzOWZRUoXXn5uzIGDJCM0tNhzsa9EIMCwK6jXifCOHaqPA>
    <xmx:ppr_arOXuI-rVSoUzkRhx683o4Vt-36HpjpGzU7BeDNa6m99C2oZYg>
    <xmx:ppr_asu5qp8dk7WW9uDGxVeFrMzNwBA0WlG8nDLFDdfcEBqoq0LtUJE1>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id DBA7D780070; Thu, 19 Nov 2026 19:56:06 -0500 (EST)
X-Mailer: MessagingEngine.com Webmail Interface
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-ThreadId: Abi8K38t_I-J
Date: Thu, 19 Nov 2026 19:55:46 -0500
From: "Chuck Lever" <cel@kernel.org>
To: "Dominik Maier" <dmnk@google.com>
Cc: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, linux-nfs@vger.kernel.org,
 dmnk+artist@google.com
Message-Id: <a43ccab0-c4eb-4531-b48a-447f2f9dfed6@slotpi15m67>
In-Reply-To: <20261119192322.2691590-1-dmnk@google.com>
References: <20261119192322.2691590-1-dmnk@google.com>
Subject: Re: [PATCH] nfsd: restrict nfsd4_spo_must_allow() to bounded cleanup compounds
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Dominik-

Thanks for the patch, but it does not apply to the nfsd-testing branch.
After 18b212a69f92, two commits from the series I posted on November 17
rewrote nfsd4_spo_must_allow():

  e63e70c8d0f5 ("NFSD: Check for a COMPOUND before reading nfsd4_compound_state")
  8489270d1cb9 ("NFSD: Move the spo_must_allow check out of check_security_flavor()")

The spo_must_allowed latch is gone. NFSD now applies the SP4_MACH_CRED
exemption in the deferred WRONGSEC check that follows PUTFH, and
records the result as fh_spo_allowed on the current filehandle. The
scan stops at the next PUTFH-like operation or at an operation that
handles NFS4ERR_WRONGSEC itself. It skips operations flagged
ALLOWED_WITHOUT_FH. A TEST_STATEID or FREE_STATEID no longer exempts
any filehandle, and an OPEN by name gets its own flavor check.

Your report still holds for one case, though. In a COMPOUND of
SEQUENCE, PUTFH, WRITE, CLOSE, the CLOSE causes NFSD to set fh_spo_allowed
on the filehandle. __fh_verify() then skips the flavor check for the
WRITE as well. The description of 8489270d1cb9 calls out this gap.

Because fh_spo_allowed is new code I'm still working on, I plan to
close that gap myself in a follow-up to that series, and I'll credit
you with Reported-by. Your nfsd4_spo_cleanup_companion_ok() is useful
input there. It records which operations the Linux NFS client sends
with the machine credential alongside CLOSE and DELEGRETURN. Any fix
has to keep those COMPOUNDs working.

Could you send me the reproducer? I'd like to run it against the fix
before I post it.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
