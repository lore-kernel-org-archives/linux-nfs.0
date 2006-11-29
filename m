From: ara.t.howard@noaa.gov
Subject: tuning guidelines
Date: Wed, 29 Nov 2006 08:55:46 -0700 (MST)
Message-ID: <Pine.LNX.4.62.0611290849570.20046@harp.ngdc.noaa.gov>
Reply-To: ara.t.howard@noaa.gov
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GpRmv-0004fp-Qz
	for nfs@lists.sourceforge.net; Wed, 29 Nov 2006 07:55:58 -0800
Received: from harp.ngdc.noaa.gov ([140.172.178.33])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GpRmv-0000c6-1C
	for nfs@lists.sourceforge.net; Wed, 29 Nov 2006 07:55:59 -0800
Received: from harp.ngdc.noaa.gov (localhost.localdomain [127.0.0.1])
	by harp.ngdc.noaa.gov (8.12.11.20060308/8.12.11) with ESMTP id
	kATFtkZA015615
	for <nfs@lists.sourceforge.net>; Wed, 29 Nov 2006 08:55:46 -0700
Received: from localhost (ahoward@localhost)
	by harp.ngdc.noaa.gov (8.12.11.20060308/8.12.11/Submit) with ESMTP id
	kATFtkTG015611
	for <nfs@lists.sourceforge.net>; Wed, 29 Nov 2006 08:55:46 -0700
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


we've got an nfs server and the data source/sink of a small (5 nodes) linux
cluster running ruby queue.  node of the nodes work over nfs: they all follow
a copy input local, perform work, copy output up to server approach.

we're running about 2000 jobs per day with average input sizes ranging
40mb-1gb and average outputs of 100mb-5gb.

taking into account this sort of usage pattern, can someone reccomend a rough
set of performance tuning guidelines or post a link on the subject?

i'm not looking to to go too deep in tuning - just rough guidelines at this
point: low hanging fruit.

kind regards.

-a
-- 
if you want others to be happy, practice compassion.
if you want to be happy, practice compassion.  -- the dalai lama

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
