From: Jeffrey Layton <jtlayton@poochiereds.net>
Subject: Re: fcntl locks prevent unmounting of underlying filesystem
Date: Thu, 27 May 2004 13:31:19 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1085679079.7390.13.camel@tesla.mmt.bellhowell.com>
References: <1085589795.20517.41.camel@tesla.mmt.bellhowell.com>
	 <1085668036.6111.2.camel@tesla.mmt.bellhowell.com>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BTOix-0006Fo-Ec
	for nfs@lists.sourceforge.net; Thu, 27 May 2004 10:31:23 -0700
Received: from rdu26-93-067.nc.rr.com ([66.26.93.67] helo=salusa.poochiereds.net)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BTOiw-0006XM-4n
	for nfs@lists.sourceforge.net; Thu, 27 May 2004 10:31:22 -0700
Received: from localhost (localhost [127.0.0.1])
	by salusa.poochiereds.net (Postfix) with ESMTP id EA957E4A8
	for <nfs@lists.sourceforge.net>; Thu, 27 May 2004 13:31:12 -0400 (EDT)
Received: from salusa.poochiereds.net ([127.0.0.1])
	by localhost (salusa [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 19147-06 for <nfs@lists.sourceforge.net>;
	Thu, 27 May 2004 13:31:12 -0400 (EDT)
Received: from localhost (salusa.poochiereds.net [192.168.1.2])
	by salusa.poochiereds.net (Postfix) with ESMTP id 92EEF15E3
	for <nfs@lists.sourceforge.net>; Thu, 27 May 2004 13:31:12 -0400 (EDT)
To: nfs@lists.sourceforge.net
In-Reply-To: <1085668036.6111.2.camel@tesla.mmt.bellhowell.com>
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

Got a response from the linux-ha list that this is a known bug :-(. The
current workaround for HA setups seems to be to force an immediate
reboot if it occurs (blech!). Any ideas what the issue is, and how it
can be fixed?

Thanks,
Jeff





-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
