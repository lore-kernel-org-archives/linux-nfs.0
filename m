From: "Leisner, Martin" <Martin.Leisner-Y/v6x+lg+nkAvxtiuMwx3w@public.gmane.org>
Subject: showmount issues
Date: Thu, 17 Jul 2008 18:01:47 -0400
Message-ID: <556445368AFA1C438794ABDA8901891C09193BE1@USA0300MS03.na.xerox.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: <martyleisner@yahoo.com>
To: <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wvmler3.mail.xerox.com ([13.8.138.218]:43317 "EHLO
	wvmler3.mail.xerox.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758627AbYGQWYE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jul 2008 18:24:04 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have a system (which is using the legacy SUN derived rpcbind).

For some reason, showmount wasn't "always" working.   It reported
nothing when running from the command line, but worked under strace
(ugh!)

I was running fedora8 (showmount 1.1.0).
I built nfs-utils 1.1.2 -- same problems.

(I just tried a 1.0.6 on a RedHat Enterprise Linux 3 -- it worked fine)

Running the code under gdb, I found some "interesting" problems...

I changed:
bash2 :2 mleisner@mleisner-linux 05:59:55; rcsdiff -u showmount.c
===================================================================
RCS file: showmount.c,v
retrieving revision 1.1
diff -u -r1.1 showmount.c
--- showmount.c 2008/07/17 21:28:59     1.1
+++ showmount.c 2008/07/17 21:45:45
@@ -82,6 +82,8 @@
  *
  *  tout contains the timeout.  It will be modified to contain the time
  *  remaining (i.e. time provided - time elasped).
+ *
+ *    Returns 0 if it works
  */
 static int connect_nb(int fd, struct sockaddr_in *addr, struct timeval
*tout)
 {
@@ -177,7 +179,7 @@
                tout.tv_sec = TIMEOUT_TCP;

                ret = connect_nb(sock, &saddr, &tout);
-               if (ret == -1) {
+               if (ret < 0) {
                        close(sock);
                        rpc_createerr.cf_stat = RPC_SYSTEMERROR;
                        rpc_createerr.cf_error.re_errno = errno;
@@ -350,7 +352,7 @@
                                         MOUNTPROG, MOUNTVERS,
IPPROTO_TCP);
                if (server_addr.sin_port) {
                        ret = connect_nb(msock, &server_addr, 0);
-                       if (ret != -1)
+                       if (ret == 0)
                                mclient = clnttcp_create(&server_addr,
                                                MOUNTPROG, MOUNTVERS,
&msock,
                                                0, 0);


and now it works....

marty
