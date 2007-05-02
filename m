From: Neil Brown <neilb@suse.de>
Subject: Re: setting specific lockd port for NFS .....................
Date: Wed, 2 May 2007 22:47:23 +1000
Message-ID: <17976.34907.530222.646539@notabene.brown>
References: <OF64408285.26F63D4C-ON852572CF.00419070-852572CF.00426FDC@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Terry Spaulding <spauld@us.ibm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HjEFH-0005ak-Tl
	for nfs@lists.sourceforge.net; Wed, 02 May 2007 05:47:47 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HjEFJ-0005sV-B5
	for nfs@lists.sourceforge.net; Wed, 02 May 2007 05:47:50 -0700
In-Reply-To: message from Terry Spaulding on Wednesday May 2
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

On Wednesday May 2, spauld@us.ibm.com wrote:
> 
> Neil,
> 
> I tried the same settings for lockd on the SLES8 system and the lockd
> settings do not work in /etc/zipl.conf
> 
> I did some research on SLES8 and setting the lockd ports and found some
> info that shows the zipl.conf noted
> below works for SLES8 but there maybe some additional settings required to
> support lockd port setting as a kernel parameter.
> 
> I found some references to using sysctl and another to use one of the /etc
> conf files but no details on what was entered in these files.
> 
> We are planning on replacing all of the SLES8's but later in the year. Can
> anyone shed some light on setting the nlm.lockd port on SLES8 ?

SLES8 is 2.4 based which does this a bit differently to 2.6.

Kernel parameters are lockd.udpport and lockd.tcpport
module parameters are nlm_udpport and nlm_tcpport.

I suspect the former is what you want to put in zipl.conf

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
