From: Paul Jakma <paul@clubi.ie>
Subject: Re: NFSv3+Krb5 and mountd
Date: Mon, 30 Aug 2004 02:41:28 +0100 (IST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.61.0408300238530.2441@fogarty.jakma.org>
References: <20040824184138.GB3251@nasse>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C1bBA-000631-RQ
	for nfs@lists.sourceforge.net; Sun, 29 Aug 2004 18:41:52 -0700
Received: from hibernia.jakma.org ([212.17.55.49])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1C1bB9-0006jg-Ph
	for nfs@lists.sourceforge.net; Sun, 29 Aug 2004 18:41:52 -0700
To: Per Olofsson <pelle@dsv.su.se>
In-Reply-To: <20040824184138.GB3251@nasse>
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

On Tue, 24 Aug 2004, Per Olofsson wrote:

> And it works! I can tell that it uses Kerberos because I can write 
> to the mounted fs if I have a ticket, but not without. The drawback 
> is that I am now allowing AUTH_SYS mounting as well, which I want 
> to avoid. Is this a bug in mountd? Is it difficult to fix?

It's a bug in mountd yes. J Bruce Fields had actually sent me a wee 
patch to try fix it for me to test a good while ago, but I havnt 
gotten back to looking at NFSv3+GSS since then:

>From bfields@fieldses.org Wed Jun  2 22:29:52 2004
Date: Wed, 2 Jun 2004 17:29:21 -0400
From: J. Bruce Fields <bfields@fieldses.org>
To: Paul Jakma <paul@clubi.ie>
Subject: Re: [NFS] gss/krb doesnt work with nfsv3?

[snippage]

mountd currently always returns AUTH_NULL and AUTH_SYS as the allowable flavors
in mount replies.  We want it to also return gss flavors when appropriate.
For now as a hack we just have it always return AUTH_KRB5 as well.


  utils/mountd/mountd.c |    6 ++++--
  1 files changed, 4 insertions(+), 2 deletions(-)

diff -puN utils/mountd/mountd.c~mountd_flavors utils/mountd/mountd.c
--- nfs-utils-1.0.6/utils/mountd/mountd.c~mountd_flavors	2004-05-25 14:39:22.000000000 -0400
+++ nfs-utils-1.0.6-bfields/utils/mountd/mountd.c	2004-06-01 15:03:22.000000000 -0400
@@ -228,7 +228,8 @@ mount_pathconf_2_svc(struct svc_req *rqs
  bool_t
  mount_mnt_3_svc(struct svc_req *rqstp, dirpath *path, mountres3 *res)
  {
-	static int	flavors[] = { AUTH_NULL, AUTH_UNIX };
+#define AUTH_GSS_KRB5 390003
+	static int	flavors[] = { AUTH_NULL, AUTH_UNIX, AUTH_GSS_KRB5};
  	struct nfs_fh_len *fh;

  	xlog(D_CALL, "MNT3(%s) called", *path);
@@ -237,7 +238,8 @@ mount_mnt_3_svc(struct svc_req *rqstp, d

  		ok->fhandle.fhandle3_len = fh->fh_size;
  		ok->fhandle.fhandle3_val = fh->fh_handle;
-		ok->auth_flavors.auth_flavors_len = 2;
+		ok->auth_flavors.auth_flavors_len
+				= sizeof(flavors)/sizeof(flavors[0]);
  		ok->auth_flavors.auth_flavors_val = flavors;
  	}
  	return 1;

_

regards,
-- 
Paul Jakma	paul@clubi.ie	paul@jakma.org	Key ID: 64A2FF6A
Fortune:
Exceptions prove the rule, and wreck the budget.
 		-- Miller


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
