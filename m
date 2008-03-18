From: Ray Ferguson <nfs-Uh4cUGhLB8SgSpxsJD1C4w@public.gmane.org>
Subject: Re: NFSERR_NOSPC nfs-client bug
Date: Mon, 17 Mar 2008 19:50:21 -0600
Message-ID: <200803172050.22223.nfs@share-foo.com>
References: <200803172021.08327.nfs@share-foo.com> <47DF1E5C.9090607@melbourne.sgi.com>
Reply-To: nfs-Uh4cUGhLB8SgSpxsJD1C4w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 71-86-230-38.static.mdsn.wi.charter.com ([71.86.230.38]:40919
	"EHLO gw.share-foo.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751081AbYCRBuX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Mar 2008 21:50:23 -0400
Received: from gw.share-foo.com (localhost [127.0.0.1])
	by postfilter.gw.share-foo.net (Postfix) with ESMTP id E287D28093
	for <linux-nfs@vger.kernel.org>; Mon, 17 Mar 2008 20:50:06 -0500 (CDT)
Received: from booger.localdomain (a7v.localdomain [192.168.0.2])
	by gw.share-foo.com (Postfix) with ESMTP id B671028092
	for <linux-nfs@vger.kernel.org>; Mon, 17 Mar 2008 20:50:06 -0500 (CDT)
Received: from localhost (localhost [IPv6:::1])
	by booger.localdomain (Postfix) with ESMTP id 74A511380
	for <linux-nfs@vger.kernel.org>; Mon, 17 Mar 2008 20:50:23 -0500 (CDT)
In-Reply-To: <47DF1E5C.9090607-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Monday 17 March 2008 20:43, Greg Banks wrote:
> It doesn't ignore ENOSPC, it reports it on close().  Of course this is
> often several gigabytes of lost data too late.

In our case, the thrashing it gave our Linux NFS cluster was severe enough to  
take it out of commission.  The lost data from the file transfer that 
triggered the event was the least of our worries.

-
Ray Ferguson
