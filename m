From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: mountd memory leaks in 1.0.12
Date: Tue, 6 Mar 2007 13:52:30 +0100
Message-ID: <20070306125230.GA30735@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HOZAS-0001Sy-Ik
	for nfs@lists.sourceforge.net; Tue, 06 Mar 2007 04:53:24 -0800
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HOZAR-00042r-6t
	for nfs@lists.sourceforge.net; Tue, 06 Mar 2007 04:53:26 -0800
Received: from trofast.sesse.net ([129.241.93.32])
	by cassarossa.samfundet.no with esmtp (Exim 4.50) id 1HOZA1-0007Dd-3X
	for nfs@lists.sourceforge.net; Tue, 06 Mar 2007 13:52:57 +0100
Received: from sesse by trofast.sesse.net with local (Exim 3.36 #1 (Debian))
	id 1HOZ9a-00081R-00
	for <nfs@lists.sourceforge.net>; Tue, 06 Mar 2007 13:52:30 +0100
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

A user reported that 1.0.12 is leaking memory like crazy, and I can reproduce
it here. Running valgrind (with the Omega tool) on mountd reveals that the
new blkid code is the culprit, but almost every single leak seems to be
_allocated_ at the same spot, namely at blkid_probe_all_new() time.

A typical leaks goes like this:

  ==9584== Loss Record 7: Leaked 974848 (0xEE000) bytes in 14 blocks
  ==9584==    at 0x4030D80: blkid_verify (probe.c:914)
  ==9584==    by 0x402D981: blkid_get_dev (devname.c:82)
  ==9584==    by 0x402DBDE: probe_one (devname.c:145)
  ==9584==    by 0x402E7CB: probe_all (devname.c:510)
  ==9584==    by 0x402E983: blkid_probe_all_new (devname.c:551)
  ==9584==    by 0x804D26E: get_uuid (cache.c:173)
  ==9584==    by 0x804DDA7: dump_to_cache (cache.c:461)
  ==9584==    by 0x804E31A: cache_export_ent (cache.c:596)
  ==9584==    by 0x804E454: cache_export (cache.c:625)
  ==9584==    by 0x804B106: get_rootfh (mountd.c:421)
  ==9584==    by 0x804AE41: mount_mnt_3_svc (mountd.c:350)
  ==9584==    by 0x8055A1A: rpc_dispatch (rpcdispatch.c:55)
  ==9584==  Blocks allocated
  ==9584==    at 0x401CDA0: malloc (vg_replace_malloc.c:149)
  ==9584==    by 0x402F28B: get_buffer (probe.c:56)
  ==9584==    by 0x4030B64: blkid_verify (probe.c:862)
  ==9584==    by 0x402D981: blkid_get_dev (devname.c:82)
  ==9584==    by 0x402DBDE: probe_one (devname.c:145)
  ==9584==    by 0x402E7CB: probe_all (devname.c:510)
  ==9584==    by 0x402E983: blkid_probe_all_new (devname.c:551)
  ==9584==    by 0x804D26E: get_uuid (cache.c:173)
  ==9584==    by 0x804DDA7: dump_to_cache (cache.c:461)
  ==9584==    by 0x804E31A: cache_export_ent (cache.c:596)
  ==9584==    by 0x804E454: cache_export (cache.c:625)
  ==9584==    by 0x804B106: get_rootfh (mountd.c:421)

Over time, this amounts to gigabytes of RAM on a busy server. Either the
blkid library is generally really leaky (in which case we probably shouldn't
be using it until it's fixed), or we're using it wrong somehow. :-)

/* Steinar */
-- 
Homepage: http://www.sesse.net/

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
