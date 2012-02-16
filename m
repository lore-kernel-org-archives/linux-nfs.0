Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ww0-f44.google.com ([74.125.82.44]:56618 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751134Ab2BPOYN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Feb 2012 09:24:13 -0500
Received: by wgbdt10 with SMTP id dt10so1970138wgb.1
        for <linux-nfs@vger.kernel.org>; Thu, 16 Feb 2012 06:24:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4F3CD0D7.8040402@steve-ss.com>
References: <4F3CD0D7.8040402@steve-ss.com>
Date: Thu, 16 Feb 2012 09:24:12 -0500
Message-ID: <CAHVgHyX-NUviMYbg2ROvgXUvj6UhFj1FfsUmcyO9JPxFhwhHcQ@mail.gmail.com>
Subject: Re: NFS4 des and weak crypto
From: Andy Adamson <androsadamson@gmail.com>
To: steve <steve@steve-ss.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 16, 2012 at 4:48 AM, steve <steve@steve-ss.com> wrote:
> Hi
> openSUSE 12.1
>
> I'm trying to explain to our windows admin that modern nfs isn't restricted
> to DES.
>
> Here is a Samba4 authenticated test setup.
>
> I've removed he DES keys from the keytab on the nfs server:
>
> klist -ke /etc/krb5.keytab
> Keytab name: WRFILE:/etc/krb5.keytab
> KVNO Principal
> ---- ---------
>   1 nfs/hh3.hh3.site@HH3.SITE (arcfour-hmac)
>   1 HH3$@hh3.site (arcfour-hmac)
>
> In /etc/krb5.conf, I comment out:
> [libdefaults]
> #allow_weak_crypto = true
> It was never actually there. I've added it help my argument;)
> hh3 is the server, hh6 is the client.
>
> On hh6, root issues:
> mount -t nfs4 hh3:/foo /bar -o sec=krb5
> rpc.gssd -fvvv throws a fit, the KDC responds with,
>
> Kerberos: ENC-TS Pre-authentication succeeded -- HH6$@HH3.SITE using
> arcfour-hmac-md5
> Kerberos: AS-REQ authtime: 2012-02-06T19:44:47 starttime: unset endtime:
> 2012-02-07T05:44:47 renew till: 2012-02-07T19:44:47
> Kerberos: Client supported enctypes: aes256-cts-hmac-sha1-96,
> aes128-cts-hmac-sha1-96, des3-cbc-sha1, arcfour-hmac-md5, des-cbc-crc,
> des-cbc-md5, des-cbc-md4, using arcfour-hmac-md5/arcfour-hmac-md5
> Kerberos: Requested flags: renewable-ok
> Kerberos: TGS-REQ HH6$@HH3.SITE from ipv4:192.168.1.10:45421 for
> nfs/hh3.hh3.site@HH3.SITE [canonicalize, renewable]
> Kerberos: TGS-REQ authtime: 2012-02-06T19:44:47 starttime:
> 2012-02-06T19:44:47 endtime: 2012-02-07T05:44:47 renew till: 20
>
> we can logon and request files via the mount.
>
> Questions
> Does this procedure prove that nfs can use other than DES crypto?
> Is arcfour what an AD admin would consider strong encryption?

Linux NFS clients and servers can use any of the crypto listed above
in the "client supported enctypes". aes256-cts-hmac-sha1-96 is the
strongest.

-->Andy

>
> Thanks,
> Steve
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
