Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:54496 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932216Ab1JaNkC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Oct 2011 09:40:02 -0400
Subject: Re: NFS4ERR_STALE_CLIENTID loop
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20111031132115.GJ2011@rd.bbc.co.uk>
Date: Mon, 31 Oct 2011 09:39:42 -0400
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Message-Id: <45576451-7EE1-4DAF-88E0-3CB7EADB5285@oracle.com>
References: <20111027221742.GI32587@rd.bbc.co.uk> <20111029002500.GA2011@rd.bbc.co.uk> <1319909376.2760.11.camel@lade.trondhjem.org> <20111029181509.GE12122@fieldses.org> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430BDE7474@SACMVEXC2-PRD.hq.netapp.com> <20111029184759.GG12122@fieldses.org> <4B27362C-FBC1-4F64-B611-85D5FF6C5359@oracle.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430BDE7479@SACMVEXC2-PRD.hq.netapp.com> <20111029195249.GE2011@rd.bbc.co.uk> <6FEDF9D0-B059-4580-931C-7EBBD1F8C8EA@oracle.com> <20111031132115.GJ2011@rd.bbc.co.uk>
To: David Flynn <davidf@rd.bbc.co.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 31, 2011, at 9:21 AM, David Flynn wrote:

> * Chuck Lever (chuck.lever@oracle.com) wrote:
>> David, what would help immensely is if you can find a reliable way of
>> reproducing this.  So far we have been unable to find a reproducer.
> 
> While i've managed to have problems with individual machines, that seem
> to fail at some random point of their own choosing, the most reliable
> way to produce problem for us to have a number of nodes updating various
> RRD files frequently.
> 
> Given that i haven't found a reliable and short method for reproducing
> it either, if we were to re-run the known case and capture all network
> traffic, would you be able to extract the relevant detail to generate a
> simulation?

A reproducer would be better for us [*], but I understand the arbitrary nature of the problem.  A network trace would be an excellent start.

Now, it would be interesting if in fact the problem occurs only when multiple clients interact with a server.  In that case, capture a full network trace with snoop on your server.  We'll worry about pruning the size of the trace once you have a clean capture.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

* - A reproducer allows us to perform internal-only tests at will, and it also can confirm we've got the problem properly fixed.


