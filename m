From: Jan Kasprzak <kas@fi.muni.cz>
Subject: NFS mount hang (no response to getattr)
Date: Tue, 19 Oct 2004 15:36:31 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20041019133630.GR21046@fi.muni.cz>
References: <20041015144701.GD4473@fi.muni.cz> <20041019120517.GO21046@fi.muni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CJuAF-0007B7-JG
	for nfs@lists.sourceforge.net; Tue, 19 Oct 2004 06:36:35 -0700
Received: from anor.ics.muni.cz ([147.251.4.35] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CJuAE-0003bF-M8
	for nfs@lists.sourceforge.net; Tue, 19 Oct 2004 06:36:35 -0700
Received: from anxur.fi.muni.cz (IDENT:0@anxur.fi.muni.cz [147.251.48.3])
	by anor.ics.muni.cz (8.12.1/8.12.1) with ESMTP id i9JDaW4k021895
	for <nfs@lists.sourceforge.net>; Tue, 19 Oct 2004 15:36:32 +0200
Received: from anxur.fi.muni.cz (IDENT:11561@localhost [127.0.0.1])
	by anxur.fi.muni.cz (8.12.10/8.12.8) with ESMTP id i9JDaVc4023230
	for <nfs@lists.sourceforge.net>; Tue, 19 Oct 2004 15:36:31 +0200 (MEST)
Received: (from kas@localhost)
	by anxur.fi.muni.cz (8.12.10/8.12.8/Submit) id i9JDaVKC023229
	for nfs@lists.sourceforge.net; Tue, 19 Oct 2004 15:36:31 +0200 (MEST)
To: nfs@lists.sourceforge.net
In-Reply-To: <20041019120517.GO21046@fi.muni.cz>
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

	Hello,

	I've sent the following to the LKML on Friday, but forgot to
explicitly Cc: the NFS maintainers. So I am forwarding this to the NFS list.

	Thanks,

-Yenya

Jan Kasprzak wrote:
: Hello, world!\n
: 
: 	I have ran into the following problem with Linux NFS code. Following
: examples are the simplest test (meaningless) cases, the real /etc/exports
: is more complicated, of course.
: 
: 	The problem is, that in some cases (depending on the contents of
: /etc/exports) mounting the NFS volume hangs. The NFS client gets filehandle
: from mount-daemon, but then it keeps retransmitting the NFS getattr call
: for the root directory of the to-be-mounted volume, while NFS server
: (nfsd on port 2049) does not respond. The tcpdump looks like this (first
: packets omitted, they look the same for both cases).
: 
: The non working case:
: [...]
: 15:38:09.512977 IP erinys2.fi.muni.cz.xxx > scylla.fi.muni.cz.nfs: 104 getattr fh 0,1/16777984
: 15:38:10.622833 IP erinys2.fi.muni.cz.xxx > scylla.fi.muni.cz.nfs: 104 getattr fh 0,1/16777984
: [ and the getattr call gets retransmitted ad infinitum ]
: 
: The working case:
: [...]
: 15:41:13.010098 IP erinys2.fi.muni.cz.xxx > scylla.fi.muni.cz.nfs: 104 getattr fh 0,1/16777984
: 15:41:13.010481 IP scylla.fi.muni.cz.nfs > erinys2.fi.muni.cz.xxx: reply ok 112 getattr DIR 40755 ids 0/0 sz 0x1000
: 15:41:13.010829 IP erinys2.fi.muni.cz.xxx > scylla.fi.muni.cz.nfs: 104 fsinfo fh 0,1/16777984
: [ the rest of traffic snipped ]
: 
: Note that in both cases, the getattr refers to the same fh.
: As I said, the difference is in /etc/exports. I have a single
: non-working case:
: 
: /tmp/1                          erinys2.fi.muni.cz(ro)
: /tmp/2                          erinys*.fi.muni.cz(ro)
: /tmp/3                          *.fi.muni.cz(ro)
: 
: (in tcpdump above, I am trying to mount scylla:/tmp/2 to erinys2:/mnt1).
: I can get mount of /tmp/2 working by any of the three modifications to
: /etc/exports on scylla (the last one is most strange one):
: 
: # Modification 1 - comment out the first line:
: #/tmp/1                         erinys2.fi.muni.cz(ro)
: /tmp/2                          erinys*.fi.muni.cz(ro)
: /tmp/3                          *.fi.muni.cz(ro)
:                                                                                 
: # Modification 2 - comment out the last line:
: /tmp/1                          erinys2.fi.muni.cz(ro)
: /tmp/2                          erinys*.fi.muni.cz(ro)
: #/tmp/3                         *.fi.muni.cz(ro)
:                                                                                 
: # Modification 3 - change "erinys*" to "eriny*" in the middle line:
: /tmp/1                          erinys2.fi.muni.cz(ro)
: /tmp/2                          eriny*.fi.muni.cz(ro)
: /tmp/3                          *.fi.muni.cz(ro)
: 
: Any of the above versions of /etc/exports makes mount of /tmp/2 on erinys2
: working. The problem may be that all exported directories are on the
: same physical volume on scylla. I have the following contents of
: /proc/fs/nfs/exports:
: 
: # Version 1.1
: # Path Client(Flags) # IPs
: /tmp/2  *.fi.muni.cz,erinys*.fi.muni.cz,erinys2.fi.muni.cz(ro,root_squash,sync,wdelay)
: 
: So maybe mount-daemon tells kernel something different than is written
: in /etc/exports.
: 
: The NFS server is 2.6.8.1-mm2 running on Fedora core 3 test3 on single-cpu
: x86-64 box, but I have tried i386 box running FC2 an x86_64 SMP box running
: RHEL3 too, with different kernels around 2.6.8.1 (vanilla 2.6.8.1, 2.6.7,
: 2.6.9-rc4). So the problem is probably not dependent on the distribution,
: compiler, SMPness or architecture. I have not tried 2.4 kernel.
: 
: I have tried two NFS clients - one is IRIX 6.5.22, the other is Linux i386
: box with FC2 and 2.6.7 kernel. IRIX box uses NFS v2 and v3 over UDP (I have
: tried -o vers=2 and -o vers=3), Linux box uses NFS v3, but I have tried v2
: as well.
: 
: I can provide more detailed information on demand. There is definitely
: a problem either with parsing wild-card export lists in rpc.mountd,
: or with kernel NFS-damon not responding to legitimate requests.
: 
: 	Does anybody see the problem here? Thanks,
: 
: -Yenya
: 
: P.S.: I have come with another strange case of /etc/exports: I am exporting
: 	only one directory for multiple wild-carded clients:
: 
: /tmp/2  erinys2.fi.muni.cz(ro) *.fi.muni.cz(ro) *.muni.cz(ro) eriny*.fi.muni.cz(ro)
: 
: 	This does not work (retransmits of getattr call), but by deleting
: _any_ of the four client descriptions in the above line it is possible
: to make it working.
: 
: -- 
: | Jan "Yenya" Kasprzak  <kas at {fi.muni.cz - work | yenya.net - private}> |
: | GPG: ID 1024/D3498839      Fingerprint 0D99A7FB206605D7 8B35FCDE05B18A5E |
: | http://www.fi.muni.cz/~kas/   Czech Linux Homepage: http://www.linux.cz/ |
: btw, David, I'm wondering about this loop: [...]  Is this
: a busy-wait-until-someone-plugs-in-more-ram-chips thing? ;)  --Andrew Morton

-- 
| Jan "Yenya" Kasprzak  <kas at {fi.muni.cz - work | yenya.net - private}> |
| GPG: ID 1024/D3498839      Fingerprint 0D99A7FB206605D7 8B35FCDE05B18A5E |
| http://www.fi.muni.cz/~kas/   Czech Linux Homepage: http://www.linux.cz/ |
btw, David, I'm wondering about this loop: [...]  Is this
a busy-wait-until-someone-plugs-in-more-ram-chips thing? ;)  --Andrew Morton

-- 
| Jan "Yenya" Kasprzak  <kas at {fi.muni.cz - work | yenya.net - private}> |
| GPG: ID 1024/D3498839      Fingerprint 0D99A7FB206605D7 8B35FCDE05B18A5E |
| http://www.fi.muni.cz/~kas/   Czech Linux Homepage: http://www.linux.cz/ |
btw, David, I'm wondering about this loop: [...]  Is this
a busy-wait-until-someone-plugs-in-more-ram-chips thing? ;)  --Andrew Morton


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
