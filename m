From: Denis Vlasenko <vda@ilport.com.ua>
Subject: [PATCH] enable stderr logging for mountd
Date: Thu, 10 Mar 2005 15:00:38 +0200
Message-ID: <200503101500.38409.vda@ilport.com.ua>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_2TEMCC0hfcHhCB7"
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D9Oym-0006sg-Ng
	for nfs@lists.sourceforge.net; Thu, 10 Mar 2005 06:49:36 -0800
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D9OPO-0004Ph-DJ
	for nfs@lists.sourceforge.net; Thu, 10 Mar 2005 06:13:04 -0800
Received: from [195.66.192.168] (helo=port.imtp.ilyichevsk.odessa.ua)
	by externalmx-1.sourceforge.net with smtp (Exim 4.41)
	id 1D9NJ7-0001qj-HF
	for nfs@lists.sourceforge.net; Thu, 10 Mar 2005 05:02:37 -0800
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


--Boundary-00=_2TEMCC0hfcHhCB7
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

I run my daemons under daemontools.
In this setup, they are best run as foreground processes
with logging to stout or stderr. mountd has some support
for this, but it is commented out. Let's enable it.

Patch also fixes handling of failure to open("/dev/null").

A few comments:
* We need xlog_background() BEFORE xlog_open(), or else
  log won't be directed to stderr.
* no need to add "mountd:", it is added by xlog() itself.

Please apply.
--
vda

--Boundary-00=_2TEMCC0hfcHhCB7
Content-Type: text/x-diff;
  charset="koi8-r";
  name="nfs-utils-1.0.7.mountd.c-2.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="nfs-utils-1.0.7.mountd.c-2.diff"

--- nfs-utils-1.0.7/utils/mountd/mountd.c.orig	Thu Mar 10 14:47:01 2005
+++ nfs-utils-1.0.7/utils/mountd/mountd.c	Thu Mar 10 14:52:41 2005
@@ -531,7 +531,8 @@ main(int argc, char **argv)
 		}
 	}
 	/* Initialize logging. */
-/*	xlog_open("mountd"); */
+	if (!foreground) xlog_background();
+	xlog_open("mountd");
 
 	sa.sa_handler = SIG_IGN;
 	sa.sa_flags = 0;
@@ -576,20 +577,20 @@ main(int argc, char **argv)
 		if ((c = fork()) > 0)
 			exit(0);
 		if (c < 0) {
-			xlog(L_FATAL, "mountd: cannot fork: %s\n",
+			xlog(L_FATAL, "cannot fork: %s\n",
 						strerror(errno));
 		}
 		/* Now we remove ourselves from the foreground.
 		   Redirect stdin/stdout/stderr first. */
 		{
 			int fd = open("/dev/null", O_RDWR);
+			if (fd < 0) xlog(L_FATAL, "cannot open /dev/null");
 			(void) dup2(fd, 0);
 			(void) dup2(fd, 1);
 			(void) dup2(fd, 2);
 			if (fd > 2) (void) close(fd);
 		}
 		setsid();
-		xlog_background();
 	}
 
 	my_svc_run();

--Boundary-00=_2TEMCC0hfcHhCB7--



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
