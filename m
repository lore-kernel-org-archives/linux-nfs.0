From: Marc Eshel <eshel@almaden.ibm.com>
Subject: nfs-utils statd -N should exit
Date: Tue, 16 Nov 2004 09:24:34 -0800
Message-ID: <OFFF1E1A13.F0959038-ON88256F4E.005E87BC-88256F4E.005FA256@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CU79H-0003m2-WC
	for nfs@lists.sourceforge.net; Tue, 16 Nov 2004 09:29:47 -0800
Received: from e6.ny.us.ibm.com ([32.97.182.106])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CU79G-0005Oz-QA
	for nfs@lists.sourceforge.net; Tue, 16 Nov 2004 09:29:47 -0800
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.12.10/8.12.9) with ESMTP id iAGHTfm5151118
	for <nfs@lists.sourceforge.net>; Tue, 16 Nov 2004 12:29:41 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iAGHTfJZ282966
	for <nfs@lists.sourceforge.net>; Tue, 16 Nov 2004 12:29:41 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.12.11) with ESMTP id iAGHTeML023082
	for <nfs@lists.sourceforge.net>; Tue, 16 Nov 2004 12:29:41 -0500
To: Neil Brown <neilb@cse.unsw.edu.au>
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





Hi Neil,

Statd doesn't exit after it is run with -N (notify-only). The following
patch will fix this problem. Can you please add this patch to the code or
find another way to make it exit.

Thanks, Marc.

 --- svc_run.c.orig     2004-11-15 17:29:40.000000000 -0800
+++ svc_run.c     2004-11-15 17:07:55.000000000 -0800
@@ -103,6 +103,8 @@ my_svc_run(void)
            selret = select(FD_SETSIZE, &readfds,
                  (void *) 0, (void *) 0, &tv);
   } else {
+           if (run_mode & MODE_NOTIFY_ONLY)
+                 return;
            dprintf(N_DEBUG, "Waiting for client connections.");
            selret = select(FD_SETSIZE, &readfds,
                  (void *) 0, (void *) 0, (struct timeval *) 0);



-------------------------------------------------------
This SF.Net email is sponsored by: InterSystems CACHE
FREE OODBMS DOWNLOAD - A multidimensional database that combines
robust object and relational technologies, making it a perfect match
for Java, C++,COM, XML, ODBC and JDBC. www.intersystems.com/match8
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
