From: =?ISO-8859-15?Q?Peter_=C5strand?= <astrand-+4tYiAq3b6azQB+pC5nmwQ@public.gmane.org>
Subject: [NFS] Unable to mount without portmap with SLED11 (nfs-utils 1.1.3)
Date: Thu, 30 Apr 2009 09:50:18 +0200 (CEST)
Message-ID: <alpine.LFD.2.00.0904241355240.7710@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="789237761-40157612-1240574152=:7710"
To: linux-nfs@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:50052 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751243AbZD3HvM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Apr 2009 03:51:12 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1LzR31-0000Yn-I8
	for linux-nfs@vger.kernel.org; Thu, 30 Apr 2009 17:51:11 +1000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--789237761-40157612-1240574152=:7710
Content-Type: TEXT/PLAIN; CHARSET=ISO-8859-15; FORMAT=flowed
Content-ID: <alpine.LFD.2.00.0904241405301.7894-K9BqGu7AvB3wj5YHdwD3Ga2PxDmRETKR@public.gmane.org>
Content-Transfer-Encoding: quoted-printable


On SLED11 (nfs-utils 1.1.3), it is not possible to mount without using th=
e=20
portmapper. This is necessary, say, when mounting resources from a "unfs3=
"=20
server. Example:

# mount -t nfs -o mountport=3D4711,port=3D4711,mountvers=3D3,nfsvers=3D3,=
nolock,tcp localhost:/some/path /mnt
mount.nfs: mount to NFS server 'localhost:/some/path' failed: RPC Error: =
Program not registered

In this case, the local portmapper shouldn't be contacted; mount has all=20
information it needs.

I suspect that this is a bug in nfs-utils 1.1.3 which has been fixed in=20
1.1.4, since it works on distributions which have upgraded to 1.1.4.=20
However, I cannot find anything obvious in the ChangeLog.

Downgrading to nfs-client-1.1.2 from OpenSuse 11.0 seems to work, but thi=
s=20
is not an optimal solution. Since Novell doesn't have a public SLE=20
Bugzilla, there's no place to report this bug, but perhaps some Novell=20
developers are reading this list?

Best regards,=20
---
Peter =C5strand		ThinLinc Chief Developer
Cendio AB		http://www.cendio.com
Wallenbergs gata 4
583 30 Link=F6ping	Phone: +46-13-21 46 00
--789237761-40157612-1240574152=:7710
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Register Now & Save for Velocity, the Web Performance & Operations 
Conference from O'Reilly Media. Velocity features a full day of 
expert-led, hands-on workshops and two days of sessions from industry 
leaders in dedicated Performance & Operations tracks. Use code vel09scf 
and Save an extra 15% before 5/3. http://p.sf.net/sfu/velocityconf
--789237761-40157612-1240574152=:7710
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

--789237761-40157612-1240574152=:7710--


