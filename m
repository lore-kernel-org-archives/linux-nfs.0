Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:32832 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756369Ab0LBCFN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Dec 2010 21:05:13 -0500
Received: by bwz15 with SMTP id 15so6784274bwz.19
        for <linux-nfs@vger.kernel.org>; Wed, 01 Dec 2010 18:05:12 -0800 (PST)
Date: Thu, 2 Dec 2010 03:05:09 +0100
To: linux-nfs@vger.kernel.org
Subject: NFSv4: rpc.svcgssd claims that no machine credentials exist
Message-ID: <20101202020509.GA6526@gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="YZ5djTAD1cGYuMQK"
From: Holger Rauch <rauch.holger@googlemail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--YZ5djTAD1cGYuMQK
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

Hi,

I'm trying to get kerberized NFSv4 (kernel based) on a Debian Lenny (with
backports) system to work. Both the POSIX account and the Kerberos info is
stored in an LDAP DIT. When I run:

/usr/sbin/rpc.svcgssd -f -vvv

I get these error messages:

ERROR: GSS-API: error in gss_acquire_cred(): Unspecified GSS failure.  Minor
code may provide more information - No principal in keytab matches desired
name
Unable to obtain credentials for 'nfs'
unable to obtain root (machine) credentials
do you have a keytab entry for nfs/<your.host>@<YOUR.REALM> in
/etc/krb5.keytab?

I can successfully obtain *user* principals using kinit.

The kernel version is 2.6.26-1-amd64

The version of the Debian NFS packages installed is:

ii  libnfsidmap2                                      0.20-1
An nfs idmapping library
ii  nfs-common                                        1:1.2.2-1~bpo50+1
NFS support files common to client and serve
ii  nfs-kernel-server                                 1:1.2.2-1~bpo50+1
support for NFS kernel server

The version of the Debian MIT Kerberos packages is:

ii  krb5-admin-server
1.6.dfsg.4~beta1-5lenny4        MIT Kerberos master server (kadmind)
ii  krb5-clients
1.6.dfsg.4~beta1-5lenny4        Secure replacements for ftp, telnet and rsh
ii  krb5-config                                       1.22
Configuration files for Kerberos Version 5
ii  krb5-kdc
1.6.dfsg.4~beta1-5lenny4        MIT Kerberos key server (KDC)
ii  krb5-kdc-ldap
1.6.dfsg.4~beta1-5lenny4        MIT Kerberos key server (KDC) LDAP plugin
ii  krb5-user
1.6.dfsg.4~beta1-5lenny4        Basic programs to authenticate using MIT Ker
ii  libkrb5-dev
1.6.dfsg.4~beta1-5lenny4        Headers and development libraries for MIT Ke
ii  libkrb53
1.6.dfsg.4~beta1-5lenny4        MIT Kerberos runtime libraries
ii  libpam-krb5                                       3.11-4
PAM module for MIT Kerberos

When I look at the machine's keytab using

klist -ek /etc/krb5.keytab

I get these results:

Keytab name: FILE:/etc/krb5.keytab
KVNO Principal
---- --------------------------------------------------------------------------
   3 host/myhost.mydomain@MYREALM (Triple DES cbc mode with HMAC/sha1)
   3 host/myhost.mydomain@MYREALM (DES cbc mode with CRC-32)
   3 nfs/myhost.mydomain@MYREALM (DES cbc mode with CRC-32)
   3 root/myhost.mydomain@MYREALM (Triple DES cbc mode with HMAC/sha1)
   3 root/myhost.mydomain@MYREALM (DES cbc mode with CRC-32)

My question is thus:

- How can I find out *exactly* which principal rpc.svcgssd is looking for
- (this would be *extremely* useful to me in order to rule out potential DNS
- problems since I use my DNS for looking up both the realm name and the kdc
- host name)?

My /etc/krb5.conf contains:

[kdcdefaults]
    kdc_ports = 750,88

[libdefaults]
    dns_lookup_realm = true
    dns_lookup_kdc = true
    passwd_check_s_address = false
    use_tcp_only = true
    ccache_type = 3
    forwardable = true

[appdefaults]
    pam = {
        debug = true
        ticket_lifetime = 57600
        renew_lifetime = 57600
        forwardable = true
        krb4_convert = false
    }
    kinit = {
        ticket_lifetime = 57600
        renew_lifetime = 57600
        forwardable = true
    }
        pam-afs-session = {
        aklog_homedir = true
                minimum_uid = 10000
        }

[realms]
    MYREALM = {
        database_name = ldap:ou=krb5,ou=myou,dc=mydc2,dc=mydc1
        admin_server = myhost.mydomain
        acl_file = /etc/krb5kdc/kadm5.acl
        database_module = openldap_ldapconf
        default_domain = er.empic.de
        max_life = 16h 0m 0s
            max_renewable_life = 7d 0h 0m 0s
            default_principal_flags = +preauth
    }


[domain_realm]
    .mydomain = MYREALM
    mydomain = MYREALM

[login]
    krb4_convert = true
    krb4_get_tickets = false

[kdc]
    database = {
        dbname = ldap:ou=krb5,ou=myou,dc=mydc2,dc=mydc1
    }

[dbdefaults]
    ldap_kerberos_container_dn = dc=mydc2,dc=mydc1
    database_module = openldap_ldapconf

[dbmodules]
    openldap_ldapconf = {
        db_library = kldap
        ldap_kerberos_container_dn = ou=krb5,ou=myou,dc=mydc2,dc=mydc1
        ldap_kdc_dn = "cn=admin,dc=mydc2,dc=mydc1"
        # this object needs to have read rights on
        # the realm container, principal container and realm sub-trees
        ldap_kadmind_dn = "cn=admin,dc=mydc2,dc=mydc1"
        # this object needs to have read and write rights on
        # the realm container, principal container and realm sub-trees
        ldap_service_password_file = /etc/krb5kdc/service.keyfile
        ldap_servers = ldap://samson.srv.er.empic.de
        ldap_conns_per_server = 5
    }

[logging]
    kdc = FILE:/var/log/kerberos/krb5kdc.log
    admin_server = FILE:/var/log/kerberos/kadmin.log
    default = FILE:/var/log/kerberos/krb5lib.log

My DNS config in the zone file looks like this:

_ntp._udp.mydomain.                  SRV     0 0 123 ns.mydomain.
_kerberos.mydomain.                  TXT     "MYREALM"
_kerberos._udp.mydomain.             SRV     0 0 88 myhost.mydomain.
_kerberos-master._udp.mydomain.      SRV     0 0 88 myhost.mydomain.
_kerberos-adm._tcp.mydomain.         SRV     0 0 749 myhost.mydomain.
_kpasswd._udp.mydomain.              SRV     0 0 464 myhost.mydomain.
_ldap._tcp.mydomain.                 SRV     0 0 389 myhost.mydomain.
_ldaps._tcp.er.mydomain.                SRV     0 0 636 myhost.mydomain.

Any idea what exactly is going on and which steps I can take to narrow down
the problem further?

Thanks in advance & kind regards,

   Holger

--YZ5djTAD1cGYuMQK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkz2/tUACgkQbiVtWpZdKQLFFQCdGQYBuO7ha9OmW6Vn4SgbWKOC
zW4AnAtecUjoRRRc5v9/E0ebxE0FNPGy
=eVv6
-----END PGP SIGNATURE-----

--YZ5djTAD1cGYuMQK--
