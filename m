Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f49.google.com ([209.85.219.49]:56215 "EHLO
	mail-oa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752068Ab3FQO6K (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Jun 2013 10:58:10 -0400
Received: by mail-oa0-f49.google.com with SMTP id n9so3484086oag.22
        for <linux-nfs@vger.kernel.org>; Mon, 17 Jun 2013 07:58:10 -0700 (PDT)
Received: from ?IPv6:2001:470:d:51c::8924:fefd? ([2001:470:d:51c::8924:fefd])
        by mx.google.com with ESMTPSA id m3sm12995922oex.7.2013.06.17.07.58.08
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 17 Jun 2013 07:58:09 -0700 (PDT)
Message-ID: <51BF23FE.4070106@gmail.com>
Date: Mon, 17 Jun 2013 08:58:06 -0600
From: John Haiducek <jhaiduce@gmail.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Re: Can't mount NFSv4 with kerberos on Debian Wheezy
References: <51BF21E0.8060805@gmail.com>
In-Reply-To: <51BF21E0.8060805@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On 06/14/2013 02:13 PM, Chuck Lever wrote:
>
> On Jun 14, 2013, at 3:49 PM, John Haiducek <jhaiduce@gmail.com 
> <mailto:jhaiduce@gmail.com>> wrote:
>
>>
>> On Jun 14, 2013 11:05 AM, "Chuck Lever" <chuck.lever@oracle.com 
>> <mailto:chuck.lever@oracle.com>> wrote:
>> >
>> >
>> > On Jun 14, 2013, at 1:57 AM, John Haiducek <jhaiduce@gmail.com 
>> <mailto:jhaiduce@gmail.com>> wrote:
>> >
>> > > Jun 11 20:28:23 tbm rpc.gssd[8959]: Name or service not known 
>> while getting full hostname for 'tbm.enterprise.local'
>> >
>> > gssd thinks your client's hostname is "tbm.enterprise.local," which 
>> has no DNS entry.
>>
>> That is the correct client hostname, and according to the 'host' 
>> command it is in dns. What would cause the host command to find it 
>> when gssd can't?
>>
>
> The error message is from utils/gssd/krb5_util.c:get_full_hostname(). 
>  If get_full_hostname() fails, then gssd can't search your client's 
> keytab.
>
> Figure out why that getaddrinfo(3) call is failing to find a canonical 
> name for "tbm.enterprise.local" -- that could be a client system 
> configuration problem as much as a DNS misconfiguration.

Incidentally, I have a dual-stack network (ipv4 and ipv6). My best guess 
is that ipv6 is not part of the problem; the client and server had 
missing AAAA records in DNS; when I added those the NFS mount switched 
automatically to using ipv6 for the connection but it hangs the same as 
before.

John

