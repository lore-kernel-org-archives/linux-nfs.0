From: <barrie_spence@agilent.com>
Subject: RE: NFS suport block sharing
Date: Fri, 20 Feb 2004 13:25:55 -0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <0BA988FDBD6ADA4C8C5C5A177C6F1F6F2250D6@wsqfmb21b.britain.agilent.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AuAlE-00043i-K4
	for nfs@lists.sourceforge.net; Fri, 20 Feb 2004 05:32:08 -0800
Received: from msgbas1x.net.europe.agilent.com ([192.25.19.109])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AuAWW-000828-J0
	for nfs@lists.sourceforge.net; Fri, 20 Feb 2004 05:16:56 -0800
To: <Charles.Lever@netapp.com>, <okir@suse.de>,
	<trond.myklebust@fys.uio.no>
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




> Let me state my point though: how many people actually do mount a file
> system twice? And if they do, wouldn't that be exactly _because_ they
> want different semantics on the two mounts?

We use automount extensively. Yes, all the home directories would be
expected to share common mount options, but the remote filesystem may
contain more than home directories and we may mount separate parts
of the filesystems in different ways in different places.=20

Obviously, I wouldn't expect to use different rsize/wsize.

Barrie


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
