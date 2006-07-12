From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Fwd:  nfs-utils compilation failing?
Date: Tue, 11 Jul 2006 23:09:59 -0400
Message-ID: <4d569c330607112009o56e869cfr47d91ad9347ead3@mail.gmail.com>
References: <OF11F5EA29.FE9B4626-ON882571A8.0071F565-882571A8.0072D28A@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sf.net, Usha Ketineni <uketinen@us.ibm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G0V6v-0004FT-TS
	for nfs@lists.sourceforge.net; Tue, 11 Jul 2006 20:10:01 -0700
Received: from ug-out-1314.google.com ([66.249.92.174])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G0V6v-0008CD-Mo
	for nfs@lists.sourceforge.net; Tue, 11 Jul 2006 20:10:02 -0700
To: "Neil Brown" <neilb@suse.de>
In-Reply-To: <OF11F5EA29.FE9B4626-ON882571A8.0071F565-882571A8.0072D28A@us.ibm.com>
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

Crap.  This is my fault.  It is the result of re-ordering patches that
I submitted for 1.0.9.  I have the following in a patch that I haven't
submitted yet:

diff -puN utils/gssd/write_bytes.h~gssd_handle_cfx_context
utils/gssd/write_bytes.h
--- nfs-utils-1.0.9/utils/gssd/write_bytes.h~gssd_handle_cfx_context	2006-07-10
14:46:13.929980000 -0400
+++ nfs-utils-1.0.9-kwc/utils/gssd/write_bytes.h	2006-07-10
14:46:14.017955000 -0400
@@ -63,6 +63,19 @@ write_buffer(char **p, char *end, gss_bu
 	return 0;
 }

+inline static int
+write_oid(char **p, char *end, gss_OID_desc *arg)
+{
+	int len = (int)arg->length;		/* make an int out of size_t */
+	if (WRITE_BYTES(p, end, len))
+		return -1;
+	if (*p + arg->length > end)
+		return -1;
+	memcpy(*p, arg->elements, len);
+	*p += len;
+	return 0;
+}
+
 static inline int
 get_bytes(char **ptr, const char *end, void *res, int len)
 {

_

---------- Forwarded message ----------
From: Usha Ketineni <uketinen@us.ibm.com>
Date: Jul 11, 2006 4:54 PM
Subject: [NFS] nfs-utils compilation failing?
To: nfs@lists.sf.net



Hi,

I am seeing a problem when tried to install the nfs-utils-1.0.9.

gssd-context_mit.o(.text+0x268): In function `serialize_krb5_ctx':
 /home/ketineni/nfs-utils-1.0.9/utils/gssd/context_mit.c:346:
undefined reference to `write_oid'
 collect2: ld returned 1 exit status
 make[2]: *** [gssd] Error 1
 make[2]: Leaving directory `/home/ketineni/nfs-utils-1.0.9/utils/gssd'
 make[1]: *** [all-recursive] Error 1
 make[1]: Leaving directory `/home/ketineni/nfs-utils-1.0.9/utils'
 make: *** [all-recursive] Error 1


As serialize_krb5_ctx() is surrounded by ifdef HAVE_KRB5 & ifdef
HAVE_LUCID_CONTEXT_SUPPORT, in the case where those
two variables are defined serialize_krb5_ctx() need write_oid which is
supposed to be defined somewhere. And in nfs-utils-1.0.8 it's
been defined.

I was able to compile the nfs-utils-1.0.9 package just by adding the
write_oid() function call in utils/gssd/write_bytes.h.  I am not sure
what
these variables are used for in the configure script.


Thanks
Usha

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
