From: ahoward <ahoward@fsl.noaa.gov>
Subject: safely updating nfs exported files
Date: Tue, 18 Feb 2003 16:15:30 +0000 (GMT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.33.0302181603530.18819-100000@eli.fsl.noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from gatekeeper.fsl.noaa.gov ([137.75.1.181])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18lAJY-0008J2-00
	for <nfs@lists.sourceforge.net>; Tue, 18 Feb 2003 08:09:48 -0800
Received: from eli.fsl.noaa.gov (eli.fsl.noaa.gov [137.75.132.144])
	by gatekeeper.fsl.noaa.gov (8.9.3/8.9.3) with ESMTP id QAA11133
	for <nfs@lists.sourceforge.net>; Tue, 18 Feb 2003 16:09:17 GMT
To: <nfs@lists.sourceforge.net>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>



nfs'ers-

i'm deliberating two methods of updating nfs exported files read by our
near-realtime linux clients and written by a single updating process :

  a)  some combination of locking, probably using ${file}.lock and fcntl
  read/write locks to protect the file during update

  b) a combination of 'mv update nfs.tmp; mv update nfs.prev; mv nfs.tmp nfs'
  in the updating processes and fault tolerance code in the reading clients
  which will attempt to open files > once so that during the brief spell when
  the file is not available (mv update nfs.prev) failed opens will be retried.

my environment is primarily linux clients running against a netapp server -
nfsV3.  however, there are other legacy OS's which will also need to use
whatever mechanism i come up with (IRIX, HP-UX, Solaris, etc) and thus i am
leaning towards solution 'b' since it requires only that clients be prepared
to attempt opens > once and yet multiple reader single writer semantics are
preserved without the use of locks (and their problems).  does anyone have
opiions on this?  other suggestions?

-a

-- 

 ====================================
 | Ara Howard
 | NOAA Forecast Systems Laboratory
 | Information and Technology Services
 | Data Systems Group
 | R/FST 325 Broadway
 | Boulder, CO 80305-3328
 | Email: ahoward@fsl.noaa.gov
 | Phone:  303-497-7238
 | Fax:    303-497-7259
 ====================================



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
