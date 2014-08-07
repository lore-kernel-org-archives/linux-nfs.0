Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:39996 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757335AbaHGLrU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Aug 2014 07:47:20 -0400
Message-ID: <53E36741.2010907@RedHat.com>
Date: Thu, 07 Aug 2014 07:47:13 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jurjen Bokma <j.bokma@rug.nl>, linux-nfs@vger.kernel.org
Subject: Re: Patch: select non-conventional principal in gssd
References: <53E242E9.1050106@rug.nl>
In-Reply-To: <53E242E9.1050106@rug.nl>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/06/2014 10:59 AM, Jurjen Bokma wrote:
> HiAll,
> 
> I have a patch to utils/gssd/krb5_util.c that enables kerberized NFS
> mounts to succeed even if the principal is not <HOSTNAME>$.
> 
> It works by reading another principal name from the [appdefaults]
> section of krb5.conf:
> 
> [appdefaults]
> nfs = {
>     ad_principal_name = 129.125.39.115$
> }
> 
> Patch is attached. Would you please incorporate it in the source if you
> find it useful?
> Sorry if I'm asking in the wrong place.
A couple things.... 

One please inline your patche in your email, not attach them
as suggested in https://www.kernel.org/doc/Documentation/SubmittingPatches
Inlining makes it easier to review... 


--- utils/gssd/krb5_util.c.orig	2014-08-06 10:54:18.806414170 +0200
+++ utils/gssd/krb5_util.c	2014-08-06 11:01:21.016320365 +0200
@@ -801,7 +801,8 @@
 	char *k5err = NULL;
 	int tried_all = 0, tried_default = 0;
 	krb5_principal princ;
-
+	const char *notsetstr = "not set";
+	char *adhostoverride;
 
 	/* Get full target hostname */
 	retval = get_full_hostname(tgtname, targethostname,
@@ -818,11 +819,18 @@
 	}
 
 	/* Compute the active directory machine name HOST$ */
-	strcpy(myhostad, myhostname);
-	for (i = 0; myhostad[i] != 0; ++i)
-		myhostad[i] = toupper(myhostad[i]);
-	myhostad[i] = '$';
-	myhostad[i+1] = 0;
+	krb5_appdefault_string(context, "nfs", NULL, "ad_principal_name", notsetstr, &adhostoverride);
Secondly, where does them memory for adhostoverride get freed??

steved.

+	if (strcmp(adhostoverride, notsetstr) != 0) {
+	        printerr (0, "AD host string overridden with \"%s\" from appdefaults\n", adhostoverride);
+	        /* No overflow: Windows cannot handle strings longer than 19 chars */
+	        strcpy(myhostad, adhostoverride);
+	} else {
+	        strcpy(myhostad, myhostname);
+	        for (i = 0; myhostad[i] != 0; ++i)
+	          myhostad[i] = toupper(myhostad[i]);
+	        myhostad[i] = '$';
+	        myhostad[i+1] = 0;
+	}
 
 	retval = get_full_hostname(myhostname, myhostname, sizeof(myhostname));
 	if (retval)
