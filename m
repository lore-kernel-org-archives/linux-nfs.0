From: Gabriel Barazer <gabriel@oxeva.fr>
Subject: patch: nfsstat signed counter bug
Date: Fri, 29 Jun 2007 23:45:34 +0200
Message-ID: <46857D7E.1080002@oxeva.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------040109080900020708060301"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I4OHi-0004Ml-5d
	for nfs@lists.sourceforge.net; Fri, 29 Jun 2007 14:45:46 -0700
Received: from mail.reagi.com ([195.60.188.80])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I4OHi-0003lG-Qo
	for nfs@lists.sourceforge.net; Fri, 29 Jun 2007 14:45:49 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This is a multi-part message in MIME format.
--------------040109080900020708060301
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hello,

This is not a critical bug as it is about an informational only tool, 
but I observed a counter bug in nfsstat :
# nfsstat -s
Server rpc stats:
calls      badcalls   badauth    badclnt    xdrcall
1647216427   0          0          0          0

Server nfs v3:
null         getattr      setattr      lookup       access       readlink
3668      0% 1642587440 27% 1636642   0% 160803697  2% -219165970 68% 
54477     0%
read         write        create       mkdir        symlink      mknod
39195344  0% 8113663   0% 3336779   0% 36784     0% 0         0% 
0         0%
remove       rmdir        rename       link         readdir      readdirplus
3981274   0% 37602     0% 310174    0% 220157    0% 1180237   0% 
1907416   0%
fsstat       fsinfo       pathconf     commit
43        0% 1841      0% 0         0% 644317    0%

---------
It is very clear that counters are looping and displaying negative 
values after counting 2^31 calls even on x86_64 platform with 64-bit Linux.
Looking at the code shows some printf's with incorrect format such as %-8d

Attached patch against nfs-utils 1.1.0 corrects this behavior to allow 
numbers with a length of 11, and reformats the display (align numbers 
and headers on the right, much easier to read). Now, up to 99 billions 
can be counted on 64-bit systems (2^32 on 32-bit), which is a very 
higher limit than ~2 billions on a moderate used NFS client/server.

Gabriel

--------------040109080900020708060301
Content-Type: text/plain;
 name="nfs-utils-1.1.0-nfsstat-format.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfs-utils-1.1.0-nfsstat-format.diff"

--- nfs-utils-1.1.0.orig/utils/nfsstat/nfsstat.c	2007-05-11 05:40:57.000000000 +0200
+++ nfs-utils-1.1.0/utils/nfsstat/nfsstat.c	2007-06-29 23:10:13.982044000 +0200
@@ -335,7 +335,7 @@
 		if (opt_prt & PRNT_NET) {
 			print_numbers(
 			"Server packet stats:\n"
-			"packets    udp        tcp        tcpconn\n",
+			"    packets         udp         tcp     tcpconn\n",
 			svcnetinfo, 4
 			);
 			printf("\n");
@@ -343,7 +343,7 @@
 		if (opt_prt & PRNT_RPC) {
 			print_numbers(
 			"Server rpc stats:\n"
-			"calls      badcalls   badauth    badclnt    xdrcall\n",
+			"      calls    badcalls     badauth     badclnt     xdrcall\n",
 			svcrpcinfo, 5
 			);
 			printf("\n");
@@ -351,7 +351,7 @@
 		if (opt_prt & PRNT_RC) {
 			print_numbers(
 			"Server reply cache:\n"
-			"hits       misses     nocache\n",
+			"       hits      misses     nocache\n",
 			svcrcinfo, 3
 			);
 			printf("\n");
@@ -373,12 +373,12 @@
 				
 				print_numbers(
 					"Server file handle cache:\n"
-					"lookup     anon       ncachedir  ncachedir  stale\n",
+					"     lookup        anon   ncachedir   ncachedir       stale\n",
 					svcfhinfo + 1, 5);
 			} else					/* < 2.4 */
 				print_numbers(
 					"Server file handle cache:\n"
-					"lookup     anon       ncachedir  ncachedir  stale\n",
+					"     lookup        anon   ncachedir   ncachedir       stale\n",
 					svcrcinfo + 3, 5);
 			printf("\n");
 		}
@@ -410,7 +410,7 @@
 		if (opt_prt & PRNT_NET) {
 			print_numbers(
 			"Client packet stats:\n"
-			"packets    udp        tcp        tcpconn\n",
+			"    packets         udp         tcp     tcpconn\n",
 			cltnetinfo, 4
 			);
 			printf("\n");
@@ -418,7 +418,7 @@
 		if (opt_prt & PRNT_RPC) {
 			print_numbers(
 			"Client rpc stats:\n"
-			"calls      retrans    authrefrsh\n",
+			"      calls     retrans  authrefrsh\n",
 			cltrpcinfo, 3
 			);
 			printf("\n");
@@ -465,7 +465,7 @@
 
 	fputs(hdr, stdout);
 	for (i = 0; i < nr; i++)
-		printf("%s%-8d", i? "   " : "", info[i]);
+		printf("%s%11u", i ? " " : "", info[i]);
 	printf("\n");
 }
 
@@ -484,11 +484,11 @@
 		total = 1;
 	for (i = 0; i < nr; i += 6) {
 		for (j = 0; j < 6 && i + j < nr; j++)
-			printf("%-13s", names[i+j]);
+			printf("%s%11s", j ? "     " : "", names[i+j]);
 		printf("\n");
 		for (j = 0; j < 6 && i + j < nr; j++) {
 			pct = ((unsigned long long) info[i+j]*100)/total;
-			printf("%-8d%3llu%% ", info[i+j], pct);
+			printf("%s%11u%3llu%%", j ? " " : "", info[i+j], pct);
 		}
 		printf("\n");
 	}

--------------040109080900020708060301
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--------------040109080900020708060301
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------040109080900020708060301--
