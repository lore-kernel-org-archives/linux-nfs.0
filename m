From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: query about kernel 2.4.21-37.ELsmp
Date: Thu, 08 Jun 2006 09:50:54 -0400
Message-ID: <44882B3E.9000008@redhat.com>
References: <20060608085004.73262.qmail@web51611.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list2-b.sourceforge.net ([10.3.1.8]
	helo=sc8-sf-list2.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FoL23-0007W0-05
	for nfs@lists.sourceforge.net; Thu, 08 Jun 2006 06:58:43 -0700
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FoL22-0004N3-NX
	for nfs@lists.sourceforge.net; Thu, 08 Jun 2006 06:58:42 -0700
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FoL22-0001SM-P3
	for nfs@lists.sourceforge.net; Thu, 08 Jun 2006 06:58:42 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by externalmx-1.sourceforge.net with esmtp (Exim 4.41)
	id 1FoL21-0000GI-Se
	for nfs@lists.sourceforge.net; Thu, 08 Jun 2006 06:58:42 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id
	k58DrVPv001378
	for <nfs@lists.sourceforge.net>; Thu, 8 Jun 2006 09:53:31 -0400
Received: from pobox.corp.redhat.com (pobox.corp.redhat.com [172.16.52.156])
	by int-mx1.corp.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id
	k58DrVng012522
	for <nfs@lists.sourceforge.net>; Thu, 8 Jun 2006 09:53:31 -0400
Received: from [172.16.59.28]
	(IDENT:U2FsdGVkX1+4CFwgaoBVrgh1LcKLP0+tYvvIfaMAXSs@wendyc.rdu.redhat.com
	[172.16.59.28])
	by pobox.corp.redhat.com (8.12.8/8.12.8) with ESMTP id k58DrVTn012623
	for <nfs@lists.sourceforge.net>; Thu, 8 Jun 2006 09:53:31 -0400
To: nfs@lists.sourceforge.net
In-Reply-To: <20060608085004.73262.qmail@web51611.mail.yahoo.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

mehta kiran wrote:

>I tried all the steps you talked 
>about mount remains busy. The only
>thing effective which you mentioned
>is  killing nfsd. This causes kernel to 
>release all reference to exported fs.
>
>Steps to reproduce this problem :
>
>1. mount <device> <mountpoint>
>2. export it
>3. unexport it
>4. try umounting it. it wont
>
>
>
>  
>
I don't seem to be able to create it ..... ok, two more things:

* nfs-utils updated ?
*  do a "cat /proc/fs/nfs/exports" when umount fails and passes back the 
info.
* give me the "exact" command you used for unexport.

-- Wendy


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
