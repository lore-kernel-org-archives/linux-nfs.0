From: "Burke, Alan" <Alan.Burke@analog.com>
Subject: NFS and/or autofs hanging on Linux
Date: Thu, 7 Oct 2004 09:31:58 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <8FDC0F9BE1F91D44BE964AA54AAA67B60E51ED7B@wilmexm3.ad.analog.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "Annie Mckeon" <anne.bourgeois@analog.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CFYOd-0005WV-5s
	for nfs@lists.sourceforge.net; Thu, 07 Oct 2004 06:33:27 -0700
Received: from nwd2mail2.analog.com ([137.71.25.51])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CFYNO-0004sU-Ug
	for nfs@lists.sourceforge.net; Thu, 07 Oct 2004 06:33:27 -0700
Received: from nwd2mhb2.analog.com (nwd2mhb2.analog.com [137.71.6.12])
	by nwd2mail2.analog.com (8.12.10/8.12.10) with ESMTP id i97DW9Nv031944
	for <nfs@lists.sourceforge.net>; Thu, 7 Oct 2004 09:32:09 -0400
Received: from wilmexm3.ad.analog.com ([10.66.5.19])
	by nwd2mhb2.analog.com (8.9.3 (PHNE_28810+JAGae91741)/8.9.3) with ESMTP id JAA18767
	for <nfs@lists.sourceforge.net>; Thu, 7 Oct 2004 09:32:11 -0400 (EDT)
To: <nfs@lists.sourceforge.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi Everyone,

We have got a problem with NFS hanging with automounter mounts.

We're running RH8 2.4.20-20.0 kernel
NFS-utils 1.0.1-2
Autofs4.1.2 (we must have the /net ability)
H/W is mixed HP4100's, Dell 2650's, Sun V60 and V65's
All the machines are in a Sun NIS domain with 700 Sun machines that run
fine.

The problem is intermittent; any automounter point can hang at any time.
For example auto_home may have 1000 entries
cd /home/user1 hangs and /home/user2 does not on machine Foo, but
/home/user2 is fine on machine Bar.

Once hung we sometimes can get it to release by umount -at nfs others
time a reboot is the only way to get it to release.

any help is appreciated

thanks,

alan



	 =20





-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
