From: Tom Haynes <Thomas.Haynes-UdXhSnd/wVw@public.gmane.org>
Subject: Re: mount.nfs: access denied by server
Date: Tue, 25 Aug 2009 11:49:48 -0500
Message-ID: <4A94162C.20904@sun.com>
References: <31F3372A-891E-44EF-8DD2-78D5A3AD5CF1@oracle.com>
 <20090821200403.GA23529@fieldses.org>
 <EB232FA3-96EF-4332-94D5-61F465912838@oracle.com>
 <1250889345.5700.11.camel@heimdal.trondhjem.org>
 <20090821213016.GG23529@fieldses.org>
 <1250890836.5700.19.camel@heimdal.trondhjem.org>
 <20090821214720.GH23529@fieldses.org>
 <1250891463.5700.21.camel@heimdal.trondhjem.org>
 <20090824161004.GB4985@fieldses.org>
 <1251133618.6325.262.camel@heimdal.trondhjem.org>
 <20090824174129.GD4985@fieldses.org>
 <1EEDD90B-709F-4C78-97B4-6107AE100162@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; CHARSET=US-ASCII; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: Chuck Lever <Chuck.Lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from brmea-mail-2.Sun.COM ([192.18.98.43]:46143 "EHLO
	brmea-mail-2.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750821AbZHYQty (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Aug 2009 12:49:54 -0400
Received: from fe-amer-09.sun.com ([192.18.109.79])
	by brmea-mail-2.sun.com (8.13.6+Sun/8.12.9) with ESMTP id n7PGnuLX014909
	for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2009 16:49:56 GMT
Received: from conversion-daemon.mail-amer.sun.com by mail-amer.sun.com
 (Sun Java(tm) System Messaging Server 7u2-7.04 64bit (built Jul  2 2009))
 id <0KOX00100XVFBY00-suYR2Hc8r9/lQFUxb2hVpgC/G2K4zDHf@public.gmane.org> for linux-nfs@vger.kernel.org; Tue,
 25 Aug 2009 10:49:56 -0600 (MDT)
In-reply-to: <1EEDD90B-709F-4C78-97B4-6107AE100162@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
>
> RFC 2623 suggests how the server should sort the returned flavor 
> list.  However I don't think there's a consistent algorithm the client 
> can use with that list to determine a good default for that mount.  
> So, I would argue that any client that uses the "first" or "last" 
> entry in that list as the mount's auth flavor is probably broken; it 
> should pick a sec= default for all mounts, and if it's not on the 
> returned list, fail the mount.  That is, incidentally, what the kernel 
> MNT client does now.
>

   The MOUNT Version 3 protocol, associated with NFS Version 3, solves
   the problem by having the response to the MNT procedure include a
   list of flavors in the MNT procedure. Note that because some NFS
   servers will export file systems to specific lists of clients, with
   different access (read-only versus read-write), and with different
   security flavors, it is possible a client might get back multiple
   security flavors in the list returned in the MNT response. The use of
   one flavor instead of another might imply read-only instead of read-
   write access, or perhaps some other degradation of access. For this
   reason, a NFS client SHOULD use the first flavor in the list that it
   supports, on the assumption that the best access is provided by the
   first flavor. NFS servers that support the ability to export file
   systems with multiple security flavors SHOULD either present the best
   accessing flavor first to the client, or leave the order under the
   control of the system administrator.



It sounds pretty clear, the server SHOULD order them in some fashion and 
the client SHOULD
pick the first one it supports in the list. It is not 'MUST', but if all 
servers and clients follow the same
algorithm, it becomes accepted practice.

Having said that, our nfssec(5) states that a client can pick any of the 
modes in the list.

But our server returns them in the order entered in the share by the admin.

The client either:

1) Uses the explicit flavor set in the mount command.
or
2) Uses the first supported one in the list.
or
3) Fails the mount.

With OpenSolaris NFSv3, there is no autonegotiation.  With NFSv4, we 
support the autonegotiation
as defined in the protocol.

We just went through a regression with this algorithm.
