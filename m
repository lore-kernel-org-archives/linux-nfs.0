Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailout1.mh.bbc.co.uk ([132.185.144.153]:32844 "EHLO
	mailout1.mh.bbc.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754728Ab1JaNVq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Oct 2011 09:21:46 -0400
Date: Mon, 31 Oct 2011 13:21:15 +0000
From: David Flynn <davidf@rd.bbc.co.uk>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: David Flynn <davidf@rd.bbc.co.uk>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: NFS4ERR_STALE_CLIENTID loop
Message-ID: <20111031132115.GJ2011@rd.bbc.co.uk>
References: <20111027221742.GI32587@rd.bbc.co.uk>
 <20111029002500.GA2011@rd.bbc.co.uk>
 <1319909376.2760.11.camel@lade.trondhjem.org>
 <20111029181509.GE12122@fieldses.org>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430BDE7474@SACMVEXC2-PRD.hq.netapp.com>
 <20111029184759.GG12122@fieldses.org>
 <4B27362C-FBC1-4F64-B611-85D5FF6C5359@oracle.com>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430BDE7479@SACMVEXC2-PRD.hq.netapp.com>
 <20111029195249.GE2011@rd.bbc.co.uk>
 <6FEDF9D0-B059-4580-931C-7EBBD1F8C8EA@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <6FEDF9D0-B059-4580-931C-7EBBD1F8C8EA@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

* Chuck Lever (chuck.lever@oracle.com) wrote:
> David, what would help immensely is if you can find a reliable way of
> reproducing this.  So far we have been unable to find a reproducer.

While i've managed to have problems with individual machines, that seem
to fail at some random point of their own choosing, the most reliable
way to produce problem for us to have a number of nodes updating various
RRD files frequently.

Given that i haven't found a reliable and short method for reproducing
it either, if we were to re-run the known case and capture all network
traffic, would you be able to extract the relevant detail to generate a
simulation?

Regards,

..david
