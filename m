From: <peter@nicker.net>
Subject: Write delay optimization question
Date: Tue, 29 Jun 2004 11:41:28 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <2633.67.70.212.198.1088523688.squirrel@mail.nicker.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BfKjp-0002CE-E7
	for nfs@lists.sourceforge.net; Tue, 29 Jun 2004 08:41:37 -0700
Received: from static-90-14.dsl.tht.net ([216.126.90.14] helo=dyn-71-150.tor.dsl.tht.net)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1BfKjp-000337-1G
	for nfs@lists.sourceforge.net; Tue, 29 Jun 2004 08:41:37 -0700
Received: from nicker.net (localhost [127.0.0.1])
	by dyn-71-150.tor.dsl.tht.net (Postfix) with SMTP id E041D1D6CA
	for <nfs@lists.sourceforge.net>; Tue, 29 Jun 2004 11:41:28 -0400 (EDT)
To: <nfs@lists.sourceforge.net>
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

Hopefully some of the gurus on the list can help with this one...

Running Red Hat AS 3, with the 2.4.21-9.0.1 kernel, nfs3.  I am trying to
optimize the NFS daemon for huge file writes.  I have already modified
/include/linux/nfsd/const.h to set the max block size to 32KB.

My underlying filesystem uses a 256KB block size which spreads evenly ove=
r
a 4+P RAID array of 64KB segments.  Writing less than 256KB at a time
incurs a significant performance penalty.

My experience right now is that using async on the export allows 3-4 time=
s
as much data throughput on huge writes (small number of files, large
amount of data).  I would prefer to not use the async option if possible,
but it seems to me like the nfsd does not "queue" enough writes to write
out a full 256 kb block if sync operation is specified.  (I get lots of
read modify writes on the controller.)

Is there a tunable parameter somewhere that would allow me to increase th=
e
write buffering?  In the exports man page under no_wdelay it states "The
NFS server will normally delay committing a write request to disc slightl=
y
if it suspects another related write request may be in progress or may
arrive soon."  If I could increase this delay it might help my problem,
but I haven't been able to find it in the source.

Thanks!
Peter





-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
