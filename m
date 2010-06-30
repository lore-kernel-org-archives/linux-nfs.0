From: Laurent Bonnaud <bonnaud-jHyHnS8NkcXLSxaa5bH2iPQULIy34Utc@public.gmane.org>
Subject: Mount error with NFSv4 and Kerberos (Bad encryption type)
Date: Wed, 30 Jun 2010 17:43:51 +0200
Message-ID: <1277912631.11798.22.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-DPlX50ycKONpI3Qgj8zo"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.ampere.inpg.fr ([147.171.64.83]:54453 "EHLO
	smtp.ampere.inpg.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751758Ab0F3PyQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jun 2010 11:54:16 -0400
Received: from localhost (localhost [127.0.0.1])
	by smtp.ampere.inpg.fr (Postfix) with ESMTP id 2F6EE981F4
	for <linux-nfs@vger.kernel.org>; Wed, 30 Jun 2010 17:43:52 +0200 (CEST)
Received: from smtp.ampere.inpg.fr ([127.0.0.1])
	by localhost (smtp.ampere.grenoble-inp.fr [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id jMESE5esqj30 for <linux-nfs@vger.kernel.org>;
	Wed, 30 Jun 2010 17:43:52 +0200 (CEST)
Received: from [193.55.51.151] (pc-dg-112-2.iut2.upmf-grenoble.fr [193.55.51.151])
	(using SSLv3 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp.ampere.inpg.fr (Postfix) with ESMTPSA id 1685E98102
	for <linux-nfs@vger.kernel.org>; Wed, 30 Jun 2010 17:43:52 +0200 (CEST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-DPlX50ycKONpI3Qgj8zo
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit

Hi,

I am trying to mount a NFSv4 share from a Debian squeeze NFS server on a
Debian squeeze NFS client using sec=krb5.  The same setup used to work
an Debian lenny and failed just after the upgrade to Debian squeeze.

Both systems use the latest versions in Debian squeeze, currently:
 - nfs-utils version 1.2.2 (package version 1.2.2-1)
 - kernel 2.6.32 (package version 2.6.32-15)
 - krb5 1.8.1 (package version 1.8.1+dfsg-5)

The mount operation fails with this error message:

root@svn-info:~# mount -v /users
mount.nfs4: timeout set for Wed Jun 30 17:29:47 2010
mount.nfs4: trying text-based options 'intr,sec=krb5,addr=192.168.141.5,clientaddr=195.221.57.54'
mount.nfs4: mount(2): Permission denied
mount.nfs4: access denied by server while mounting erebus2-pdg:/users

Here is the /etc/fstab entry on the client:

  erebus2-pdg:/users /users nfs4 auto,user,exec,intr,sec=krb5

On the server /var/log/daemon.log contains the following error messages:

Jun 30 17:27:47 erebus2-pdg rpc.svcgssd[24332]: ERROR: GSS-API: error in
handle_nullreq: gss_accept_sec_context(): Unspecified GSS failure.
Minor code may provide more information - Bad encryption type
Jun 30 17:27:47 erebus2-pdg rpc.svcgssd[24332]: ERROR: GSS-API: error in
handle_nullreq: gss_accept_sec_context(): Unspecified GSS failure.
Minor code may provide more information - Bad encryption type

Kerberos keys were generated on a Windows 2003 AD server and the same
keys used to work in Debian lenny:

 - on the client:

root@svn-info:~# klist -ke
Keytab name: WRFILE:/etc/krb5.keytab
KVNO Principal
---- --------------------------------------------------------------------------
   3 nfs/pc-client-nfs-mNjEMxXs7nNb7MaPNYHebcAQG6jrQJLRZR6xolQnxMI@public.gmane.org (DES cbc mode with RSA-MD5) 

 - on the server:

root@erebus2-pdg:~# klist -ke
Keytab name: WRFILE:/etc/krb5.keytab
KVNO Principal
---- --------------------------------------------------------------------------
   3 nfs/erebus2-pdg.iut2.upmf-grenoble.fr-mNjEMxXs7nNb7MaPNYHebcAQG6jrQJLRZR6xolQnxMI@public.gmane.org (DES cbc mode with RSA-MD5) 

On the server /etc/krb5.conf does contain the following line (see the
attached file):

  allow_weak_crypto = true

Google does not know about this problem:

  http://www.google.com/search?q=rpc.svcgssd+%22Bad+encryption+type%22

Could anybody please help ?

-- 
Laurent Bonnaud.


--=-DPlX50ycKONpI3Qgj8zo
Content-Disposition: attachment; filename="krb5.conf"
Content-Type: text/plain; name="krb5.conf"; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit

[libdefaults]
	default_realm = NTIUT2GRE.IUT2.UPMF-GRENOBLE.FR

# The following krb5.conf variables are only for MIT Kerberos.
	kdc_timesync = 1
	ccache_type = 4
	forwardable = true
	proxiable = true

     	allow_weak_crypto = true

[realms]
	NTIUT2GRE.IUT2.UPMF-GRENOBLE.FR = {
		kdc = xxx.iut2.upmf-grenoble.fr
		admin_server = xxx.iut2.upmf-grenoble.fr
	}

[domain_realm]
	.iut2.upmf-grenoble.fr = NTIUT2GRE.IUT2.UPMF-GRENOBLE.FR
	iut2.upmf-grenoble.fr = NTIUT2GRE.IUT2.UPMF-GRENOBLE.FR

--=-DPlX50ycKONpI3Qgj8zo--

