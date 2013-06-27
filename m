Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:13508 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753080Ab3F0AvC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Jun 2013 20:51:02 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Christopher T Vogan <cvogan@us.ibm.com>, Jeff Layton <jlayton@redhat.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Steve Dickson <SteveD@redhat.com>
Subject: Re: NFSERR_STALE on umount  with 3.10.0.RC5 kernel
Date: Thu, 27 Jun 2013 00:51:01 +0000
Message-ID: <1372294255.3192.4.camel@leira.trondhjem.org>
References: <OF659496E7.43E03D23-ON87257B8E.004B852B-86257B8E.004BC3F6@us.ibm.com>
		 <1371568176.3868.5.camel@leira.trondhjem.org>
	 <OF0A202F9C.685475CA-ON87257B8E.005E218B-86257B8E.006D757C@us.ibm.com>
		 <4FA345DA4F4AE44899BD2B03EEEC2FA93F422610@SACEXCMBX04-PRD.hq.netapp.com>
	 <51CB3F08.9050005@RedHat.com>
	 <1372274707.36780.2.camel@leira.trondhjem.org>
	 <OFFA688044.F059006D-ON87257B96.0074D508-86257B96.0075968C@us.ibm.com>
In-Reply-To: <OFFA688044.F059006D-ON87257B96.0074D508-86257B96.0075968C@us.ibm.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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
