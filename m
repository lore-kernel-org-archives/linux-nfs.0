From: Jan Bruvoll <jan@bruvoll.com>
Subject: Re: async vs. sync
Date: Tue, 27 Jul 2004 15:04:17 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <410660E1.3060700@bruvoll.com>
References: <482A3FA0050D21419C269D13989C61130435E51E@lavender-fe.eng.netapp.com> <200407270006.08581.bernd-schubert@web.de> <410643C5.3040004@bruvoll.com> <200407271500.38074.bernd-schubert@web.de> <Pine.LNX.4.58.0407272155450.1368@donald.themaw.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Bernd Schubert <bernd-schubert@web.de>,
 NFS mailling list <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BpSZM-0007YT-1I
	for nfs@lists.sourceforge.net; Tue, 27 Jul 2004 07:04:40 -0700
Received: from homer.brvl.com ([213.61.99.172])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1BpSZK-00025Z-Vm
	for nfs@lists.sourceforge.net; Tue, 27 Jul 2004 07:04:39 -0700
To: raven@themaw.net
In-Reply-To: <Pine.LNX.4.58.0407272155450.1368@donald.themaw.net>
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

Hi Ian,

raven@themaw.net wrote:

> How many threads is the server running?


In my desperation I bumped it all the way up to 128, which is about 50 
more than the number of simultaneous mounts.

Regards
Jan



-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
