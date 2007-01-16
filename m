From: Frank Steiner <fsteiner-mail1@bio.ifi.lmu.de>
Subject: Disapearing directories
Date: Tue, 16 Jan 2007 13:02:32 +0100
Message-ID: <45ACBED8.4040707@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H6n1a-0003qB-KB
	for nfs@lists.sourceforge.net; Tue, 16 Jan 2007 04:02:46 -0800
Received: from acheron.ifi.lmu.de ([129.187.214.135])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1H6n1V-00016m-VP
	for nfs@lists.sourceforge.net; Tue, 16 Jan 2007 04:02:48 -0800
Received: from internaldeliver.acheron.ifi.lmu.de (localhost [127.0.0.1])
	by acheron.ifi.lmu.de (Postfix) with ESMTP id 44359436E9
	for <nfs@lists.sourceforge.net>; Tue, 16 Jan 2007 13:02:32 +0100 (CET)
Received: from [141.84.1.30] (galois.bio.ifi.lmu.de [141.84.1.30])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by acheron.ifi.lmu.de (Postfix) with ESMTP id 301B743580
	for <nfs@lists.sourceforge.net>; Tue, 16 Jan 2007 13:02:32 +0100 (CET)
To: nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi,

server is running SLES 9 (latest Kernel for this is 2.6.5 with thousands
of SuSE patches...), clients are runing SLES 10 and SuSE 10.1.

We recently had some problems with the fibre channel bus, causing the
NFS-exported fs to disapear on the server. After restoring it and even
rebooting the NFS server, some clients are missing some subdirs. If
server hat /export/bla/blu, some clients see an empty /mnt/bla/ subdir,
others see the blu.

And I can't get rid of this. Restarting the nfs server, unexporting and
reexporting the server dirs, umount an remount on the clients, nothing 
helps!
So when I call "umount /mnt/; mount server:/export/ /mnt", still "blu"
is missing. However, when I call "mount server:/export/bla /mnt/bla",
then the /mnt/bla/ directory is filled again. Unmounting it again,
and then unmounting and remount "/mnt" as a whole still gives an empty
bla subdir.

Only rebooting the client solves that issue.

Maybe some caching issue? Like the client remembers that /mnt/bla
was empty sometime and now keeps that info even after umounting and
remounting? Can I flush the info on the client somehow?

We can't upgrade the SLES9 server because any newer kernel crashes
the IBM xSeries (IBM has been working on that for some months, no
solution so far).

cu,
Frank

-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049
* Rekursion kann man erst verstehen, wenn man Rekursion verstanden hat. *

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
