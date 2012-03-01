Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:60371 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754946Ab2CAMGu convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Mar 2012 07:06:50 -0500
Received: by obbuo6 with SMTP id uo6so288978obb.19
        for <linux-nfs@vger.kernel.org>; Thu, 01 Mar 2012 04:06:49 -0800 (PST)
MIME-Version: 1.0
Reply-To: tigran.mkrtchyan@desy.de
In-Reply-To: <4F4F2901.4020805@steve-ss.com>
References: <4F3CD0D7.8040402@steve-ss.com>
	<CAGue13obwkrr4eWAdF0nyQZBhZrh4eSKeAgABV-cGd9cu-0zYA@mail.gmail.com>
	<4F4F2901.4020805@steve-ss.com>
Date: Thu, 1 Mar 2012 13:06:49 +0100
Message-ID: <CAGue13qehJdP+nrxFPJsLjk5Jv1CAr00O2NybNOhXSJ2Zu87Tg@mail.gmail.com>
Subject: Re: NFS4 des and weak crypto
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: steve <steve@steve-ss.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve,

you could try to enable capture filter like 'port 2049 and host 192.168.1.8'

to see only nfs traffic.

Tigran.

On Thu, Mar 1, 2012 at 8:45 AM, steve <steve@steve-ss.com> wrote:
> On 02/16/2012 11:45 AM, Tigran Mkrtchyan wrote:
>>
>> Hi Steve,
>>
>> On Thu, Feb 16, 2012 at 10:48 AM, steve<steve@steve-ss.com>  wrote:
>>>
>>> Hi
>>> openSUSE 12.1
>>>
>>> On hh6, root issues:
>>> mount -t nfs4 hh3:/foo /bar -o sec=krb5
>>> rpc.gssd -fvvv throws a fit, the KDC responds with,
>>>
>>> Kerberos: ENC-TS Pre-authentication succeeded -- HH6$@HH3.SITE using
>>> arcfour-hmac-md5
>>> Kerberos: TGS-REQ HH6$@HH3.SITE from ipv4:192.168.1.10:45421 for
>>> nfs/hh3.hh3.site@HH3.SITE [canonicalize, renewable]
>>> Kerberos: TGS-REQ authtime: 2012-02-06T19:44:47 starttime:
>>> 2012-02-06T19:44:47 endtime: 2012-02-07T05:44:47 renew till: 20
>>>
>>> we can logon and request files via the mount.
>>>
>>> Questions
>>> Does this procedure prove that nfs can use other than DES crypto?
>>
>> you can check that with wireshark. My screen shot is attached.
>>
>> Tigran.
>>
> Hi Tigran
>
> Thanks for the reply. I only seem to get smb packets:
> http://2.bp.blogspot.com/-5lxu8-GB44o/T05PfIR-vYI/AAAAAAAAARQ/pfYKQJh1AKM/s1600/w713.png
>
> 192.168.1.3 is a nfs, dns and samba server. 192.168.1.12 is a win 7 client.
> The nfs client at 192.168.1.8 doesn't figure, even though it's getting files
> and dns fine from the same server. What am I missing?
>
> Sorry to trouble you.
> Steve
>
