From: Steffen Persvold <sp@scali.com>
Subject: Input/output error on hard mounted NFS directory
Date: Tue, 14 May 2002 12:25:28 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.30.0205141159580.28229-100000@elin.scali.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from elin.scali.no ([62.70.89.10])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 177ZUt-0003mS-00
	for <nfs@lists.sourceforge.net>; Tue, 14 May 2002 03:25:36 -0700
Received: from localhost (sp@localhost)
	by elin.scali.no (8.12.3/8.12.3) with ESMTP id g4EAPTOb028492
	for <nfs@lists.sourceforge.net>; Tue, 14 May 2002 12:25:29 +0200
To: NFS mailinglist <nfs@lists.sourceforge.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Hi all,

I guess I've reported this before, but here we go again:

I'm compiling up a large project which resides on a NFS mounted
ext2 filesystem. In this case the NFS server is running RH 7.2
kernel-smp-2.4.9-21 (i686 version) nfs-utils-0.3.1-13.7.2.1, and the
client is running RH 6.2 kernel-enterprise-2.2.19-6.2.7 (i686 version).

The relevant /proc/mounts looks like this :

huey:/export/home/sp /home/sp nfs rw,v3,rsize=8192,wsize=8192,intr,addr=huey 0 0


What happens is that when all object files are compiled (this goes fine),
a static library is about to be created. This is when the client aborts :

#     Creating static library Linux2.i86pc.gnu/libmpi.a ...
ar: Linux2.i86pc.gnu/libmpi.a: Input/output error
make[4]: *** [Linux2.i86pc.gnu/libmpi.a] Error 1

If I try once more (just creating the static library) everything goes
fine. Another thing is that this is unfortunately not always reproducible.

Is there a know bug in some of my componets which could result in such an
error ? I would very much appreciate some pointers to what could be wrong
(not just 'upgrade to latest version, maybe it is fixed').

Thanks,
-- 
  Steffen Persvold   | Scalable Linux Systems |   Try out the world's best
 mailto:sp@scali.com |  http://www.scali.com  | performing MPI implementation:
Tel: (+47) 2262 8950 |   Olaf Helsets vei 6   |      - ScaMPI 1.13.8 -
Fax: (+47) 2262 8951 |   N0621 Oslo, NORWAY   | >320MBytes/s and <4uS latency


_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
