From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] 1/3 - RPC metrics support
Date: Wed, 31 Mar 2004 11:46:07 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1080751567.4194.30.camel@lade.trondhjem.org>
References: <482A3FA0050D21419C269D13989C61130435DE31@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Olaf Kirch <okir@suse.de>, Steve Dickson <SteveD@redhat.com>, Jeremy McNicoll <jeremy@mcnicoll.ca>, Patrick Mochel <mochel@digitalimplant.org>,  nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B8ir5-0003Ao-Se
	for nfs@lists.sourceforge.net; Wed, 31 Mar 2004 08:46:19 -0800
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1B8ir5-0000lk-J1
	for nfs@lists.sourceforge.net; Wed, 31 Mar 2004 08:46:19 -0800
To: Charles Lever <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C61130435DE31@lavender-fe.eng.netapp.com>
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


My experience with gettimeofday() was that it slows down and eventually
hangs the machine when you use it inside bottom halves. That's why I had
to revert to using 'jiffies' instead. While I agree that precision may
be important, a measurement that so impacts on what it is measuring is
not particularly useful either...

Could you also move EXPORT_SYMBOL() definitions to after their function
definition, as per the 2.6.x recommendations.

Cheers,
  Trond

-- 
Trond Myklebust <trond.myklebust@fys.uio.no>


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
