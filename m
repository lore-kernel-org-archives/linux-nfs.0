From: Kevin Coffman <kwc@citi.umich.edu>
Subject: Re: libnfsidmap: Virtual domains/users handling with at sign in idmap
Date: Tue, 11 May 2010 10:07:27 -0400
Message-ID: <AANLkTinWVImhX2OpHT4Z75l_m1D1ED7YJkj4iuP3SyWn@mail.gmail.com>
References: <4BE956AC.3070303@nomado.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: ramzi-nj/97Yry1BOHXe+LvDLADg@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:48007 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757191Ab0EKOH2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 May 2010 10:07:28 -0400
Received: by gyg13 with SMTP id 13so2698851gyg.19
        for <linux-nfs@vger.kernel.org>; Tue, 11 May 2010 07:07:28 -0700 (PDT)
In-Reply-To: <4BE956AC.3070303-nj/97Yry1BOHXe+LvDLADg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks.  Unless someone else sees a problem with this, I'll apply it.

On Tue, May 11, 2010 at 9:07 AM, HABIB Ramzi <ramzi-nj/97Yry1BOHXe+LvDLADg@public.gmane.org> wrote:
> Subject: libnfsidmap: Virtual domains/users handling with at sign in =
idmap
> Package: libnfsidmap
> Version: 0.23
> Severity: normal
> Tags: patch
>
> *** Please type your report below this line ***
>
> Idmap fails to map uid to localname or vice versa in case an 'at' ( @=
 ) sign
> is included in the localname.
> This is particularly the case of virtual domains username where
> a user@virtual_domain is in fact the username and its @ sign conflict=
s with
> username@idmap_domain format used by idmap to handle uid/localname
> conversions.
> Where username =3D user@virtual_domain.
> Idmap is still able to map uid/localname correctly when the username =
does
> not
> include an @ sign.
> Both NFS Server and Client are PAM/NSS clients of an OpenLDAP Server =
that
> handles users & groups. NFSv4 is used and without kerberos and "nsswi=
tch"
> Translation method is used rather than umich_ldap.
> Idmap looks for the first occurrence of and @ sign in the name string
> and assumes that the @ sign is the one of user@virtual_domain rather =
than
> using the one of username@idmap_domain (user@virtual_domain@idmap_dom=
ain).
> The function "strip_domain" is defined in nss.c file and uses "strchr=
"
> function on line 138 to find the first occurrence of an @ sign from t=
he name
> string.
> As the name string includes 2 occurrences, the domain resulting from =
that
> (virtual_domain@idmap_domain) fails to match with the configured idma=
p
> domain
> (idmap_domain) and this causes idmap returning a null value.
> Switching from "strchr" to "strrchr" simply fix the problem as it wou=
ld look
> for the last occurrence rather than the first one and therefore has a
> resulting
> domain that matched the idmap one.
> This obviously makes sense as a URI should be read from right to left=
 and
> not
> from left to right when handling domains.
> The idmap domain is this way the root domain and all virtual domains
> included
> in the username it handles will not conflicts with it.
>
> A patch is included here below :
>
> libnfsidmap_0.23_fix_at_sign_user_with_domain.diff
>
> //////////////////////////////////////////////////////////////////
>
> --- libnfsidmap-0.23.orig/nss.c =A0 =A02009-07-29 22:19:06.000000000 =
+0200
> +++ libnfsidmap-0.23/nss.c =A0 =A02010-05-11 15:02:13.000000000 +0200
> @@ -135,7 +135,7 @@
> =A0 =A0 char *l =3D NULL;
> =A0 =A0 int len;
>
> - =A0 =A0c =3D strchr(name, '@');
> + =A0 =A0c =3D strrchr(name, '@');
> =A0 =A0 if (c =3D=3D NULL && domain !=3D NULL)
> =A0 =A0 =A0 =A0 goto out;
> =A0 =A0 if (c =3D=3D NULL && domain =3D=3D NULL) {
>
> //////////////////////////////////////////////////////////////////
>
> The patch applies to all archs.
> Versions checked :
> Debian :
> libnfsidmap2 0.18-0 (oldstable)
> libnfsidmap2 0.20-1 (stable)
> libnfsidmap2 0.23-2 (testing,unstable)
>
> -- System Information:
> Debian Release: 5.0.4
> =A0APT prefers stable
> =A0APT policy: (500, 'stable')
> Architecture: amd64 (x86_64)
>
> Kernel: Linux 2.6.26-2-amd64 (SMP w/1 CPU core)
> Locale: LANG=3Dfr_FR.UTF-8, LC_CTYPE=3Dfr_FR.UTF-8 (charmap=3DUTF-8)
> Shell: /bin/sh linked to /bin/bash
>
> Versions of packages libnfsidmap2 depends on:
> ii =A0libc6 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 2.7-18lenny2 =
GNU C Library: Shared libraries
> ii =A0libldap-2.4-2 =A0 =A0 =A0 =A0 =A0 =A0 =A0 2.4.11-1+lenny1 =A0 O=
penLDAP libraries
>
> Ramzi HABIB
> ramzi <at> nomado.eu
>
