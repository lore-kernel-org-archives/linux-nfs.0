From: Jacob <jacob@jhu.edu>
Subject: Re: network storage solutions - mounts [and other ranting]
Date: Thu, 15 May 2003 23:53:41 +0500 (GMT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.GSO.4.33.0305152331370.13731-100000@s01.clsp.jhu.edu>
References: <E19GNM4-0004wB-00@sc8-sf-list2.sourceforge.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.clsp.jhu.edu ([128.220.34.27])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19GNsh-00086F-00
	for <nfs@lists.sourceforge.net>; Thu, 15 May 2003 11:55:07 -0700
Received: from mailhost.clsp.jhu.edu (mailhost.clsp.jhu.edu [10.0.5.11])
	by mail.clsp.jhu.edu (8.9.3/8.9.3) with ESMTP id OAA20135
	for <nfs@lists.sourceforge.net>; Thu, 15 May 2003 14:55:16 -0400 (EDT)
Received: from s01.clsp.jhu.edu (s01.clsp.jhu.edu [10.0.10.1])
	by mailhost.clsp.jhu.edu (8.9.3/8.9.3) with ESMTP id OAA00679
	for <nfs@lists.sourceforge.net>; Thu, 15 May 2003 14:54:41 -0400 (EDT)
To: <nfs@lists.sourceforge.net>
In-Reply-To: <E19GNM4-0004wB-00@sc8-sf-list2.sourceforge.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

1. Close the list.
2. It is my experience that soft automount is more reliable in the
   long run.  less corrupt data and fewer reboots.  -soft mounting
   doesn't CAUSE corrupt data, badly synchronized distributed
   processing does.  (read: pour[sic] programmer/programming)
3. My most reliable server is a SUN Ultra2 running Sol8
   w/fiberchanel to a dual redundant RaidInc Array (Currently with
   36 sca disks)
3. Does anyone have any experience with the Apple Xserve w/Apple
   Xserve RAID under high through-put and high load?.

---------------------------------------------------------------
Jacob, System Admin at Center for Language & Speech Processing
mail: jacob@jhu.edu
- wife, boy, girl, sheep, goats, donkey, fowl, beehives-

> Message: 7
> From: "Josefa Blevins" <6uvdc1ii2@yahoo.com.hk>
> To: net-snmp-coders@lists.sourceforge.net
> Cc: <net-snmp-users-request@lists.sourceforge.net>, <netsaintplug-devel@lists.sourceforge.net>, <nfs@lists.sourceforge.net>, <nms-cgi-support@lists.sourceforge.net>
> Date: Mon, 28 Jan 02 21:54:04 GMT
> Subject: [NFS] Debt Relief is ON THE WAY! thet jzczhwdxe
>
> This is a multi-part message in MIME format.
<edited>
>
> --__--__--
>
> Message: 8
> Date: Thu, 15 May 2003 13:37:00 -0400
> From: Jeff Layton <jeffrey.b.layton@lmco.com>
> To: beowulf@beowulf.org
> Cc: Alvin Oga <alvin@Maggie.Linux-Consulting.com>, nfs@lists.sourceforge.net
> Reply-to: jeffrey.b.layton@lmco.com
> Organization: Lockheed-Martin Aeronautics Company
> Subject: [NFS] Re: network storage solutions - mounts
>
> Alvin Oga wrote:
>
> > On Wed, 14 May 2003, Glen Kaukola wrote:
> >
> > > Alvin Oga wrote:
> >
> > some kernel folks will tell you that using soft mount WILL cause
> > corrupt data  ... and that hard mount is better...



-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
