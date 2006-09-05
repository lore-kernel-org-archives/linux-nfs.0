From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: linking librpcsecgss against libgssapi
Date: Tue, 5 Sep 2006 09:44:26 -0400
Message-ID: <4d569c330609050644w5f08c6a7mbde028c3dbc7765e@mail.gmail.com>
References: <200608311956.17014.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GKbE4-0006ZR-A7
	for nfs@lists.sourceforge.net; Tue, 05 Sep 2006 06:44:28 -0700
Received: from wr-out-0506.google.com ([64.233.184.231])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GKbE9-00007z-62
	for nfs@lists.sourceforge.net; Tue, 05 Sep 2006 06:44:34 -0700
Received: by wr-out-0506.google.com with SMTP id i22so629503wra
	for <nfs@lists.sourceforge.net>; Tue, 05 Sep 2006 06:44:26 -0700 (PDT)
To: "Mike Frysinger" <vapier@gentoo.org>
In-Reply-To: <200608311956.17014.vapier@gentoo.org>
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

On 8/31/06, Mike Frysinger <vapier@gentoo.org> wrote:
> is there a reason librpcsecgss is not linked against libgssapi ?  the simple
> fix here would be to add a line like:
> LDADD = $(GSSAPI_LIBS)
> to the librcpsecgss/src/Makefile.am file
>
> problem being that librpcsecgss uses symbols from libgssapi but never actually
> links against it so doing something simple like:
> echo 'int main(){}' > test.c
> gcc -lrpcsecgss test.c
> fails miserably unless you add -lgssapi
> -mike

The patch below will be included in the next release...

Thanks,
K.C.

--- src/Makefile.am     1 Aug 2006 17:06:37 -0000       1.8
+++ src/Makefile.am     5 Sep 2006 13:26:40 -0000
@@ -1,5 +1,6 @@
 lib_LTLIBRARIES = librpcsecgss.la
 librpcsecgss_la_LDFLAGS = -version-info 3:0:0
+librpcsecgss_la_LIBADD = $(GSSAPI_LIBS)
 librpcsecgss_la_SOURCES = \
        auth_gss.c authgss_prot.c svc.c svc_run.c svc_auth.c \
        svc_auth_none.c svc_auth_unix.c svc_auth_gss.c \

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
