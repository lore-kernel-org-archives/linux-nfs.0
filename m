From: Wendy Cheng <wcheng@redhat.com>
Subject: [PATCH] fix recursive nlm_file_mutex deadlock
Date: Wed, 09 Aug 2006 14:13:39 -0400
Message-ID: <44DA25D3.3010003@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------080907040208090808000000"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GAsZv-00037t-LP
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 11:14:51 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GAsZu-0006DD-Qg
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 11:14:52 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id
	k79IEdZo023227
	for <nfs@lists.sourceforge.net>; Wed, 9 Aug 2006 14:14:39 -0400
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com
	[172.16.52.154])
	by int-mx1.corp.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id
	k79IEd0x022894
	for <nfs@lists.sourceforge.net>; Wed, 9 Aug 2006 14:14:39 -0400
Received: from [172.16.59.28]
	(IDENT:U2FsdGVkX1/D7hCaxe6j+Z89fdwmA+MvU2O5Vy85bmM@wendyc.rdu.redhat.com
	[172.16.59.28])
	by lacrosse.corp.redhat.com (8.12.11.20060308/8.11.6) with ESMTP id
	k79IEdmh010303
	for <nfs@lists.sourceforge.net>; Wed, 9 Aug 2006 14:14:39 -0400
To: Linux NFS Mailing List <nfs@lists.sourceforge.net>
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

This is a multi-part message in MIME format.
--------------080907040208090808000000
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

I was testing NLM failover patches this morning and found the command 
hangs. Look like nlm_traverse_files(), where it grabs nlm_file_mutex 
early in the call, will have a chance to call nlm_release_file() via 
nlmsvc_free_block() inside kref_put(). The nlm_release_file() wants 
nlm_file_mutex too - this would generate a deadlock as the following:

dhcp59-234 kernel: Call Trace:
[<c02dd749>] __mutex_lock_slowpath+0x4c/0x7e
[<c02dd78a>] .text.lock.mutex+0xf/0x14
[<f8afeacd>] nlm_release_file+0x2b/0xdf [lockd]
[<f8afda90>] nlmsvc_free_block+0x8c/0x9d [lockd]
[<f8afda04>] nlmsvc_free_block+0x0/0x9d [lockd]
[<c01be98d>] kref_put+0x4e/0x58
[<f8afd175>] nlmsvc_traverse_blocks+0xaf/0xc6 [lockd]
[<f8afe960>] nlm_traverse_files+0x108/0x1cd [lockd]

The attached patch seems to fix the issue - it skips (defers) the file 
removal. Eventually either nlm_gc_hosts (some time later when client is 
unmonitored) or nlmsvc_traverse_files will finish the clean up.  Note 
that this is a 10-minutes  work - not sure its ramification at this 
moment. Take a look ?

-- Wendy


--------------080907040208090808000000
Content-Type: text/plain;
 name="gfs_nlm_deadlock.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="gfs_nlm_deadlock.patch"

--- linux-2/fs/lockd/svclock.c	2006-08-08 10:20:16.000000000 -0400
+++ linux/fs/lockd/svclock.c	2006-08-09 10:28:35.000000000 -0400
@@ -264,7 +264,9 @@ static void nlmsvc_free_block(struct kre
 
 	nlmsvc_freegrantargs(block->b_call);
 	nlm_release_call(block->b_call);
-	nlm_release_file(block->b_file);
+	down(&file->f_sema);
+	file->f_count--;
+	up(&file->f_sema);
 	kfree(block);
 }
 

--------------080907040208090808000000
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--------------080907040208090808000000
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------080907040208090808000000--
