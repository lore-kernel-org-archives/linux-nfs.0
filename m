From: Terry Spaulding <spauld@us.ibm.com>
Subject: Re: setting specific lockd port for NFS .....................
Date: Wed, 2 May 2007 09:44:24 -0400
Message-ID: <OFC02E0FF4.48C3EEEC-ON852572CF.004B0F40-852572CF.004B79ED@us.ibm.com>
References: <OFE3F7DAE4.8FFD5934-ON852572CF.0049AC08-852572CF.004A71CA@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HjF7w-0000nx-DJ
	for nfs@lists.sourceforge.net; Wed, 02 May 2007 06:44:16 -0700
Received: from e1.ny.us.ibm.com ([32.97.182.141])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HjF7w-0005Gr-Jg
	for nfs@lists.sourceforge.net; Wed, 02 May 2007 06:44:19 -0700
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l42DiAWU017005
	for <nfs@lists.sourceforge.net>; Wed, 2 May 2007 09:44:10 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id
	l42DiAUt467608
	for <nfs@lists.sourceforge.net>; Wed, 2 May 2007 09:44:10 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	l42DiApE021032
	for <nfs@lists.sourceforge.net>; Wed, 2 May 2007 09:44:10 -0400
In-Reply-To: <OFE3F7DAE4.8FFD5934-ON852572CF.0049AC08-852572CF.004A71CA@us.ibm.com>
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

Neil,

I found typo on the lockd statement.

I should have set the kernel parms as: parameters="dasd=200-209
root=/dev/dasda1 lockd.tcpport=52670 lockd.udpport=52670"

Lockd is now set correctly.

On to testing.

Thanks for your assistance.


Regards,
Terry L. Spaulding
IBM
spauld@us.ibm.com


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
