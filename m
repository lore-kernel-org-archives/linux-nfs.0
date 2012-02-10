Return-Path: linux-nfs-owner@vger.kernel.org
Received: from partagas.dragonet.es ([217.70.240.130]:54065 "EHLO
	partagas.dragonet.es" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753981Ab2BJRRo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Feb 2012 12:17:44 -0500
Message-ID: <4F35512A.9050500@steve-ss.com>
Date: Fri, 10 Feb 2012 18:17:30 +0100
From: steve <steve@steve-ss.com>
MIME-Version: 1.0
To: whats_up@gmx.net
CC: linux-nfs@vger.kernel.org
Subject: Re: mount hangs in NFS4+Kerberos setup
References: <20120210154526.7b504146@little-poseidon>
In-Reply-To: <20120210154526.7b504146@little-poseidon>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/10/2012 03:45 PM, whats_up@gmx.net wrote:
> Hi,
>
> I want to setup a file server with NFS4+Kerberos and Debian squeeze for
> clients running Ubuntu 11.10.
>
> What is already working:
> 1) Mount NFS4 on client without krb5 option works. Users are able to
> access files and uids/gids are correct. 2) KDC works. Access from
> client, get tickets, user authentication/change password through pam is
> ok.
>
> Now I want to mount with sec=krb5 but this time the command hangs and
> does not return to shell. See also logs below.
>
> Any hints to fix the issue or to get more helpful debug information are
> welcome.
>
> regards
>    knut
>
>
>
>
> === server status ===
>
> Debian Linux squeeze
>
> # uname -a
> Linux tm 2.6.32-5-686 #1 SMP Mon Jan 16 16:04:25 UTC 2012 i686 GNU/Linux
Ubuntu 11.10
uname -r
3.0.0-15-generic

Some older kernels do not support strong keys. Try adding:
allow_weak_crypto = true
to the
  [libdefaults]
in /etc/krb5.conf

Here it is using the machine principal with arcfour:

Kerberos: AS-REQ nfs/hh3.hh3.site@HH3.SITE from ipv4:192.168.1.3:49650 
for krbtgt/HH3.SITE@HH3.SITE
Kerberos: UNKNOWN -- nfs/hh3.hh3.site@HH3.SITE: no such entry found in hdb
Kerberos: AS-REQ HH3$@HH3.SITE from ipv4:192.168.1.3:43041 for 
krbtgt/HH3.SITE@HH3.SITE
Kerberos: Client sent patypes: 149
Kerberos: Looking for PKINIT pa-data -- HH3$@HH3.SITE
Kerberos: Looking for ENC-TS pa-data -- HH3$@HH3.SITE
Kerberos: No preauth found, returning PREAUTH-REQUIRED -- HH3$@HH3.SITE
Kerberos: AS-REQ HH3$@HH3.SITE from ipv4:192.168.1.3:32850 for 
krbtgt/HH3.SITE@HH3.SITE
Kerberos: Client sent patypes: encrypted-timestamp, 149
Kerberos: Looking for PKINIT pa-data -- HH3$@HH3.SITE
Kerberos: Looking for ENC-TS pa-data -- HH3$@HH3.SITE
Kerberos: ENC-TS Pre-authentication succeeded -- HH3$@HH3.SITE using 
arcfour-hmac-md5
Kerberos: AS-REQ authtime: 2012-02-10T18:00:16 starttime: unset endtime: 
2012-02-11T04:00:16 renew till: 2012-02-11T18:00:15
Kerberos: Client supported enctypes: aes256-cts-hmac-sha1-96, 
aes128-cts-hmac-sha1-96, des3-cbc-sha1, arcfour-hmac-md5, using 
arcfour-hmac-md5/arcfour-hmac-md5
Kerberos: Requested flags: renewable-ok
Kerberos: TGS-REQ HH3$@HH3.SITE from ipv4:192.168.1.3:41288 for 
nfs/hh3.hh3.site@HH3.SITE [canonicalize, renewable]
Kerberos: TGS-REQ authtime: 2012-02-10T18:00:16 starttime: 
2012-02-10T18:00:16 endtime: 2012-02-11T04:00:16 renew till: 
2012-02-11T18:00:15

Also it's not recommended to use the pseudo-root fsid=0 method for nfs 
exports under Linux:
  http://wiki.linux-nfs.org/wiki/index.php/Nfsv4_configuration

HTH,
Steve

