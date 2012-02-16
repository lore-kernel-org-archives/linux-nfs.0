Return-Path: linux-nfs-owner@vger.kernel.org
Received: from partagas.dragonet.es ([217.70.240.130]:59430 "EHLO
	partagas.dragonet.es" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750914Ab2BPJsW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Feb 2012 04:48:22 -0500
Received: from [192.168.1.3] (217-70-247-131.dragonet.es [217.70.247.131] (may be forged))
	(authenticated bits=0)
	by partagas.dragonet.es (8.12.11/8.12.11) with ESMTP id q1G9mg83018263
	for <linux-nfs@vger.kernel.org>; Thu, 16 Feb 2012 10:48:50 +0100
Message-ID: <4F3CD0D7.8040402@steve-ss.com>
Date: Thu, 16 Feb 2012 10:48:07 +0100
From: steve <steve@steve-ss.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: NFS4 des and weak crypto
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi
openSUSE 12.1

I'm trying to explain to our windows admin that modern nfs isn't 
restricted to DES.

Here is a Samba4 authenticated test setup.

I've removed he DES keys from the keytab on the nfs server:

klist -ke /etc/krb5.keytab
Keytab name: WRFILE:/etc/krb5.keytab
KVNO Principal
---- ---------
    1 nfs/hh3.hh3.site@HH3.SITE (arcfour-hmac)
    1 HH3$@hh3.site (arcfour-hmac)

In /etc/krb5.conf, I comment out:
[libdefaults]
#allow_weak_crypto = true
It was never actually there. I've added it help my argument;)
hh3 is the server, hh6 is the client.

On hh6, root issues:
mount -t nfs4 hh3:/foo /bar -o sec=krb5
rpc.gssd -fvvv throws a fit, the KDC responds with,

Kerberos: ENC-TS Pre-authentication succeeded -- HH6$@HH3.SITE using 
arcfour-hmac-md5
Kerberos: AS-REQ authtime: 2012-02-06T19:44:47 starttime: unset endtime: 
2012-02-07T05:44:47 renew till: 2012-02-07T19:44:47
Kerberos: Client supported enctypes: aes256-cts-hmac-sha1-96, 
aes128-cts-hmac-sha1-96, des3-cbc-sha1, arcfour-hmac-md5, des-cbc-crc, 
des-cbc-md5, des-cbc-md4, using arcfour-hmac-md5/arcfour-hmac-md5
Kerberos: Requested flags: renewable-ok
Kerberos: TGS-REQ HH6$@HH3.SITE from ipv4:192.168.1.10:45421 for 
nfs/hh3.hh3.site@HH3.SITE [canonicalize, renewable]
Kerberos: TGS-REQ authtime: 2012-02-06T19:44:47 starttime: 
2012-02-06T19:44:47 endtime: 2012-02-07T05:44:47 renew till: 20

we can logon and request files via the mount.

Questions
Does this procedure prove that nfs can use other than DES crypto?
Is arcfour what an AD admin would consider strong encryption?

Thanks,
Steve

