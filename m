Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e38.co.us.ibm.com ([32.97.110.159]:59605 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753195Ab3F0T0F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Jun 2013 15:26:05 -0400
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <cvogan@us.ibm.com>;
	Thu, 27 Jun 2013 13:26:04 -0600
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 19BD41FF0027
	for <linux-nfs@vger.kernel.org>; Thu, 27 Jun 2013 13:20:44 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5RJPeXE131136
	for <linux-nfs@vger.kernel.org>; Thu, 27 Jun 2013 13:25:41 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5RJPcSt015920
	for <linux-nfs@vger.kernel.org>; Thu, 27 Jun 2013 13:25:40 -0600
In-Reply-To: <1372294255.3192.4.camel@leira.trondhjem.org>
References: <OF659496E7.43E03D23-ON87257B8E.004B852B-86257B8E.004BC3F6@us.ibm.com>		 <1371568176.3868.5.camel@leira.trondhjem.org>
	 <OF0A202F9C.685475CA-ON87257B8E.005E218B-86257B8E.006D757C@us.ibm.com>
		 <4FA345DA4F4AE44899BD2B03EEEC2FA93F422610@SACEXCMBX04-PRD.hq.netapp.com>
	 <51CB3F08.9050005@RedHat.com>	 <1372274707.36780.2.camel@leira.trondhjem.org>
	 <OFFA688044.F059006D-ON87257B96.0074D508-86257B96.0075968C@us.ibm.com> <1372294255.3192.4.camel@leira.trondhjem.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
Subject: Re: NFSERR_STALE on umount  with 3.10.0.RC5 kernel
Message-ID: <OFD61D3EF8.918A1095-ON87257B97.0069766B-86257B97.006AB5A7@us.ibm.com>
From: Christopher T Vogan <cvogan@us.ibm.com>
Date: Thu, 27 Jun 2013 14:25:38 -0500
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This last update on the problem was new information gathered after our 
last exchange on 6/18/2013.
We also suspected the issue to be related to "cto", but adding mount 
options "nocto" did not resolve the problem.


Christopher Vogan
Dept. W98 NFS Development & Test



From:   "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To:     Christopher T Vogan/San Jose/IBM@IBMUS, Jeff Layton 
<jlayton@redhat.com>, 
Cc:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>, Steve 
Dickson <SteveD@redhat.com>
Date:   06/26/2013 07:51 PM
Subject:        Re: NFSERR_STALE on umount  with 3.10.0.RC5 kernel



On Wed, 2013-06-26 at 15:24 -0600, Christopher T Vogan wrote:
> This is a complete network trace between the client and server.
> 
> 
> So this issue only happens on Kernels 3.9.6 and newer.
> I did not have this problem with Kernel 3.8.13
> nfs-utils-1.2.3-36 (from Redhat) was used w/ all kernel versions.

Ah. I don't recall seeing that information before. In that case, I'm
guessing that the change in behaviour is likely to be commit
ecf3d1f1aa74da0d632b651a2e05a911f60e92c0 (vfs: kill FS_REVAL_DOT by
adding a d_weak_revalidate dentry op).

Jeff, any comment on what behaviour you expect on umount()
post-ecf3d1f1aa?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com



