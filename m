From: Chris Penney <cpenney@gmail.com>
Subject: NFS Corruption
Date: Tue, 29 Mar 2005 16:08:16 -0500
Message-ID: <111aefd050329130844a0042e@mail.gmail.com>
Reply-To: penney@msu.edu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DGNwq-0005mf-31
	for nfs@lists.sourceforge.net; Tue, 29 Mar 2005 13:08:28 -0800
Received: from wproxy.gmail.com ([64.233.184.196])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DGNwp-0007ut-8L
	for nfs@lists.sourceforge.net; Tue, 29 Mar 2005 13:08:27 -0800
Received: by wproxy.gmail.com with SMTP id 69so652040wra
        for <nfs@lists.sourceforge.net>; Tue, 29 Mar 2005 13:08:21 -0800 (PST)
To: nfs@lists.sourceforge.net
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

Where I am we are starting to move to using Linux NFS servers now that
2.6 seems relatively stable (we need >2GB volumes) and I setup a SLES
9 with SP1 on a dual-cpu pentium4 system with 2GB ram and four 1TB san
supplied luns form an LSI array.  I tried various combonations of
jfs/xfs/resiserfs (mainly I was using jfs) with lvm2/md/dm for
building a volume (as well as a plain lun) and no matter what I did I
was getting corruption (I tried smp and up kernels).  Typically it
would show up as a bad md5sum of a ~2.5GB file I was copying from an
NFS client (a SuSE 9.1 system) while a couple of instances of iozone
or dbench were running.  It usually required a fsck to fix and was
fairly easily repeatable.  If I download 2.6.11.5 and apply NFS-ALL
and the latest DM patches everything seems fine.

Is this a known issue that was recently fixed?  The bug was really
easy for me to reproduce.  The main reason I'm asking is because I
really don't like to use a downloaded kernel tree with SLES 9 and I'd
like to know what needs to go in so I can watch for it and switch back
when it goes in.

Thanks,

   Chris


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
