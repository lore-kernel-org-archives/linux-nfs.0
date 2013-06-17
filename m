Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:28377 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751259Ab3FQPa6 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Jun 2013 11:30:58 -0400
Content-Type: text/plain; charset=US-ASCII
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Subject: Re: Can't mount NFSv4 with kerberos on Debian Wheezy
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <51BF23FE.4070106@gmail.com>
Date: Mon, 17 Jun 2013 11:30:54 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <3E91EC3C-EA92-41A6-9EDA-42E108E83024@oracle.com>
References: <51BF21E0.8060805@gmail.com> <51BF23FE.4070106@gmail.com>
To: John Haiducek <jhaiduce@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 17, 2013, at 10:58 AM, John Haiducek <jhaiduce@gmail.com> wrote:

> 
> On 06/14/2013 02:13 PM, Chuck Lever wrote:
>> 
>> On Jun 14, 2013, at 3:49 PM, John Haiducek <jhaiduce@gmail.com <mailto:jhaiduce@gmail.com>> wrote:
>> 
>>> 
>>> On Jun 14, 2013 11:05 AM, "Chuck Lever" <chuck.lever@oracle.com <mailto:chuck.lever@oracle.com>> wrote:
>>> >
>>> >
>>> > On Jun 14, 2013, at 1:57 AM, John Haiducek <jhaiduce@gmail.com <mailto:jhaiduce@gmail.com>> wrote:
>>> >
>>> > > Jun 11 20:28:23 tbm rpc.gssd[8959]: Name or service not known while getting full hostname for 'tbm.enterprise.local'
>>> >
>>> > gssd thinks your client's hostname is "tbm.enterprise.local," which has no DNS entry.
>>> 
>>> That is the correct client hostname, and according to the 'host' command it is in dns. What would cause the host command to find it when gssd can't?
>>> 
>> 
>> The error message is from utils/gssd/krb5_util.c:get_full_hostname().  If get_full_hostname() fails, then gssd can't search your client's keytab.
>> 
>> Figure out why that getaddrinfo(3) call is failing to find a canonical name for "tbm.enterprise.local" -- that could be a client system configuration problem as much as a DNS misconfiguration.
> 
> Incidentally, I have a dual-stack network (ipv4 and ipv6). My best guess is that ipv6 is not part of the problem; the client and server had missing AAAA records in DNS; when I added those the NFS mount switched automatically to using ipv6 for the connection but it hangs the same as before.

It looks to me like a network connectivity issue at this point.  The next step is to capture a network trace.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



