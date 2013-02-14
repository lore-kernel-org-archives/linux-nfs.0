Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:43173 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757931Ab3BNP53 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Feb 2013 10:57:29 -0500
Content-Type: text/plain; charset=iso-8859-1
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Subject: Re: Kernels 3.7 and newer break rpc.gssd -n
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1117889154.119108.1360851840169.JavaMail.root@opinsys.fi>
Date: Thu, 14 Feb 2013 10:57:22 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <DA37FD67-166A-4A41-9EC5-13DECE99511B@oracle.com>
References: <127351146.98508.1360769367943.JavaMail.root@opinsys.fi> <1117889154.119108.1360851840169.JavaMail.root@opinsys.fi>
To: Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 14, 2013, at 9:24 AM, Veli-Matti Lintu <veli-matti.lintu@opinsys.fi> wrote:

> 
>> I've been using kerberized nfs4 mounts without machine credentials for
>> quite some time by running rpc.gssd with the -n option. This has
>> resulted rpc.gssd in using ccache in /tmp/krb5cc_0 when doing the mount
>> instead of machine credentials. This functionality seems to break when
>> using kernel 3.7 or newer. 3.6.11 and earlier work like expected.
>> 
>> The use case for this is diskless workstations that do not have machine
>> credentials stored on them as they have no secure storage medium. When a
>> user logs in, the home directory is mounted using the user's credentials
>> only.
>> 
>> Steps to reproduce the problem:
>> 
>> # kinit user (this creates /tmp/krb5cc_0)
>> # rpc.gssd -f -n -vvvv
>> # mount -t nfs4 -o sec=krb5 server.example.org:/home /mnt
>> 
>> The mount works when using kernel 3.6.11 or earlier and fails on 3.7-rc1
>> or later. Testing was done on Ubuntu 12.04 and 12.10 using Ubuntu kernels
>> and kernel.org kernels (up to 3.8-rc7) with similar results.
>> 
>> nfs-utils versions 1.2.5 and the latest version from git master head
>> (git://linux-nfs.org/nfs-utils) behave the same way.
> 
> ...
> 
>> It seems like the kernel now asks rpc.gssd to fetch credentials for
>> service '*' instead of NULL like with 3.6 and earlier.
> 
> I got some bisecting help from Tuomas Räsänen who managed to find the 
> commit that introduces the change. Here's what he found. I haven't 
> yet figured out what in the commit causes the change in behaviour. 
> Before that patch the kernel asks rpc.gssd for service <null>, but 
> with the patch applied, it requests for service '*' when doing the 
> initial mount with sec=krb5.

While I am trying to reproduce this, have a look at commit a56989b6 in nfs-utils 1.2.8-rc1.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

