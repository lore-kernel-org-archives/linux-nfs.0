Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e39.co.us.ibm.com ([32.97.110.160]:50355 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752955Ab3FZVYc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Jun 2013 17:24:32 -0400
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <cvogan@us.ibm.com>;
	Wed, 26 Jun 2013 15:24:31 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 585B13E40026
	for <linux-nfs@vger.kernel.org>; Wed, 26 Jun 2013 15:24:09 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5QLOSAd153540
	for <linux-nfs@vger.kernel.org>; Wed, 26 Jun 2013 15:24:28 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5QLOSKs024613
	for <linux-nfs@vger.kernel.org>; Wed, 26 Jun 2013 15:24:28 -0600
Received: from d03nm116.boulder.ibm.com (d03nm116.boulder.ibm.com [9.63.40.222])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id r5QLOSlB024610
	for <linux-nfs@vger.kernel.org>; Wed, 26 Jun 2013 15:24:28 -0600
In-Reply-To: <1372274707.36780.2.camel@leira.trondhjem.org>
References: <OF659496E7.43E03D23-ON87257B8E.004B852B-86257B8E.004BC3F6@us.ibm.com>	 <1371568176.3868.5.camel@leira.trondhjem.org>
	 <OF0A202F9C.685475CA-ON87257B8E.005E218B-86257B8E.006D757C@us.ibm.com>	 <4FA345DA4F4AE44899BD2B03EEEC2FA93F422610@SACEXCMBX04-PRD.hq.netapp.com>
	 <51CB3F08.9050005@RedHat.com> <1372274707.36780.2.camel@leira.trondhjem.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
Subject: Re: NFSERR_STALE on umount  with 3.10.0.RC5 kernel
Message-ID: <OFFA688044.F059006D-ON87257B96.0074D508-86257B96.0075968C@us.ibm.com>
From: Christopher T Vogan <cvogan@us.ibm.com>
Date: Wed, 26 Jun 2013 15:24:27 -0600
Content-Type: multipart/mixed; boundary="=_mixed 0075968786257B96_="
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=_mixed 0075968786257B96_=
Content-Type: text/plain; charset="US-ASCII"

This is a complete network trace between the client and server.


So this issue only happens on Kernels 3.9.6 and newer.
I did not have this problem with Kernel 3.8.13
nfs-utils-1.2.3-36 (from Redhat) was used w/ all kernel versions.

The mount command includes option "noac".  I assume when mounts do not 
include this option, the sending of the trailing getattr is suppressed 
since the client cached its attributes.
Let me know if you need anything else.


Christopher Vogan
Dept. W98 NFS Development & Test



From:   "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To:     Steve Dickson <SteveD@redhat.com>, 
Cc:     Christopher T Vogan/San Jose/IBM@IBMUS, 
"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date:   06/26/2013 02:25 PM
Subject:        Re: NFSERR_STALE on umount  with 3.10.0.RC5 kernel



On Wed, 2013-06-26 at 15:20 -0400, Steve Dickson wrote:
> 
> On 18/06/13 15:59, Myklebust, Trond wrote:
> >> -----Original Message-----
> >> From: Christopher T Vogan [mailto:cvogan@us.ibm.com]
> >> Sent: Tuesday, June 18, 2013 3:56 PM
> >> To: Myklebust, Trond
> >> Cc: linux-nfs@vger.kernel.org
> >> Subject: Re: NFSERR_STALE on umount with 3.10.0.RC5 kernel
> >>
> >> The NFS server uses UMNT as a signal to remove the client from its 
mount
> >> table. Also at this time the Server cleans up other information about 
the now
> >> disconnected client.  Why would the client attempt to access the NFS 
server
> >> once it has stated its going to unmount?  I do not see the point of 
the
> >> GETATTR request after UMNT call.
> > 
> > As I said, the umount.nfs utility is doing the umount system call 
after UMNT, so the 
> > client does a lookup of the umount path at that time.
> > 
> > IOW: This has nothing to do with the kernel. If you feel it is a bug, 
then please ask 
> > SteveD to file a fix against nfs-utils.
> > 
> I just took a look at the umount code and it appears the UMNT call and 
> umount() system call are being done in the correct order... 
> 
> The UMNT call is done in nfs_umount23() which is follow by either
> mnt_context_do_umount() (if using the libmount code) or del_mtab()
> which make the umount() system call....

That's the order that will cause the result Christopher is seeing: first
a UMNT call, then a lookup/revalidate as part of the umount() system
call.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com



--=_mixed 0075968786257B96_=
Content-Type: application/octet-stream; name="reddy4-umount.pcap.bz2"
Content-Disposition: attachment; filename="reddy4-umount.pcap.bz2"
Content-Transfer-Encoding: base64

QlpoOTFBWSZTWTU4ttAAPzn/////////////////////////////////////////////4Bd/enp6
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
NuzbZ7PMhOxvDBU6Ah/8XckU4UJA1OLbQA==

--=_mixed 0075968786257B96_=--

