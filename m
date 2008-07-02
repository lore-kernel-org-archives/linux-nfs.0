From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Subject: Re: [Patch] enable preferred realms for ccache searching
Date: Wed, 2 Jul 2008 19:24:09 +0200
Message-ID: <20080702172409.GU5111@ics.muni.cz>
References: <20080624153524.GK4484@ics.muni.cz>
	<4d569c330807020853m37a834ex5ba191faf85b0f97@mail.gmail.com>
	<20080702160924.GT5111@ics.muni.cz>
	<4d569c330807021018ka2c6ad6t573caae886fb5307@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="45Z9DzgjV8m4Oswq"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <4d569c330807021018ka2c6ad6t573caae886fb5307@mail.gmail.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>


--45Z9DzgjV8m4Oswq
Content-Type: text/plain; charset=iso-8859-2
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jul 02, 2008 at 01:18:46PM -0400, Kevin Coffman wrote:
> Thanks, but I'm already cleaning it up.  I'll re-post for you look at
> before sending up to Steve.

OK, thanks

> > Also, if interested, I have a patch to set the default preferred real=
m
> > from the kerberos configuration.
>=20
> I think that would be a nice thing to add to this.

attached.

--=20
Luk=E1=B9 Hejtm=E1nek

--45Z9DzgjV8m4Oswq
Content-Type: text/x-diff; charset=iso-8859-2
Content-Disposition: attachment; filename="gssd-4.patch"


Set default kerberos realm as preferred realm by default.

Signed-off-by: Lukas Hejtmanek <xhejtman@ics.muni.cz>

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index c7f9bdd..3c8c24b 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -148,6 +148,9 @@ main(int argc, char *argv[])
 		}
 	}
 
+	if(!preferred_realm)
+		preferred_realm = gssd_k5_get_default_realm();
+
 	i = 0;
 	ccachesearch[i++] = strtok(ccachedir, ":");
 	do {
diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index 4915293..16d155a 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -1234,3 +1234,26 @@ gssd_k5_err_msg(krb5_context context, krb5_error_code code)
 		return error_message(code);
 #endif
 }
+
+/*
+ * Routine that returns default kerberos realm
+ */
+
+const char*
+gssd_k5_get_default_realm()
+{
+	krb5_context context;
+	char         *realm;
+
+	if(krb5_init_context(&context)) {
+		return NULL;
+	}
+
+	if(krb5_get_default_realm(context, &realm)) {
+		krb5_free_context(context);
+		return NULL;
+	}
+
+	krb5_free_context(context);
+	return realm;
+}
diff --git a/utils/gssd/krb5_util.h b/utils/gssd/krb5_util.h
index addae1c..a4cccac 100644
--- a/utils/gssd/krb5_util.h
+++ b/utils/gssd/krb5_util.h
@@ -17,6 +17,7 @@ struct gssd_k5_kt_princ {
 };
 
 
+const char* gssd_k5_get_default_realm(void);
 int gssd_setup_krb5_user_gss_ccache(uid_t uid, char *servername,
 				     char *dirname);
 int  gssd_get_krb5_machine_cred_list(char ***list);

--45Z9DzgjV8m4Oswq
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
--45Z9DzgjV8m4Oswq--
