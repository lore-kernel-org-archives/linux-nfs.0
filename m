From: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Subject: Re: FW: [PATCH for 2.6.25] SVCRDMA: Use only 1 RDMA read scatter entry for iWARP adapters
Date: Mon, 24 Mar 2008 09:57:04 -0700
Message-ID: <adave3crrfj.fsf@cisco.com>
References: <C40C5781.3E539%tom@opengridcomputing.com>
	<C40C84D0.3E674%tom@opengridcomputing.com>
	<20080324154452.GA23736@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Tucker <tom@opengridcomputing.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:41313 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758087AbYCXQ5I (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Mar 2008 12:57:08 -0400
In-Reply-To: <20080324154452.GA23736@fieldses.org> (J. Bruce Fields's message of "Mon, 24 Mar 2008 11:44:52 -0400")
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

 > Will do, thanks, but, as a subsequent patch, could we clean this up a
 > little?  For example, assuming sge_count and sc_max_sge are always
 > positive, isn't the (sge_count > 1) check superfluous, given that the
 > following min_t's going to produce 1 in that case anyway?

Yes, I had the same thought reading the code but I didn't want to try
and do too many things in one patch.

 > Also, would it be possible just to ensure sc_max_sge is just set to 1
 > from the start in this case?

I think the problem with this is that on InfiniBand, it is fine to
have multiple scatter entries for an RDMA read request, while on iWARP
only 1 scatter entry is possible for RDMA read.  For both IB and
iWARP, you can eg have multiple gather entries for an RDMA write.  So
sc_max_sge as it stands may want to be bigger than 1 even for iWARP devices.

One not-too-bad possibility would just be to have sc_max_sge and
sc_max_sge_rdma_read fields and initialize them properly based on IB
vs iWARP...

 - R.
