From: Anton Starikov <A.Starikov@utwente.nl>
Subject: Re: NFS cache problem
Date: Thu, 26 May 2005 01:44:14 +0200
Message-ID: <42950DCE.9050109@utwente.nl>
References: <429503BA.4060908@utwente.nl> <1117064050.12336.67.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Db5Y6-00018e-5D
	for nfs@lists.sourceforge.net; Wed, 25 May 2005 16:44:30 -0700
Received: from netlx010.civ.utwente.nl ([130.89.1.92])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Db5Y4-0005Rb-51
	for nfs@lists.sourceforge.net; Wed, 25 May 2005 16:44:29 -0700
Received: from [130.89.204.129] (hantst.kabel.utwente.nl [130.89.204.129])
          by netlx010.civ.utwente.nl (8.11.7/HKD) with ESMTP id j4PNiEH03876
          for <nfs@lists.sourceforge.net>; Thu, 26 May 2005 01:44:14 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <1117064050.12336.67.camel@lade.trondhjem.org>
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

Trond Myklebust wrote:
> The NFS cache consistency model is discussed in the FAQ. Please see
> http://nfs.sourceforge.net/#faq_a8

I did it long time ago. I've reread it now.
My usage fits this. I have "noac" and "sync" on client side. What's more? :)

Can ACL be a problem?

Best regards,
	Anton


-------------------------------------------------------
SF.Net email is sponsored by: GoToMeeting - the easiest way to collaborate
online with coworkers and clients while avoiding the high cost of travel and
communications. There is no equipment to buy and you can meet as often as
you want. Try it free.http://ads.osdn.com/?ad_id=7402&alloc_id=16135&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
