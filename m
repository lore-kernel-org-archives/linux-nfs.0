From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: [PATCH 2.6.3] Add write throttling to NFS client
Date: Wed, 3 Mar 2004 18:08:00 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C61130435DCCF@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "Shantanu Goel" <Shantanu.Goel@lehman.com>,
        "Bogdan Costescu" <bogdan.costescu@iwr.uni-heidelberg.de>,
        "Olaf Kirch" <okir@suse.de>, "Greg Banks" <gnb@melbourne.sgi.com>,
        <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AyiNJ-00077u-Sp
	for nfs@lists.sourceforge.net; Wed, 03 Mar 2004 18:14:13 -0800
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AyhyP-0003xJ-FM
	for nfs@lists.sourceforge.net; Wed, 03 Mar 2004 17:48:29 -0800
To: "Shantanu Goel" <sgoel01@yahoo.com>,
        "Trond Myklebust" <trond.myklebust@fys.uio.no>
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

> BTW, there was a one line nfs_rename fix I sent a
> while back.  At the time 2.6.0 was in freeze so it
> couldn't be integrated.  The issue was the NFS client
> does not refresh attributes after a rename causing
> some programs to spew out bogus errors.  One such
> culprit is GNU tar.

that fix is appropriate for 2.4, but trond tells me
that his attribute cache fixes will address this issue
in 2.6.


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
