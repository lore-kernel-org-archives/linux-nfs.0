From: Yusuf Goolamabbas <yusufg@outblaze.com>
Subject: Re: [PATCH] Timeouts gone wild on ia64
Date: Thu, 18 Sep 2003 15:03:52 +0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030918070352.GA23924@outblaze.com>
References: <482A3FA0050D21419C269D13989C6113127DC8@lavender-fe.eng.netapp.com> <3EC39FDF.60609@RedHat.com> <16067.42148.524146.39488@charged.uio.no> <20030917041418.GA8900@outblaze.com> <16232.26027.789453.979782@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19zspr-0007ct-00
	for <nfs@lists.sourceforge.net>; Thu, 18 Sep 2003 00:04:15 -0700
Received: from corpmail.outblaze.com ([203.86.166.82])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19zspq-0004k2-B3
	for nfs@lists.sourceforge.net; Thu, 18 Sep 2003 00:04:14 -0700
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by corpmail.outblaze.com (Postfix) with ESMTP id 6B33F37AC4
	for <nfs@lists.sourceforge.net>; Thu, 18 Sep 2003 07:04:11 +0000 (GMT)
Received: from yusufg.portal2.com (210-177-227-130.outblaze.com [210.177.227.130])
	by corpmail.outblaze.com (Postfix) with SMTP id D05CC16DD84
	for <nfs@lists.sourceforge.net>; Thu, 18 Sep 2003 07:04:10 +0000 (GMT)
To: nfs@lists.sourceforge.net
In-Reply-To: <16232.26027.789453.979782@charged.uio.no>
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

>      > Trond, In your opinion. What should be the default retrans
>      > value given your recent work in having adaptive timeouts in the
>      > NFS client ?
> 
> I'd like to cap the minimum value for the estimated error on the RTO
> at 1/10sec as per the 2.6 kernel (currently it is set at 2/HZ sec ~
> 2/100sec on most architectures, but 2/1000sec on ia64).
> 
> Then I'd like to increase the default value that "mount" uses for
> "retrans" to the kernel value (which is currently set at 5).

What value are you looking at ?
Also man 5 nfs seems (in RH 9) that default retrans value is 3




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
