From: Mike Eisler <mike@eisler.com>
Subject: RE: disable caching in NFS
Date: Fri, 06 Jun 2003 13:54:06 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EE0FF6E.8010609@eisler.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19OOEF-00033o-00
	for <nfs@lists.sourceforge.net>; Fri, 06 Jun 2003 13:54:27 -0700
Received: from frejya.corp.netapp.com (frejya [10.10.20.91])
	by mx01.netapp.com (8.12.9/8.12.9/NTAP-1.4) with ESMTP id h56KsEJo023334
	for <nfs@lists.sourceforge.net>; Fri, 6 Jun 2003 13:54:14 -0700 (PDT)
Received: from tahoe.corp.netapp.com (tahoe.corp.netapp.com [10.10.22.112])
	by frejya.corp.netapp.com (8.12.9/8.12.9/NTAP-1.5) with ESMTP id h56KsEtf015356
	for <nfs@lists.sourceforge.net>; Fri, 6 Jun 2003 13:54:14 -0700 (PDT)
To: nfs@lists.sourceforge.net
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

The application (vi) is opening the file, and
the Linux NFS client should be implementing
close-to-open semantics (meaning that the client will
revalidate its cache against the server upon every open).
Thus, this should not be necessary. Of course, if the server does not
update the file's modification time upon every write, or
if it does, but uses coarse granularity (e.g. one second),
then close-to-open semantics won't work. In that
event, the strategies Chuck Lever mentioned are among
what you can use to force the cache to be flushed or
unused.




-------------------------------------------------------
This SF.net email is sponsored by:  Etnus, makers of TotalView, The best
thread debugger on the planet. Designed with thread debugging features
you've never dreamed of, try TotalView 6 free at www.etnus.com.
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
