Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gx0-f174.google.com ([209.85.161.174]:46479 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752244Ab2BPQtM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Feb 2012 11:49:12 -0500
Received: by ggnh1 with SMTP id h1so1357133ggn.19
        for <linux-nfs@vger.kernel.org>; Thu, 16 Feb 2012 08:49:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAHVgHyX-NUviMYbg2ROvgXUvj6UhFj1FfsUmcyO9JPxFhwhHcQ@mail.gmail.com>
References: <4F3CD0D7.8040402@steve-ss.com>
	<CAHVgHyX-NUviMYbg2ROvgXUvj6UhFj1FfsUmcyO9JPxFhwhHcQ@mail.gmail.com>
Date: Thu, 16 Feb 2012 11:49:11 -0500
Message-ID: <CAKnQG+eYFcOFcKdw02KivkQDSBz6Tyv1VTwQR9rjA17Piw3tbA@mail.gmail.com>
Subject: Re: NFS4 des and weak crypto
From: Kevin Coffman <kwc@umich.edu>
To: steve <steve@steve-ss.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 16, 2012 at 9:24 AM, Andy Adamson <androsadamson@gmail.com> wrote:
> On Thu, Feb 16, 2012 at 4:48 AM, steve <steve@steve-ss.com> wrote:
>> Hi
>> openSUSE 12.1
>>
>> I'm trying to explain to our windows admin that modern nfs isn't restricted
>> to DES.
>>
>> Here is a Samba4 authenticated test setup.
>>
>> I've removed he DES keys from the keytab on the nfs server:
>>
>> klist -ke /etc/krb5.keytab
>> Keytab name: WRFILE:/etc/krb5.keytab
>> KVNO Principal
>> ---- ---------
>>   1 nfs/hh3.hh3.site@HH3.SITE (arcfour-hmac)
>>   1 HH3$@hh3.site (arcfour-hmac)
>>
>> In /etc/krb5.conf, I comment out:
>> [libdefaults]
>> #allow_weak_crypto = true
>> It was never actually there. I've added it help my argument;)
>> hh3 is the server, hh6 is the client.
>>
>> On hh6, root issues:
>> mount -t nfs4 hh3:/foo /bar -o sec=krb5
>> rpc.gssd -fvvv throws a fit, the KDC responds with,
>>
>> Kerberos: ENC-TS Pre-authentication succeeded -- HH6$@HH3.SITE using
>> arcfour-hmac-md5
>> Kerberos: AS-REQ authtime: 2012-02-06T19:44:47 starttime: unset endtime:
>> 2012-02-07T05:44:47 renew till: 2012-02-07T19:44:47
>> Kerberos: Client supported enctypes: aes256-cts-hmac-sha1-96,
>> aes128-cts-hmac-sha1-96, des3-cbc-sha1, arcfour-hmac-md5, des-cbc-crc,
>> des-cbc-md5, des-cbc-md4, using arcfour-hmac-md5/arcfour-hmac-md5
>> Kerberos: Requested flags: renewable-ok
>> Kerberos: TGS-REQ HH6$@HH3.SITE from ipv4:192.168.1.10:45421 for
>> nfs/hh3.hh3.site@HH3.SITE [canonicalize, renewable]
>> Kerberos: TGS-REQ authtime: 2012-02-06T19:44:47 starttime:
>> 2012-02-06T19:44:47 endtime: 2012-02-07T05:44:47 renew till: 20
>>
>> we can logon and request files via the mount.
>>
>> Questions
>> Does this procedure prove that nfs can use other than DES crypto?
>> Is arcfour what an AD admin would consider strong encryption?

As Andy said, modern Linux NFS supports all those "Cllient supported enctypes".

Re: strong encryption for AD.  What version of Windows AD?  If it is
Windows 2003, then yes, I think arcfour would be considered strong.
If it is Windows 2008 or later, AES is supported and is stronger.
(Windows has never supported DES3).

K.C.
