Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([139.142.54.143]:37792 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751005Ab1ADVcM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jan 2011 16:32:12 -0500
Date: Tue, 4 Jan 2011 14:32:08 -0700
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Timo Aaltonen <timo.aaltonen@aalto.fi>
Cc: linux-nfs@vger.kernel.org, Steve Dickson <steved@redhat.com>
Subject: Re: [PATCH] Support AD style kerberos automatically in rpc.gss
Message-ID: <20110104213207.GA1211@obsidianresearch.com>
References: <20101222192227.GA31112@obsidianresearch.com>
 <alpine.DEB.2.00.1012231240220.20516@kosh.org.aalto.fi>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <alpine.DEB.2.00.1012231240220.20516@kosh.org.aalto.fi>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Dec 23, 2010 at 12:55:16PM +0200, Timo Aaltonen wrote:
> On Wed, 22 Dec 2010, Jason Gunthorpe wrote:
> 
> >An Active Directory KDC will only grant a TGT for UPNs, getting
> >a TGT for SPNs is not possible:
> >
> >$ kinit -k host/ib5@ADS.ORCORP.CA
> >kinit: Client not found in Kerberos database while getting initial credentials
> >
> >The correct thing to do for machine credentials is to get a TGT
> >for the computer UPN <HOSTNAME>$@REALM:
> >$ kinit -k IB5\$
> >$ klist
> >12/22/10 11:43:47  12/22/10 21:43:47  krbtgt/ADS.ORCORP.CA@ADS.ORCORP.CA
> >
> >Samba automatically creates /etc/krb5.keytab entry for the computer UPN,
> >this patch makes gssd_refresh_krb5_machine_credential prefer it above
> >the SPNs if it is present.
> >
> >The net result is that nfs client works automatically out of the box
> >if samba has been used to setup kerberos via 'net ads join' 'net ads
> >keytab create'
> >
> >Tested using Windows Server 2003 R2 as the AD server.
> 
> This is basically what I did earlier, see:
> 
> http://marc.info/?l=linux-nfs&m=128108638228797&w=2
> 
> though I still haven't cleaned it up as promised..

Right, mine is a bit more complete (man page updated, etc) but it does
the same thing.

Maybe we can get a nfs-utils maintainer to comment this time?

Jason
 
> >Signed-off-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
> >utils/gssd/gssd.man    |    5 ++++
> >utils/gssd/krb5_util.c |   62 ++++++++++++++++++++++++++++++++++--------------
> >2 files changed, 49 insertions(+), 18 deletions(-)
> >
> >I'm still looking into what to do for AD in the server case when
> >process_krb5_upcall is called with service == nfs. Some references
> >suggest setting AD's userPrincipalName to the nfs SPN, but it would be
> >really nice if that wasn't necessary.
> >
> >Shouldn't it be possible to use the a ticket provided from the client
> >to send back an unsolicted reply??
> >
> >Thanks,
> >Jason
> >
> >diff --git a/utils/gssd/gssd.man b/utils/gssd/gssd.man
> >index 0a23cd6..073379d 100644
> >+++ b/utils/gssd/gssd.man
> >@@ -53,6 +53,8 @@ To be more consistent with other implementations, we now look for
> >specific keytab entries.  The search order for keytabs to be used
> >for "machine credentials" is now:
> >.br
> >+  <HOSTNAME>$@<REALM>
> >+.br
> >  root/<hostname>@<REALM>
> >.br
> >  nfs/<hostname>@<REALM>
> >@@ -64,6 +66,9 @@ for "machine credentials" is now:
> >  nfs/<anyname>@<REALM>
> >.br
> >  host/<anyname>@<REALM>
> >+.IP
> >+If this search order does not use the correct key then provide a
> >+keytab file that contains only correct keys.
> >.TP
> >.B -p path
> >Tells
> >diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
> >index f071600..4b13fa1 100644
> >+++ b/utils/gssd/krb5_util.c
> >@@ -768,6 +768,7 @@ find_keytab_entry(krb5_context context, krb5_keytab kt, const char *hostname,
> >	krb5_error_code code;
> >	char **realmnames = NULL;
> >	char myhostname[NI_MAXHOST], targethostname[NI_MAXHOST];
> >+	char myhostad[NI_MAXHOST+1];
> >	int i, j, retval;
> >	char *default_realm = NULL;
> >	char *realm;
> >@@ -789,6 +790,14 @@ find_keytab_entry(krb5_context context, krb5_keytab kt, const char *hostname,
> >		printerr(1, "%s while getting local hostname\n", k5err);
> >		goto out;
> >	}
> >+
> >+	/* Compute the active directory machine name HOST$ */
> >+	strcpy(myhostad, myhostname);
> >+	for (i = 0; myhostad[i] != 0; ++i)
> >+		myhostad[i] = toupper(myhostad[i]);
> >+	myhostad[i] = '$';
> >+	myhostad[i+1] = 0;
> >+
> >	retval = get_full_hostname(myhostname, myhostname, sizeof(myhostname));
> >	if (retval)
> >		goto out;
> >@@ -833,32 +842,47 @@ find_keytab_entry(krb5_context context, krb5_keytab kt, const char *hostname,
> >		if (strcmp(realm, default_realm) == 0)
> >			tried_default = 1;
> >		for (j = 0; svcnames[j] != NULL; j++) {
> >-			code = krb5_build_principal_ext(context, &princ,
> >-							strlen(realm),
> >-							realm,
> >-							strlen(svcnames[j]),
> >-							svcnames[j],
> >-							strlen(myhostname),
> >-							myhostname,
> >-							NULL);
> >+			char spn[300];
> >+
> >+			/*
> >+			 * The special svcname "$" means 'try the active
> >+			 * directory machine account'
> >+			 */
> >+			if (strcmp(svcnames[j],"$") == 0) {
> >+				snprintf(spn, sizeof(spn), "%s@%s", myhostad, realm);
> >+				code = krb5_build_principal_ext(context, &princ,
> >+								strlen(realm),
> >+								realm,
> >+								strlen(myhostad),
> >+								myhostad,
> >+								NULL);
> >+			} else {
> >+				snprintf(spn, sizeof(spn), "%s/%s@%s",
> >+					 svcnames[j], myhostname, realm);
> >+				code = krb5_build_principal_ext(context, &princ,
> >+								strlen(realm),
> >+								realm,
> >+								strlen(svcnames[j]),
> >+								svcnames[j],
> >+								strlen(myhostname),
> >+								myhostname,
> >+								NULL);
> >+			}
> >+
> >			if (code) {
> >				k5err = gssd_k5_err_msg(context, code);
> >-				printerr(1, "%s while building principal for "
> >-					 "'%s/%s@%s'\n", k5err, svcnames[j],
> >-					 myhostname, realm);
> >+				printerr(1, "%s while building principal for '%s'\n",
> >+					 k5err, spn);
> >				continue;
> >			}
> >			code = krb5_kt_get_entry(context, kt, princ, 0, 0, kte);
> >			krb5_free_principal(context, princ);
> >			if (code) {
> >				k5err = gssd_k5_err_msg(context, code);
> >-				printerr(3, "%s while getting keytab entry for "
> >-					 "'%s/%s@%s'\n", k5err, svcnames[j],
> >-					 myhostname, realm);
> >+				printerr(3, "%s while getting keytab entry for '%s'\n",
> >+					 k5err, spn);
> >			} else {
> >-				printerr(3, "Success getting keytab entry for "
> >-					 "'%s/%s@%s'\n",
> >-					 svcnames[j], myhostname, realm);
> >+				printerr(3, "Success getting keytab entry for '%s'\n",spn);
> >				retval = 0;
> >				goto out;
> >			}
> >@@ -870,6 +894,8 @@ find_keytab_entry(krb5_context context, krb5_keytab kt, const char *hostname,
> >		 */
> >		for (j = 0; svcnames[j] != NULL; j++) {
> >			int found = 0;
> >+			if (strcmp(svcnames[j],"$") == 0)
> >+				continue;
> >			code = gssd_search_krb5_keytab(context, kt, realm,
> >						       svcnames[j], &found, kte);
> >			if (!code && found) {
> >@@ -1160,7 +1186,7 @@ gssd_refresh_krb5_machine_credential(char *hostname,
> >	krb5_keytab kt = NULL;;
> >	int retval = 0;
> >	char *k5err = NULL;
> >-	const char *svcnames[4] = { "root", "nfs", "host", NULL };
> >+	const char *svcnames[5] = { "$", "root", "nfs", "host", NULL };
> >
> >	/*
> >	 * If a specific service name was specified, use it.
