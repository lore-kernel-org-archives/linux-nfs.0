From: Jeff Garzik <jeff@garzik.org>
Subject: Linux client misses lack of open-confirm?
Date: Fri, 21 Dec 2007 23:15:11 -0500
Message-ID: <476C8F4F.7080100@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: NFS list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:49565 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751167AbXLVEPN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Dec 2007 23:15:13 -0500
Received: from cpe-069-134-071-233.nc.res.rr.com ([69.134.71.233] helo=core.yyz.us)
	by mail.dvmed.net with esmtpsa (Exim 4.63 #1 (Red Hat Linux))
	id 1J5vlY-0006C5-Gi
	for linux-nfs@vger.kernel.org; Sat, 22 Dec 2007 04:15:13 +0000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

While debugging my NFS server, I may have caught a Linux client bug.

My server is currently buggy, in that, it never sets the 
OPEN4_RESULT_CONFIRM bit after an OPEN with a new owner.  Shockingly, I 
can pass ~530 pynfs tests, fsx-linux [Linux v4 client], and build a 
kernel [Linux v4 client] even with such brokenness.  ;-)

Anyway, the Linux NFSv4 client (2.6.24-rc6) seems quite happy with this 
state of affairs, right until CLOSE time, when it passes "seqid + 2" to 
my server rather than the expected "seqid + 1".

Though I am quite happy that Linux managed to workaround my stupid 
server and store data successfully _anyway_, I thought it was worth 
commenting.  I was assuming either

	a) Linux would notice the lack of OPEN4_RESULT_CONFIRM and
	   complain accordingly, or,

	b) Linux would generate a correct seqid, taking into account
	   the fact that it did not issue OPEN_CONFIRM.

As you can see from the wireshark-0.99.7-2.fc8 binary dump at

	http://gtf.org/garzik/misc/dump.bz2 (33k compressed)

we see many examples of

	C:	OPEN	(seqid == 0)
	S:	NFS4_OK

	C:	[perhaps some intervening READ or WRITE or *ATTR]
	S:	[replies as expected]

	C:	CLOSE	(seqid == 2)
	S:	NFS4ERR_BAD_SEQID

If you feel this behavior is fine given a broken server, that's cool... 
  I just figured I would post in case somebody cared about this data point.

	Jeff


P.S.  I really really hate stateid/seqids at this point.  RFC 
nonwithstanding, they are basically undocumented.  I am reduced to 
poking through NFSv4 WG archives and Linux kernel code to find out what 
my server should be doing.  pynfs is no help here, either.
