From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: [PATCH] 0/3 - NFS iostat support: introduction
Date: Wed, 31 Mar 2004 08:34:05 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C61130435DE30@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B8ifR-0007vK-6p
	for nfs@lists.sourceforge.net; Wed, 31 Mar 2004 08:34:17 -0800
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1B8ifQ-00049Z-UZ
	for nfs@lists.sourceforge.net; Wed, 31 Mar 2004 08:34:16 -0800
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>,
        "Olaf Kirch" <okir@suse.de>, "Steve Dickson" <SteveD@redhat.com>,
        "Jeremy McNicoll" <jeremy@mcnicoll.ca>,
        "Patrick Mochel" <mochel@digitalimplant.org>
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

Following three patches are what I have so far for implementing support
in the NFS client for iostat and sar I/O metrics.  These are against
2.6.5-rc2 with Trond's NFS4_ALL patch.

Still left to do:

1.  Select a final resting place.  The stats now reside in
    /proc/fs/placeholder/iostat

2.  Need to provide GSS metrics in the RPC layer, and find
    better ways of measuring cache behavior in the NFS
    client.  May want to reduct the number of metrics we
    maintain.

3.  NFSv4 is not measured yet, but it should be easy to
    add basic support for, once these patches are
    acceptable.

Comments, review, new ideas are welcome.

        - Chuck Lever
--
corporate:     <cel at netapp dot com>
personal:      <chucklever at bigfoot dot com>


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
