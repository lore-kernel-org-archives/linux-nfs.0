From: "Divyesh Amipara" <divyesh@techie.com>
Subject: Re: Mount hangs forever
Date: Thu, 22 Jul 2004 00:19:35 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040722051935.7FFA86EEE9@ws1-5.us4.outblaze.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BnVzb-0002mM-BI
	for nfs@lists.sourceforge.net; Wed, 21 Jul 2004 22:19:43 -0700
Received: from webmail-outgoing.us4.outblaze.com ([205.158.62.67])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1BnVzb-0005y0-3u
	for nfs@lists.sourceforge.net; Wed, 21 Jul 2004 22:19:43 -0700
Received: from wfilter.us4.outblaze.com (wfilter.us4.outblaze.com [205.158.62.180])
	by webmail-outgoing.us4.outblaze.com (Postfix) with QMQP id 93793180046A
	for <nfs@lists.sourceforge.net>; Thu, 22 Jul 2004 05:19:35 +0000 (GMT)
To: nfs@lists.sourceforge.net
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

Hi All,

I am trying to mount from nfs server running linux RH 8 from other
inux client
running RH 8

using this comman..


$ mount -o timeo=20,soft -t nfs 192.168.9.1:/home /mnt/home

but it hangs forever without getting Time Out. so if i am doing backup
after NFS mount it will never happen.

So pls suggest me how to resolve this kind of proble so that it
should come out when
NFS server will not respond or through some error.

Ok. Fine. Thanks.

>> Divyesh A.

-- 
___________________________________________________________
Sign-up for Ads Free at Mail.com
http://promo.mail.com/adsfreejump.htm



-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
