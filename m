Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp24.rug.nl ([129.125.60.105]:57911 "EHLO smtp24.rug.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754597AbaHGNBc convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Aug 2014 09:01:32 -0400
Received: from mail-wg0-f42.google.com ([172.23.16.207])
	by smtp24.rug.nl (8.14.7/8.14.7) with ESMTP id s77D1VNc017505
	for <linux-nfs@vger.kernel.org>; Thu, 7 Aug 2014 15:01:31 +0200
Received: by mail-wg0-f42.google.com with SMTP id l18so4108681wgh.1
        for <linux-nfs@vger.kernel.org>; Thu, 07 Aug 2014 06:01:31 -0700 (PDT)
Message-ID: <53E378A6.8040401@rug.nl>
Date: Thu, 07 Aug 2014 15:01:26 +0200
From: Jurjen Bokma <j.bokma@rug.nl>
MIME-Version: 1.0
To: SteveD@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: Patch: select non-conventional principal in gssd
References: <53E242E9.1050106@rug.nl> <53E36741.2010907@RedHat.com>
In-Reply-To: <53E36741.2010907@RedHat.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/07/2014 01:47 PM, Steve Dickson wrote:
>
> On 08/06/2014 10:59 AM, Jurjen Bokma wrote:
>> HiAll,
>>
>> I have a patch to utils/gssd/krb5_util.c that enables kerberized NFS
>> mounts to succeed even if the principal is not <HOSTNAME>$.
>>
>> It works by reading another principal name from the [appdefaults]
>> section of krb5.conf:
>>
>> [appdefaults]
>> nfs = {
>>     ad_principal_name = 129.125.39.115$
>> }
>>
>> Patch is attached. Would you please incorporate it in the source if you
>> find it useful?
>> Sorry if I'm asking in the wrong place.
> A couple things.... 
>
> One please inline your patche in your email, not attach them
> as suggested in https://www.kernel.org/doc/Documentation/SubmittingPatches
> Inlining makes it easier to review... 
I'm sorry. Also for not using the proper command, not choosing the
proper subsystem, and a couple more mistakes.
> <snip 1st version of patch>
> +	krb5_appdefault_string(context, "nfs", NULL, "ad_principal_name", notsetstr, &adhostoverride);
> Secondly, where does them memory for adhostoverride get freed??
Thank you for reviewing. <shame>Leaking memory in just a dozen
LOC.</shame> Wrong assumption on my part.
With the free(adhostoverride) added, the patch becomes:

--- utils/gssd/krb5_util.c.orig 2014-08-06 10:54:18.806414170 +0200
+++ utils/gssd/krb5_util.c      2014-08-07 14:21:51.795949903 +0200
@@ -801,7 +801,8 @@ find_keytab_entry(krb5_context context,
        char *k5err = NULL;
        int tried_all = 0, tried_default = 0;
        krb5_principal princ;
-
+       const char *notsetstr = "not set";
+       char *adhostoverride;
 
        /* Get full target hostname */
        retval = get_full_hostname(tgtname, targethostname,
@@ -818,11 +819,19 @@ find_keytab_entry(krb5_context context,
        }
 
        /* Compute the active directory machine name HOST$ */
-       strcpy(myhostad, myhostname);
-       for (i = 0; myhostad[i] != 0; ++i)
-               myhostad[i] = toupper(myhostad[i]);
-       myhostad[i] = '$';
-       myhostad[i+1] = 0;
+       krb5_appdefault_string(context, "nfs", NULL,
"ad_principal_name", notsetstr, &adhostoverride);
+       if (strcmp(adhostoverride, notsetstr) != 0) {
+               printerr (0, "AD host string overridden with \"%s\" from
appdefaults\n", adhostoverride);
+               /* No overflow: Windows cannot handle strings longer
than 19 chars */
+               strcpy(myhostad, adhostoverride);
+               free(adhostoverride);
+       } else {
+               strcpy(myhostad, myhostname);
+               for (i = 0; myhostad[i] != 0; ++i)
+                 myhostad[i] = toupper(myhostad[i]);
+               myhostad[i] = '$';
+               myhostad[i+1] = 0;
+       }
 
        retval = get_full_hostname(myhostname, myhostname,
sizeof(myhostname));
        if (retval)

And another one for the man page, if you like:

--- a/utils/gssd/gssd.man
+++ b/utils/gssd/gssd.man
@@ -140,7 +140,23 @@
 that enables Kerberized NFS when the local system is joined
 to an Active Directory domain using Samba.
 A password for this principal must be provided in the local system's
keytab.
-.P
+If the host is joined to an AD domain, but not with a principal
<HOSTNAME>$,
+then another principal name can be configured in
+.B /etc/krb5.conf
+in a
+.B appdefaults
+stanza:
+.sp
+  [appdefaults]
+.br
+  nfs = {
+.br
+    # This name should reflect a principal that has a key in the keytab
+.br
+    ad_principal_name = 192.168.3.19$
+.br
+  }
+.sp
 You can specify another keytab by using the
 .B -k
 option if


Thanks!
Jurjen


