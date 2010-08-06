Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56480 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751713Ab0HFRTz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Aug 2010 13:19:55 -0400
Date: Fri, 6 Aug 2010 13:18:25 -0400
To: Timo Aaltonen <timo.aaltonen@aalto.fi>
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
Subject: Re: [PATCH nfs-utils] gssd: Check for AD style machine principal
 name
Message-ID: <20100806171825.GA28318@fieldses.org>
References: <1277729907-14299-1-git-send-email-timo.aaltonen@aalto.fi>
 <alpine.DEB.2.00.1008061157330.15926@kosh.hut.fi>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <alpine.DEB.2.00.1008061157330.15926@kosh.hut.fi>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Aug 06, 2010 at 11:59:10AM +0300, Timo Aaltonen wrote:
> On Mon, 28 Jun 2010, Timo Aaltonen wrote:
> 
> >On a MS Active Directory client the service principals cannot be used
> >for authentication. Add a check for the default machine principal name
> >so that krb5 auth works out of the box.
> >
> >Signed-off-by: Timo Aaltonen <timo.aaltonen@aalto.fi>
> >---
> >
> >Resending, the previous try didn't get any comments.
> 
> Ping? Should it add a new option to try the default AD principal to
> get accepted?

find_keytab_entry() is already quite long, has multiple nested loops,
and I find the control flow hard to follow.  This piles a little more
on.

Could you look into moving some of that code into logically-named helper
functions and clarifying the control flow?  Ideally  you could do that
in a preliminary patch that cleaned up the existing code, followed by an
update of this patch.  That might be easier to review.

--b.

> 
> >utils/gssd/krb5_util.c |   58 ++++++++++++++++++++++++++++++++++++++++++++++++
> >1 files changed, 58 insertions(+), 0 deletions(-)
> >
> >diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
> >index dccbeb6..686ef3b 100644
> >--- a/utils/gssd/krb5_util.c
> >+++ b/utils/gssd/krb5_util.c
> >@@ -737,6 +737,29 @@ gssd_search_krb5_keytab(krb5_context context, krb5_keytab kt,
> >}
> >
> >/*
> >+ * Convert the hostname to machine principal name as created
> >+ * by MS Active Directory.
> >+*/
> >+
> >+static char *
> >+hostname_to_adprinc(char *name)
> >+{
> >+	int i = 0;
> >+	int len = strlen(name);
> >+	char *buf;
> >+	if ((buf = malloc(len+2))) {
> >+		while(i < len) {
> >+			buf[i] = toupper(name[i]);
> >+			i++;
> >+		}
> >+		buf[i++] = '$';
> >+		buf[i] = 0;
> >+		return buf;
> >+	}
> >+	return NULL;
> >+}
> >+
> >+/*
> > * Find a keytab entry to use for a given target hostname.
> > * Tries to find the most appropriate keytab to use given the
> > * name of the host we are trying to connect with.
> >@@ -754,6 +777,7 @@ find_keytab_entry(krb5_context context, krb5_keytab kt, const char *hostname,
> >	char *k5err = NULL;
> >	int tried_all = 0, tried_default = 0;
> >	krb5_principal princ;
> >+	char *adprinc = NULL;
> >
> >
> >	/* Get full target hostname */
> >@@ -769,6 +793,9 @@ find_keytab_entry(krb5_context context, krb5_keytab kt, const char *hostname,
> >		printerr(1, "%s while getting local hostname\n", k5err);
> >		goto out;
> >	}
> >+	/* Convert to Active Directory machine principal name */
> >+	adprinc = hostname_to_adprinc(myhostname);
> >+
> >	retval = get_full_hostname(myhostname, myhostname, sizeof(myhostname));
> >	if (retval)
> >		goto out;
> >@@ -812,6 +839,36 @@ find_keytab_entry(krb5_context context, krb5_keytab kt, const char *hostname,
> >			break;
> >		if (strcmp(realm, default_realm) == 0)
> >			tried_default = 1;
> >+		/* First try the Active Directory style machine principal */
> >+		if (adprinc != NULL) {
> >+			code = krb5_build_principal_ext(context, &princ,
> >+							strlen(realm),
> >+							realm,
> >+							strlen(adprinc),
> >+							adprinc,
> >+							NULL);
> >+			if (code) {
> >+				k5err = gssd_k5_err_msg(context, code);
> >+				printerr(1, "%s while building principal for "
> >+					 "'%s@%s'\n", k5err,
> >+					 adprinc, realm);
> >+			}
> >+			code = krb5_kt_get_entry(context, kt, princ, 0, 0, kte);
> >+			krb5_free_principal(context, princ);
> >+			if (code) {
> >+				k5err = gssd_k5_err_msg(context, code);
> >+				printerr(3, "%s while getting keytab entry for "
> >+					 "'%s@%s'\n", k5err,
> >+					 adprinc, realm);
> >+			} else {
> >+				printerr(3, "Success getting keytab entry for "
> >+					 "'%s@%s'\n",
> >+					 adprinc, realm);
> >+				retval = 0;
> >+				goto out;
> >+			}
> >+			retval =code;
> >+		}
> >		for (j = 0; svcnames[j] != NULL; j++) {
> >			code = krb5_build_principal_ext(context, &princ,
> >							strlen(realm),
> >@@ -870,6 +927,7 @@ out:
> >	if (realmnames)
> >		krb5_free_host_realm(context, realmnames);
> >	free(k5err);
> >+	free(adprinc);
> >	return retval;
> >}
> >
> >-- 
> >1.7.0.4
> >
> >
> 
> -- 
> Timo Aaltonen
> Systems Specialist, Aalto IT
> tel. +358-9-47024317, mobile: +358-50-5918781
> http://users.tkk.fi/~tjaalton
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
