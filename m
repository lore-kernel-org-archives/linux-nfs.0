From: Steve Dickson <SteveD@redhat.com>
Subject: Re: rebuilding redhat 2.4.20-30.9smp kernel with nfs tcp support
Date: Mon, 07 Jun 2004 14:17:33 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40C4B13D.8040403@RedHat.com>
References: <2B51611764AC0A4DB3A15200DD51E8E60907C5@mail2.chesapeakebay.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BXOgm-0006lb-UG
	for nfs@lists.sourceforge.net; Mon, 07 Jun 2004 11:17:40 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BXOgm-0007uE-EZ
	for nfs@lists.sourceforge.net; Mon, 07 Jun 2004 11:17:40 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.10/8.12.10) with ESMTP id i57IHXi5002514
	for <nfs@lists.sourceforge.net>; Mon, 7 Jun 2004 14:17:33 -0400
Received: from RedHat.com (vpn64-13.boston.redhat.com [172.16.66.13])
	by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id i57IHX001039
	for <nfs@lists.sourceforge.net>; Mon, 7 Jun 2004 14:17:33 -0400
To: nfs@lists.sourceforge.net
In-Reply-To: <2B51611764AC0A4DB3A15200DD51E8E60907C5@mail2.chesapeakebay.net>
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

Try:

$ make mrproper oldconfig
Edit the config file to turn on NFS over TCP
$ make bzImage modules

FYI... FC1 has it on by default....

SteveD.


-------------------------------------------------------
This SF.Net email is sponsored by: GNOME Foundation
Hackers Unite!  GUADEC: The world's #1 Open Source Desktop Event.
GNOME Users and Developers European Conference, 28-30th June in Norway
http://2004/guadec.org
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
