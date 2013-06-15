Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:23225 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754178Ab3FOQ13 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 15 Jun 2013 12:27:29 -0400
Content-Type: text/plain; charset=US-ASCII
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Subject: Re: Can't mount NFSv4 with kerberos on Debian Wheezy
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <51BC8740.8010000@gmail.com>
Date: Sat, 15 Jun 2013 12:27:23 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <FD6F6C61-BF8B-4C9C-BCB5-E240203D3ACB@oracle.com>
References: <51BAAFFC.6060208@gmail.com> <51BAB0BC.1010303@gmail.com> <5A1575CF-0400-48CE-B18B-5B26C92D152A@oracle.com> <CAFYD6QXVKpLDS_cWiA2uasu+KXazcRuk-+BX39MdehSwiu35gw@mail.gmail.com> <871BEFF7-33F4-4B34-9887-D5388951987E@oracle.com> <51BC8740.8010000@gmail.com>
To: John Haiducek <jhaiduce@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 15, 2013, at 11:24 AM, John Haiducek <jhaiduce@gmail.com> wrote:

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
> Ok, I think I fixed the DNS problem. I was running avahi, and apparently you can't use avahi and also have a DNS server with a domain ending in .local. Shutting down avahi fixed it, although if I wanted to keep avahi working I could probably fix this by changing my domain to end in something other than .local.
> 
> But now the mount command hangs and never returns. I get this in /var/log/syslog:
> 
> Jun 15 09:19:36 tbm rpc.idmapd[16253]: New client: 24
> Jun 15 09:19:36 tbm rpc.gssd[16258]: dir_notify_handler: sig 37 si 0x7fffb0fb3330 data 0x7fffb0fb3200
> Jun 15 09:19:37 tbm rpc.gssd[16258]: dir_notify_handler: sig 37 si 0x7fffb0fb3330 data 0x7fffb0fb3200
> Jun 15 09:19:37 tbm rpc.gssd[16258]: dir_notify_handler: sig 37 si 0x7fffb0fb3330 data 0x7fffb0fb3200
> Jun 15 09:19:37 tbm rpc.gssd[16258]: destroying client /var/lib/nfs/rpc_pipefs/nfs/clnt24
> Jun 15 09:19:37 tbm rpc.idmapd[16253]: Stale client: 24
> Jun 15 09:19:37 tbm rpc.idmapd[16253]: #011-> closed /var/lib/nfs/rpc_pipefs/nfs/clnt24/idmap
> Jun 15 09:19:53 tbm rpc.gssd[16258]: dir_notify_handler: sig 37 si 0x7fffb0fb3330 data 0x7fffb0fb3200
> Jun 15 09:19:53 tbm rpc.idmapd[16253]: New client: 25
> 
> I might be missing something, but none of these entries look like errors. Where else should I look?

You can boost the verbosity of the debugging messages from gssd.  Start it with "-vv" or "-vvv".

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




