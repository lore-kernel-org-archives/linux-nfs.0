Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ns201214.ovh.net ([91.121.117.65]:57328 "EHLO ns201214.ovh.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932151Ab0EKQ6j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 May 2010 12:58:39 -0400
Message-ID: <4BE98CAA.3050702@nomado.eu>
Date: Tue, 11 May 2010 17:58:18 +0100
From: HABIB Ramzi <ramzi@nomado.eu>
Reply-To: ramzi@nomado.eu
To: Kevin Coffman <kwc@citi.umich.edu>
CC: linux-nfs@vger.kernel.org, 581199@bugs.debian.org
Subject: Re: libnfsidmap: Virtual domains/users handling with at sign in idmap
References: <4BE956AC.3070303@nomado.eu> <AANLkTinWVImhX2OpHT4Z75l_m1D1ED7YJkj4iuP3SyWn@mail.gmail.com> <4BE96A0B.8070000@nomado.eu>
In-Reply-To: <4BE96A0B.8070000@nomado.eu>
Content-Type: multipart/mixed;
 boundary="------------030101050004040200020500"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--------------030101050004040200020500
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

Hi again,

Here is a second patch that applies to 0.21 and up only ( up to testing=20
and unstable 0.23-2 for debian libnfsidmap2 packages and 0.23=20
libnfsidmap source ) where dealing with local realms and principal realm=20
was introduced first in. libnfsidmap
strstr has been switched to strrchr  ( to avoid using strrstr as it's=20
not a standard function ) .

Patch to fix principal realm in addition to previous domain patch in=20
#1st post

libnfsidmap_0.21_up_fix_at_sign_user_realm_fix.diff

///////////////////////////////////////////////////////////////////////////=
////////////////////////////////////////////

--- libnfsidmap-0.23.orig/nss.c 2009-07-29 22:19:06.000000000 +0200
+++ libnfsidmap-0.23/nss.c      2010-05-11 17:34:03.000000000 +0200
@@ -135,7 +135,7 @@
         char *l =3D NULL;
         int len;

-       c =3D strchr(name, '@');
+       c =3D strrchr(name, '@');
         if (c =3D=3D NULL && domain !=3D NULL)
                 goto out;
         if (c =3D=3D NULL && domain =3D=3D NULL) {
@@ -276,7 +276,7 @@
                 return -EINVAL;

         /* get princ's realm */
-       princ_realm =3D strstr(princ, "@");
+       princ_realm =3D strrchr(princ, '@');
         if (princ_realm =3D=3D NULL)
                 return -EINVAL;
         princ_realm++;

///////////////////////////////////////////////////////////////////////////=
////////////////////////////////////////////

Patch to fix both domain & principal realm

libnfsidmap_0.21_up_fix_at_sign_user_with_domain_plus_realm_fix.diff

///////////////////////////////////////////////////////////////////////////=
////////////////////////////////////////////

--- libnfsidmap-0.23.orig/nss.c 2009-07-29 22:19:06.000000000 +0200
+++ libnfsidmap-0.23/nss.c      2010-05-11 17:34:03.000000000 +0200
@@ -135,7 +135,7 @@
         char *l =3D NULL;
         int len;

-       c =3D strchr(name, '@');
+       c =3D strrchr(name, '@');
         if (c =3D=3D NULL && domain !=3D NULL)
                 goto out;
         if (c =3D=3D NULL && domain =3D=3D NULL) {
@@ -276,7 +276,7 @@
                 return -EINVAL;

         /* get princ's realm */
-       princ_realm =3D strstr(princ, "@");
+       princ_realm =3D strrchr(princ, '@');
         if (princ_realm =3D=3D NULL)
                 return -EINVAL;
         princ_realm++;

///////////////////////////////////////////////////////////////////////////=
////////////////////////////////////////////


Le 11/05/2010 15:30, HABIB Ramzi a =E9crit :
> You're welcome.
> The patch fixes the problem if not using kerberos.
> I checked the latest version (0.23, in testing and unstable packages.=20
> Doesn't apply for oldstable and stable ones) from citi's website and=20
> it seems there's an additional fix to make for function=20
> "nss_gss_princ_to_ids" in nss.c file on line 279 :
>
> /////////////////////////////////////////////////
>
>     /* get princ's realm */
>     princ_realm =3D strstr(princ, "@");
>     if (princ_realm =3D=3D NULL)
>         return -EINVAL;
>     princ_realm++;
>
> ////////////////////////////////////////////////
>
> I'll check that soon and get back to you with the results.
>
> Ramzi
>
> Le 11/05/2010 15:07, Kevin Coffman a =E9crit :
>> Thanks.  Unless someone else sees a problem with this, I'll apply it.
>>
>> On Tue, May 11, 2010 at 9:07 AM, HABIB Ramzi<ramzi@nomado.eu>  wrote:
>>> Subject: libnfsidmap: Virtual domains/users handling with at sign in=20
>>> idmap
>>> Package: libnfsidmap
>>> Version: 0.23
>>> Severity: normal
>>> Tags: patch
>>>
>>> *** Please type your report below this line ***
>>>
>>> Idmap fails to map uid to localname or vice versa in case an 'at' (=20
>>> @ ) sign
>>> is included in the localname.
>>> This is particularly the case of virtual domains username where
>>> a user@virtual_domain is in fact the username and its @ sign=20
>>> conflicts with
>>> username@idmap_domain format used by idmap to handle uid/localname
>>> conversions.
>>> Where username =3D user@virtual_domain.
>>> Idmap is still able to map uid/localname correctly when the username=20
>>> does
>>> not
>>> include an @ sign.
>>> Both NFS Server and Client are PAM/NSS clients of an OpenLDAP Server=20
>>> that
>>> handles users&  groups. NFSv4 is used and without kerberos and=20
>>> "nsswitch"
>>> Translation method is used rather than umich_ldap.
>>> Idmap looks for the first occurrence of and @ sign in the name string
>>> and assumes that the @ sign is the one of user@virtual_domain rather=20
>>> than
>>> using the one of username@idmap_domain=20
>>> (user@virtual_domain@idmap_domain).
>>> The function "strip_domain" is defined in nss.c file and uses "strchr"
>>> function on line 138 to find the first occurrence of an @ sign from=20
>>> the name
>>> string.
>>> As the name string includes 2 occurrences, the domain resulting from=20
>>> that
>>> (virtual_domain@idmap_domain) fails to match with the configured idmap
>>> domain
>>> (idmap_domain) and this causes idmap returning a null value.
>>> Switching from "strchr" to "strrchr" simply fix the problem as it=20
>>> would look
>>> for the last occurrence rather than the first one and therefore has a
>>> resulting
>>> domain that matched the idmap one.
>>> This obviously makes sense as a URI should be read from right to=20
>>> left and
>>> not
>>> from left to right when handling domains.
>>> The idmap domain is this way the root domain and all virtual domains
>>> included
>>> in the username it handles will not conflicts with it.
>>>
>>> A patch is included here below :
>>>
>>> libnfsidmap_0.23_fix_at_sign_user_with_domain.diff
>>>
>>> //////////////////////////////////////////////////////////////////
>>>
>>> --- libnfsidmap-0.23.orig/nss.c    2009-07-29 22:19:06.000000000 +0200
>>> +++ libnfsidmap-0.23/nss.c    2010-05-11 15:02:13.000000000 +0200
>>> @@ -135,7 +135,7 @@
>>>      char *l =3D NULL;
>>>      int len;
>>>
>>> -    c =3D strchr(name, '@');
>>> +    c =3D strrchr(name, '@');
>>>      if (c =3D=3D NULL&&  domain !=3D NULL)
>>>          goto out;
>>>      if (c =3D=3D NULL&&  domain =3D=3D NULL) {
>>>
>>> //////////////////////////////////////////////////////////////////
>>>
>>> The patch applies to all archs.
>>> Versions checked :
>>> Debian :
>>> libnfsidmap2 0.18-0 (oldstable)
>>> libnfsidmap2 0.20-1 (stable)
>>> libnfsidmap2 0.23-2 (testing,unstable)
>>>
>>> -- System Information:
>>> Debian Release: 5.0.4
>>>   APT prefers stable
>>>   APT policy: (500, 'stable')
>>> Architecture: amd64 (x86_64)
>>>
>>> Kernel: Linux 2.6.26-2-amd64 (SMP w/1 CPU core)
>>> Locale: LANG=3Dfr_FR.UTF-8, LC_CTYPE=3Dfr_FR.UTF-8 (charmap=3DUTF-8)
>>> Shell: /bin/sh linked to /bin/bash
>>>
>>> Versions of packages libnfsidmap2 depends on:
>>> ii  libc6                       2.7-18lenny2 GNU C Library: Shared=20
>>> libraries
>>> ii  libldap-2.4-2               2.4.11-1+lenny1   OpenLDAP libraries
>>>
>>> Ramzi HABIB
>>> ramzi<at>  nomado.eu
>>>
>> __________ Information provenant d'ESET Smart Security, version de la=20
>> base des signatures de virus 5105 (20100511) __________
>>
>> Le message a =E9t=E9 v=E9rifi=E9 par ESET Smart Security.
>>
>> http://www.eset.com
>>
>>
>>
>>
>


--------------030101050004040200020500
Content-Type: text/plain;
 name="libnfsidmap_0.20-1_fix_at_sign_user_with_domain.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="libnfsidmap_0.20-1_fix_at_sign_user_with_domain.diff"

--- libnfsidmap-0.20.orig/nss.c	2007-02-05 17:13:05.000000000 +0100
+++ libnfsidmap-0.20/nss.c	2010-05-11 14:35:55.000000000 +0200
@@ -135,7 +135,7 @@
 	char *l = NULL;
 	int len;
 
-	c = strchr(name, '@');
+	c = strrchr(name, '@');
 	if (c == NULL && domain != NULL)
 		goto out;
 	if (c == NULL && domain == NULL) {

--------------030101050004040200020500
Content-Type: text/plain;
 name="libnfsidmap_0.21_up_fix_at_sign_user_with_domain_plus_realm_fix.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="libnfsidmap_0.21_up_fix_at_sign_user_with_domain_plus_realm_";
 filename*1="fix.diff"

--- libnfsidmap-0.23.orig/nss.c	2009-07-29 22:19:06.000000000 +0200
+++ libnfsidmap-0.23/nss.c	2010-05-11 17:34:03.000000000 +0200
@@ -135,7 +135,7 @@
 	char *l = NULL;
 	int len;
 
-	c = strchr(name, '@');
+	c = strrchr(name, '@');
 	if (c == NULL && domain != NULL)
 		goto out;
 	if (c == NULL && domain == NULL) {
@@ -276,7 +276,7 @@
 		return -EINVAL;
 
 	/* get princ's realm */
-	princ_realm = strstr(princ, "@");
+	princ_realm = strrchr(princ, '@');
 	if (princ_realm == NULL)
 		return -EINVAL;
 	princ_realm++;

--------------030101050004040200020500
Content-Type: text/plain;
 name="libnfsidmap_0.21_up_fix_at_sign_user_realm_fix.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="libnfsidmap_0.21_up_fix_at_sign_user_realm_fix.diff"

--- libnfsidmap-0.23.orig/nss.c	2009-07-29 22:19:06.000000000 +0200
+++ libnfsidmap-0.23/nss.c	2010-05-11 17:34:03.000000000 +0200
@@ -276,7 +276,7 @@
 		return -EINVAL;
 
 	/* get princ's realm */
-	princ_realm = strstr(princ, "@");
+	princ_realm = strrchr(princ, '@');
 	if (princ_realm == NULL)
 		return -EINVAL;
 	princ_realm++;

--------------030101050004040200020500--
