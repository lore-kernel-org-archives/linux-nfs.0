Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:54724 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755503Ab0LBCeD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Dec 2010 21:34:03 -0500
Subject: Re: NFSv4: rpc.svcgssd claims that no machine credentials exist
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Holger Rauch <rauch.holger@googlemail.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20101202020509.GA6526@gmail.com>
References: <20101202020509.GA6526@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 01 Dec 2010 21:34:01 -0500
Message-ID: <1291257241.6609.104.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-12-02 at 03:05 +0100, Holger Rauch wrote:
> Hi,
> 
> I'm trying to get kerberized NFSv4 (kernel based) on a Debian Lenny (with
> backports) system to work. Both the POSIX account and the Kerberos info is
> stored in an LDAP DIT. When I run:
> 
> /usr/sbin/rpc.svcgssd -f -vvv
> 
> I get these error messages:
> 
> ERROR: GSS-API: error in gss_acquire_cred(): Unspecified GSS failure.  Minor
> code may provide more information - No principal in keytab matches desired
> name
> Unable to obtain credentials for 'nfs'
> unable to obtain root (machine) credentials
> do you have a keytab entry for nfs/<your.host>@<YOUR.REALM> in
> /etc/krb5.keytab?
> 
> I can successfully obtain *user* principals using kinit.
> 
> The kernel version is 2.6.26-1-amd64
> 
> The version of the Debian NFS packages installed is:
> 
> ii  libnfsidmap2                                      0.20-1
> An nfs idmapping library
> ii  nfs-common                                        1:1.2.2-1~bpo50+1
> NFS support files common to client and serve
> ii  nfs-kernel-server                                 1:1.2.2-1~bpo50+1
> support for NFS kernel server
> 
> The version of the Debian MIT Kerberos packages is:
> 
> ii  krb5-admin-server
> 1.6.dfsg.4~beta1-5lenny4        MIT Kerberos master server (kadmind)
> ii  krb5-clients
> 1.6.dfsg.4~beta1-5lenny4        Secure replacements for ftp, telnet and rsh
> ii  krb5-config                                       1.22
> Configuration files for Kerberos Version 5
> ii  krb5-kdc
> 1.6.dfsg.4~beta1-5lenny4        MIT Kerberos key server (KDC)
> ii  krb5-kdc-ldap
> 1.6.dfsg.4~beta1-5lenny4        MIT Kerberos key server (KDC) LDAP plugin
> ii  krb5-user
> 1.6.dfsg.4~beta1-5lenny4        Basic programs to authenticate using MIT Ker
> ii  libkrb5-dev
> 1.6.dfsg.4~beta1-5lenny4        Headers and development libraries for MIT Ke
> ii  libkrb53
> 1.6.dfsg.4~beta1-5lenny4        MIT Kerberos runtime libraries
> ii  libpam-krb5                                       3.11-4
> PAM module for MIT Kerberos
> 
> When I look at the machine's keytab using
> 
> klist -ek /etc/krb5.keytab
> 
> I get these results:
> 
> Keytab name: FILE:/etc/krb5.keytab
> KVNO Principal
> ---- --------------------------------------------------------------------------
>    3 host/myhost.mydomain@MYREALM (Triple DES cbc mode with HMAC/sha1)
>    3 host/myhost.mydomain@MYREALM (DES cbc mode with CRC-32)
>    3 nfs/myhost.mydomain@MYREALM (DES cbc mode with CRC-32)
>    3 root/myhost.mydomain@MYREALM (Triple DES cbc mode with HMAC/sha1)
>    3 root/myhost.mydomain@MYREALM (DES cbc mode with CRC-32)
> 
> My question is thus:
> 
> - How can I find out *exactly* which principal rpc.svcgssd is looking for
> - (this would be *extremely* useful to me in order to rule out potential DNS
> - problems since I use my DNS for looking up both the realm name and the kdc
> - host name)?

Bryan and I hit this problem recently. The issue appears to be that the
MIT kerberos libraries are _very_ sensitive to the contents
of /etc/hosts. In particular, I found that a line of the form

::1	my.host.name

would completely screw up MIT kerberos's (and hence rpc.svcgssd's)
ability to figure out the correct fdqn for my server.

Unfortunately, NetworkManager loves to add 'my.host.name' to any
existing '::1' line. The only solution I've found so far is to disable
NetworkManager on my server.



The other interesting rpcsec bug I found recently had to do with
selinux: apparently MIT kerberos also likes to create a
file /var/tmp/nfs_0 when you ask it for a machine credential. If selinux
is enabled, then the security label that is set on /var/tmp/nfs_0 may
depend on how rpc.svcgssd has been run. On Fedora machines (for
instance) starting rpc.svcgssd using 'service rpcsvcgssd start' will
produce a security label of 'unconfined_u:object_r:gssd_tmp_t:s0',
whereas '/etc/init.d/rpcsvcgssd start' may produce a completely
different security label. If /var/tmp/nfs_0 is labelled incorrectly,
then rpc.svcgssd may be unable to delete the old file and replace it
with a new one...

Cheers,
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

