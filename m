From: "Lever, Charles" <cel@netapp.com>
Subject: RE: interprtation of /proc/net/rpc/nfsd
Date: Mon, 11 Oct 2004 08:22:27 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C61130435E96A@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "James Pearson" <james-p@moving-picture.com>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CH21A-0000o2-Vq
	for nfs@lists.sourceforge.net; Mon, 11 Oct 2004 08:23:20 -0700
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CH20W-0000rE-CX
	for nfs@lists.sourceforge.net; Mon, 11 Oct 2004 08:23:20 -0700
To: "Steve Dickson" <SteveD@redhat.com>,
        "Jehan PROCACCIA" <Jehan.Procaccia@int-evry.fr>
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

> Well... zeroing out the nfs stats was something I proposed a=20
> while ago but got shoot down both internally and externally=20
> since zero out stats is "not the Linux way".... so I've taken=20
> the patch out of both FC and RHEL kernels, but I guess I=20
> forgot to take it out of the nfs-utils....

for the record, the reason that zeroing the kernel stats is a bad idea
is that this should really be a user-space thing.  otherwise, if process
A is sampling the stats and process B zeroes them, it will screw up
process A's samples.

we can get all the functionality we need by teaching the user-space
tools to subtract.  :-)


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
