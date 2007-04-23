From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
 on a privileged port??
Date: Mon, 23 Apr 2007 09:43:21 -0400
Message-ID: <462CB7F9.2040800@RedHat.com>
References: <17958.48121.280256.493824@notabene.brown>	<20070419012154.GB19063@javifsp.no-ip.org>	<17960.11704.321124.641669@notabene.brown>	<4629120C.60803@RedHat.com>	<17964.12324.307985.65596@notabene.brown>
	<17964.21206.435402.157895@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------030908000706080609010507"
Cc: Matthias Koenig <mkoenig@novell.com>, nfs@lists.sourceforge.net,
	Olaf Kirch <olaf.kirch@oracle.com>,
	=?ISO-8859-1?Q?Javier_Fern=E1ndez-Sanguino_Pe=F1a?= <jfs@computer.org>,
	anibal@debian.org
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HfyoW-0002in-LS
	for nfs@lists.sourceforge.net; Mon, 23 Apr 2007 06:42:44 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HfyoY-0003dH-V5
	for nfs@lists.sourceforge.net; Mon, 23 Apr 2007 06:42:47 -0700
In-Reply-To: <17964.21206.435402.157895@notabene.brown>
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
--------------030908000706080609010507
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit



Neil Brown wrote:
> On Monday April 23, neilb@suse.de wrote:
>> I think I'll add -u/-g flags
>> I might even include the Redhat code in #ifdef, so if compile with
>>  make RPCUSER=rpc
>> it will do the getpwnam..
> 
> I have added both compile-time and run-time setting of the uid and
> gid, and allowed a username to be set at compile time.  I have also
> made it possible to compile in host-name lookups.  The man-page
> auto-adjusts to match the compile options.
> 
>   make RPCUSER=rpc DAEMON_UID=4 DAEMON_GID=100 USE_DNS=yes
> 
> I think it is now should do all that I want, and should be a slot-in
> replacement for any distro that wants it (providing they choose
> appropriate Make options).
When porting this functionality to rpcbind, I made the setting of
the uid a configuration argument (i.e. --with-rpcuser=user)
See attached patch... Its basically doing the same thing in a
different way...

I guess I've become a fan of letting autoconf (and friends) create
the makefiles verses me hacking on them... although working with
that autoconf API can drive one to drink (which it has ;-) ) but
in the end, I do think it makes things a be more configurable...

steved.

--------------030908000706080609010507
Content-Type: text/x-patch;
 name="uid.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="uid.patch"

commit c24026e7c2949ede4fc292335df1a08c3f6575fe
Author: Steve Dickson <steved@redhat.com>
Date:   Fri Apr 20 13:10:58 2007 -0400

    Allow the uid that rpcbind runs as to be set during
    compile time with the --with-rpcuser configuration
    flag. The given uid will only be used if the -s
    flag is not given on the command.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/configure.in b/configure.in
index 0e2f163..dfe5907 100644
--- a/configure.in
+++ b/configure.in
@@ -37,6 +37,12 @@ if test "$warmstarts" = "true" ; then
 		AC_SUBST(statedir)
 	AC_DEFINE_UNQUOTED(RPCBIND_STATEDIR, "$statedir", [This defines the location where the state files will be kept for warm starts])
 fi
+AC_ARG_WITH(rpcuser,
+	[  --with-rpcuser=user uid to use [root]],
+	rpcuser=$withval,
+	rpcuser=root)
+	AC_SUBST(rpcuser)
+AC_DEFINE_UNQUOTED(RPCBIND_USER, "$rpcuser", [This defines the uid to run as])
 
 AC_CHECK_HEADERS([arpa/inet.h fcntl.h netdb.h \
                   netinet/in.h stdlib.h string.h \
diff --git a/src/rpcbind.c b/src/rpcbind.c
index 55bbd8d..2a900d9 100644
--- a/src/rpcbind.c
+++ b/src/rpcbind.c
@@ -68,6 +68,7 @@
 #include <pwd.h>
 #include <string.h>
 #include <errno.h>
+#include "config.h"
 #include "rpcbind.h"
 
 /*#define RPCBIND_DEBUG*/
@@ -79,6 +80,11 @@ int doabort = 0;	/* When debugging, do an abort on errors */
 
 rpcblist_ptr list_rbl;	/* A list of version 3/4 rpcbind services */
 
+#ifdef RPCBIND_USER
+char *rpcbinduser = RPCBIND_USER;
+#else
+char *rpcbinduser = NULL;
+#endif
 
 /* who to suid to if -s is given */
 #define RUN_AS  "daemon"
@@ -206,15 +212,16 @@ main(int argc, char *argv[])
         		err(1, "fork failed");
 	}
 
-	if (runasdaemon) {
+	if (runasdaemon || rpcbinduser) {
 		struct passwd *p;
+		char *id = runasdaemon ? RUN_AS : rpcbinduser;
 
-		if((p = getpwnam(RUN_AS)) == NULL) {
-			syslog(LOG_ERR, "cannot get uid of daemon: %m");
+		if((p = getpwnam(id)) == NULL) {
+			syslog(LOG_ERR, "cannot get uid of '%s': %m", id);
 			exit(1);
 		}
 		if (setuid(p->pw_uid) == -1) {
-			syslog(LOG_ERR, "setuid to daemon failed: %m");
+			syslog(LOG_ERR, "setuid to '%s' failed: %m", id);
 			exit(1);
 		}
 	}

--------------030908000706080609010507
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--------------030908000706080609010507
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------030908000706080609010507--
