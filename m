From: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Subject: Re: [ofa-general] Re: new NFS/RDMA instructions for 2.6.25-rc1
Date: Mon, 25 Feb 2008 09:04:04 -0800
Message-ID: <ada7igt2cjf.fsf@cisco.com>
References: <Pine.LNX.4.64.0802111223040.23589@jlentini-linux.nane.netapp.com>
	<20080211173322.GA4755@fieldses.org>
	<Pine.LNX.4.64.0802111552080.23589@jlentini-linux.nane.netapp.com>
	<20080211210044.GA4561@fieldses.org>
	<Pine.LNX.4.64.0802251140290.16537@jlentini-linux.nane.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, general-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org,
	Thomas Talpey <talpey@netapp.com>
To: James Lentini <jlentini@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:11573 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752691AbYBYREZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Feb 2008 12:04:25 -0500
In-Reply-To: <Pine.LNX.4.64.0802251140290.16537-5zmYZXM8ymTNoO61VEKW3MYxy48AqY0ZOQ4dku92ua4@public.gmane.org> (James Lentini's message of "Mon, 25 Feb 2008 11:49:58 -0500 (EST)")
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

 > +  - Install an OpenFabrics-compatible RDMA card
 > +
 > +    Any device that is compatible with the OpenFabrics.org software stack is 
 > +    acceptable.

This seems a little odd in the context of instructions on how to use
the code in the kernel.  Maybe something like:

 - Install an RDMA device

   Any device supported by the drivers in drivers/infiniband/hw is
   acceptable.

 - R.
