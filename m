From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: [PATCH] 1/3 - RPC metrics support
Date: Wed, 31 Mar 2004 08:57:18 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C61130435DE34@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "Patrick Mochel" <mochel@digitalimplant.org>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B8j1s-0006Sm-I8
	for nfs@lists.sourceforge.net; Wed, 31 Mar 2004 08:57:28 -0800
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1B8j1s-0003Ek-IN
	for nfs@lists.sourceforge.net; Wed, 31 Mar 2004 08:57:28 -0800
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
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

> My experience with gettimeofday() was that it slows down and=20
> eventually hangs the machine when you use it inside bottom=20
> halves. That's why I had to revert to using 'jiffies'=20
> instead. While I agree that precision may be important, a=20
> measurement that so impacts on what it is measuring is not=20
> particularly useful either...

using jiffies makes these measurements useless for anything
faster than a millisecond (or 10 milliseconds on current
x86), which is most everything on 100Mb or faster, these
days.  isn't there some other solution?

> Could you also move EXPORT_SYMBOL() definitions to after=20
> their function definition, as per the 2.6.x recommendations.

i would prefer that we did this in a separate patch, and
moved all the symbols at once.


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
