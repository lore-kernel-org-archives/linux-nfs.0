From: Peter Staubach <staubach@redhat.com>
Subject: Re: export very large filesystem
Date: Mon, 21 Nov 2005 11:12:26 -0500
Message-ID: <4381F1EA.2020602@redhat.com>
References: <4381DDBA.9090509@chrisdos.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EeEHp-0003Ua-NE
	for nfs@lists.sourceforge.net; Mon, 21 Nov 2005 08:12:57 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EeEHn-0003bp-D5
	for nfs@lists.sourceforge.net; Mon, 21 Nov 2005 08:12:57 -0800
To: Chris Dos <chris@chrisdos.com>
In-Reply-To: <4381DDBA.9090509@chrisdos.com>
Sender: nfs-admin@lists.sourceforge.net
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

Chris Dos wrote:

> I have a customer that would like to export their 22.5 TB XFS file 
> system via NFS using Linux 2.6.14.  Before I even attempt to do this, 
> can NFS v2/3/4 even handle something like this? 


As mentioned, yes.  NFSv2 limits file sizes and the total number of blocks
in file systems to 32 bit quantities, so it won't, but NFSv3 and NFSv4 use
64 bit quantities, so they can.

       ps


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.  Get Certified Today
Register for a JBoss Training Course.  Free Certification Exam
for All Training Attendees Through End of 2005. For more info visit:
http://ads.osdn.com/?ad_id=7628&alloc_id=16845&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
