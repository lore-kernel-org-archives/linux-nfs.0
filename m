From: "G. Allen Morris III" <gam3-nfs@gam3.net>
Subject: Making /proc/fs/nfs/exports human friendly
Date: Fri, 18 Mar 2005 08:55:50 -0500
Message-ID: <20050318135550.GB27718@gam3.net>
References: <20050306164036.GA21468@gam3.net> <20050306173628.GA3918@gam3.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="cNdxnHkX5QqsyA0e"
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DCHxL-0008BV-W3
	for nfs@lists.sourceforge.net; Fri, 18 Mar 2005 05:56:03 -0800
Received: from mta13.mail.adelphia.net ([68.168.78.44] helo=mta13.adelphia.net)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DCHxK-0005i2-NK
	for nfs@lists.sourceforge.net; Fri, 18 Mar 2005 05:56:03 -0800
Received: from harpo.ny.gam3.net ([68.235.28.141]) by mta13.adelphia.net
          (InterMail vM.6.01.04.01 201-2131-118-101-20041129) with ESMTP
          id <20050318135551.IFMU4618.mta13.adelphia.net@harpo.ny.gam3.net>
          for <nfs@lists.sourceforge.net>; Fri, 18 Mar 2005 08:55:51 -0500
Received: from gam3 by harpo.ny.gam3.net with local (Exim 3.36 #1 (Debian))
	id 1DCHx8-0007Fy-00
	for <nfs@lists.sourceforge.net>; Fri, 18 Mar 2005 08:55:50 -0500
To: nfs@lists.sourceforge.net
In-Reply-To: <20050306173628.GA3918@gam3.net>
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


--cNdxnHkX5QqsyA0e
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Mar 06, 2005 at 12:36:28PM -0500, G. Allen Morris III wrote:
> Neil,
>=20
> Neil the net rcp export cache should not be used directly for
> the /proc/nfs/exports output.
>=20
> I am pretty sure that all that needs to be done is to only display
> the rightmost element of the domain (client =3D strrchr(domain, ',')+1).
>=20
> I have a patch, but plan to clean it up before I send it to you.
>=20
> I just wanted to request comments on this problem for now.

Here is a patch.  I don't expect this to be applied.  I only wanted
feed back for now.

The last patch is to the nfs-utils to get the client name.

Rather than passing in the client name as a string it could be passed in
as an index to the correct entry in the domain.


=3D=3D=3D=3D=3D fs/nfsd/export.c 1.95 vs edited =3D=3D=3D=3D=3D
--- 1.95/fs/nfsd/export.c       2005-03-05 01:32:50 -05:00
+++ edited/fs/nfsd/export.c     2005-03-12 08:39:54 -05:00
@@ -95,6 +95,7 @@
 }
=20
 static struct svc_expkey *svc_expkey_lookup(struct svc_expkey *, int);
+
 static int expkey_parse(struct cache_detail *cd, char *mesg, int mlen)
 {
        /* client fsidtype fsid [path] */
@@ -280,6 +281,8 @@
                dput(exp->ex_dentry);
                mntput(exp->ex_mnt);
                auth_domain_put(exp->ex_client);
+               if (exp->ex_client_name)
+                   kfree(exp->ex_client_name);
                kfree(exp);
        }
 }
@@ -342,7 +345,7 @@
=20
 static int svc_export_parse(struct cache_detail *cd, char *mesg, int mlen)
 {
-       /* client path expiry [flags anonuid anongid fsid] */
+       /* domain path expiry [flags anonuid anongid fsid client] */
        char *buf;
        int len;
        int err;
@@ -382,6 +385,7 @@
        exp.ex_client =3D dom;
        exp.ex_mnt =3D nd.mnt;
        exp.ex_dentry =3D nd.dentry;
+       exp.ex_client_name =3D NULL;
=20
        /* expiry */
        err =3D -EINVAL;
@@ -416,6 +420,10 @@
                if (err) goto out;
        }
=20
+       len =3D qword_get(&mesg, buf, PAGE_SIZE);
+       if (len) {
+               exp.ex_client_name =3D buf;
+       }
        expp =3D svc_export_lookup(&exp, 1);
        if (expp)
                exp_put(expp);
@@ -455,6 +463,7 @@
        seq_puts(m, ")\n");
        return 0;
 }
+
 struct cache_detail svc_export_cache =3D {
        .hash_size      =3D EXPORT_HASHMAX,
        .hash_table     =3D export_table,
@@ -477,6 +486,17 @@
        new->ex_client =3D item->ex_client;
        new->ex_dentry =3D dget(item->ex_dentry);
        new->ex_mnt =3D mntget(item->ex_mnt);
+       new->ex_client_name =3D NULL;
+       if (item->ex_client_name) {
+               int len;
+               char *s;
+
+               len =3D strlen(item->ex_client_name);
+               s =3D kmalloc(len+1, GFP_KERNEL);
+               if (s)
+                       strcpy(s, item->ex_client_name);
+               new->ex_client_name =3D s;
+       }
 }
=20
 static inline void svc_export_update(struct svc_export *new, struct svc_ex=
port *item)
@@ -485,6 +505,13 @@
        new->ex_anon_uid =3D item->ex_anon_uid;
        new->ex_anon_gid =3D item->ex_anon_gid;
        new->ex_fsid =3D item->ex_fsid;
+       if (new->ex_client_name && item->ex_client_name) {
+               if (strcmp(new->ex_client_name, item->ex_client_name)) {
+                       printk("svc_export_update both %s ~=3D %s\n", new->=
ex_client_name, item->ex_client_name);
+               }
+       } else if (item->ex_client_name) {
+               printk("svc_export_update new %p item %p\n", new->ex_client=
_name, item->ex_client_name);
+       }
 }
=20
 static DefineSimpleCacheLookup(svc_export,1) /* allow inplace updates */
@@ -1037,6 +1064,42 @@
                seq_printf(m, "%sanongid=3D%d", first++?",":"", anong);
 }
=20
+static int svc_export_display(struct seq_file *m,
+                          struct cache_detail *cd,
+                          struct cache_head *h)
+{
+       struct svc_export *exp ;
+
+       if (h =3D=3DNULL) {
+               seq_puts(m, "#path domain(flags)\n");
+               return 0;
+       }
+       exp =3D container_of(h, struct svc_export, h);
+       seq_path(m, exp->ex_mnt, exp->ex_dentry, " \t\n\\");
+       seq_putc(m, '\t');
+       if (exp->ex_client_name) {
+           seq_escape(m, exp->ex_client_name, " \t\n\\");
+       } else {
+           seq_escape(m, exp->ex_client->name, " \t\n\\");
+       }
+       seq_putc(m, '(');
+       if (test_bit(CACHE_VALID, &h->flags) &&=20
+           !test_bit(CACHE_NEGATIVE, &h->flags))
+               exp_flags(m, exp->ex_flags, exp->ex_fsid,=20
+                         exp->ex_anon_uid, exp->ex_anon_gid);
+       seq_puts(m, ") #");
+       {
+           struct auth_domain *dom;
+           dom =3D auth_domain_find(exp->ex_client->name);
+           if (dom) {
+               auth_unix_list(m, dom);
+               auth_domain_put(dom);
+           }
+       }
+       seq_putc(m, '\n');
+       return 0;
+}
+
 static int e_show(struct seq_file *m, void *p)
 {
        struct cache_head *cp =3D p;
@@ -1054,7 +1117,7 @@
        if (cache_check(&svc_export_cache, &exp->h, NULL))
                return 0;
        if (cache_put(&exp->h, &svc_export_cache)) BUG();
-       return svc_export_show(m, &svc_export_cache, cp);
+       return svc_export_display(m, &svc_export_cache, cp);
 }
=20
 struct seq_operations nfs_exports_op =3D {
=3D=3D=3D=3D=3D net/sunrpc/sunrpc_syms.c 1.35 vs edited =3D=3D=3D=3D=3D
--- 1.35/net/sunrpc/sunrpc_syms.c       2005-03-05 01:32:49 -05:00
+++ edited/net/sunrpc/sunrpc_syms.c     2005-03-09 19:02:17 -05:00
@@ -107,6 +107,7 @@
 EXPORT_SYMBOL(auth_unix_add_addr);
 EXPORT_SYMBOL(auth_unix_forget_old);
 EXPORT_SYMBOL(auth_unix_lookup);
+EXPORT_SYMBOL(auth_unix_list);
 EXPORT_SYMBOL(cache_check);
 EXPORT_SYMBOL(cache_flush);
 EXPORT_SYMBOL(cache_purge);
=3D=3D=3D=3D=3D net/sunrpc/svcauth_unix.c 1.37 vs edited =3D=3D=3D=3D=3D
--- 1.37/net/sunrpc/svcauth_unix.c      2005-03-05 01:32:49 -05:00
+++ edited/net/sunrpc/svcauth_unix.c    2005-03-11 02:28:57 -05:00
@@ -296,6 +296,38 @@
        return 0;
 }
=20
+int auth_unix_list(struct seq_file *m, struct auth_domain *dom)
+{
+       int n;
+       struct in_addr addr;
+
+       if (dom->flavour !=3D RPC_AUTH_UNIX)
+               return 1;
+       for (n =3D 0; n < ip_map_cache.hash_size; n++) {
+               if (ip_map_cache.hash_table[n]) {
+                       struct cache_head *h;
+                       struct ip_map *im;
+                       char *udom =3D "";
+
+                       h =3D ip_map_cache.hash_table[n];
+                       im =3D container_of(h, struct ip_map, h);
+                       if (test_bit(CACHE_VALID, &h->flags) &&
+                               !test_bit(CACHE_NEGATIVE, &h->flags))
+                               udom =3D im->m_client->h.name;
+                       if (!strcmp(udom, dom->name)) {
+                               addr =3D im->m_addr;
+                               seq_printf(m, " %d.%d.%d.%d",
+                                  htonl(addr.s_addr) >> 24 & 0xff,
+                                  htonl(addr.s_addr) >> 16 & 0xff,
+                                  htonl(addr.s_addr) >>  8 & 0xff,
+                                  htonl(addr.s_addr) >>  0 & 0xff
+                                  );
+                       }
+               }
+       }
+       return 0;
+}
+
 struct auth_domain *auth_unix_lookup(struct in_addr addr)
 {
        struct ip_map key, *ipm;
Index: support/nfs/nfsexport.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
RCS file: /cvsroot/nfs/nfs-utils/support/nfs/nfsexport.c,v
retrieving revision 1.4
diff -u -r1.4 nfsexport.c
--- support/nfs/nfsexport.c     4 Aug 2003 03:14:50 -0000       1.4
+++ support/nfs/nfsexport.c     18 Mar 2005 13:44:05 -0000
@@ -48,6 +48,7 @@
                qword_printint(f, exp->ex_anon_uid);
                qword_printint(f, exp->ex_anon_gid);
                qword_printint(f, exp->ex_dev);
+               qword_print(f, exp->ex_client);
        } else
                qword_printint(f, 1);
=20

--cNdxnHkX5QqsyA0e
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFCOt3mliSr/X1H0FwRAuZiAKCCkYeTsoAAeukfNRlRXwWv1PoX5ACg4SXg
KJLUCWyM3Yap+sm5sry2MwM=
=Txad
-----END PGP SIGNATURE-----

--cNdxnHkX5QqsyA0e--


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
