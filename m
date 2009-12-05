From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: RE: [PATCH 0/12] Fix session reset deadlocks Version 4
Date: Sat, 05 Dec 2009 16:12:18 -0500
Message-ID: <1260047538.29208.12.camel@localhost>
References: <273FE88A07F5D445824060902F70034408A1A330@SACMVEXC1-PRD.hq.netapp.com>
	 <1260043442.2624.92.camel@localhost>
	 <273FE88A07F5D445824060902F7003440637144A@SACMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "Adamson, Andy" <William.Adamson@netapp.com>,
	linux-nfs@vger.kernel.org
To: "Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4043 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752688AbZLEVM0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 5 Dec 2009 16:12:26 -0500
Received: from sacrsexc1-prd.hq.netapp.com (sacrsexc1-prd.hq.netapp.com [10.99.115.27])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id nB5LCXoN016705
	for <linux-nfs@vger.kernel.org>; Sat, 5 Dec 2009 13:12:33 -0800 (PST)
In-Reply-To: <273FE88A07F5D445824060902F7003440637144A-hX7t0kiaRRpT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2009-12-05 at 12:55 -0800, Labiaga, Ricardo wrote:
> Tried with this patch but it didn't make a difference.

You are still seeing RPC calls with 0 session ids?

>   I haven't tried applying the second cleanup patch yet since it
> didn't apply cleanly on top of nfs-for-next.  Is this the branch you
> used?

I've pushed out all patches (including the cleanup patch) onto
nfs-for-next now...

Trond
