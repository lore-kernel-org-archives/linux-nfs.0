Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1050.oracle.com ([156.151.31.82]:18420 "EHLO
	userp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751189AbcFUTcJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Jun 2016 15:32:09 -0400
Received: from userp1040.oracle.com (userp1040.oracle.com [156.151.31.81])
	by userp1050.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id u5LHx5iv010714
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 21 Jun 2016 17:59:05 GMT
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH 1/1 v2] systemd: Only start the gssd daemons when they are enabled
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <a82a0e31-a0e0-409a-8310-bd62cf0436b5@RedHat.com>
Date: Tue, 21 Jun 2016 13:57:53 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <1D39CEF6-AC29-4166-95DF-ADBD2C0286B3@oracle.com>
References: <1466520807-4340-1-git-send-email-steved@redhat.com> <09ECB137-8EC4-4713-B5F4-44D0405B2700@oracle.com> <c21d7a5d-853f-1722-53b4-99f66f263d74@RedHat.com> <AA20A3F4-82FB-4118-B0F2-012890D24042@oracle.com> <a82a0e31-a0e0-409a-8310-bd62cf0436b5@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jun 21, 2016, at 1:20 PM, Steve Dickson <SteveD@redhat.com> wrote:
> 
> Hey,
> 
> On 06/21/2016 11:47 AM, Chuck Lever wrote:
>>>>>> When you say "the upcall fails" do you mean there is
>>>>>> no reply, or that there is a negative reply after a
>>>>>> delay, or there is an immediate negative reply?
>>>> Good point.. the upcalls did not fail, they
>>>> just received negative replies.
>> I would say that the upcalls themselves are not the
>> root cause of the delay if they all return immediately.
> Well when rpc.gssd is not running (aka no upcalls)
> the delays stop happening.

Well let me say it a different way: the mechanism of
performing an upcall should be fast. The stuff that gssd
is doing as a result of the upcall request may be taking
longer than expected, though.

If gssd is up, and has nothing to do (which I think is
the case here?) then IMO that upcall should be unnoticeable.
I don't expect there to be any difference between the kernel
squelching an upcall, and an upcall completing immediately.


>> Are you saying that each negative reply takes a moment?
> Yes. Even on sec=sys mounts. Which is the issue.

Yep, I get that. I've seen that behavior on occasion,
and agree it should be addressed somehow.


>> If that's the case, is there something that gssd should
>> do to reply more quickly when there's no host or nfs
>> service principal in the keytab?
> I don't think so... unless we start caching negative
> negative response or something like which is way 
> overkill especially since the problem is solved
> by not starting rpc.gssd.

I'd like to understand why this upcall, which should be
equivalent to a no-op, is not returning an immediate
answer. Three of these in a row shouldn't take more than
a dozen milliseconds.

How long does the upcall take when there is a service
principal versus how long it takes when there isn't one?
Try running gssd under strace to get some timings.

Is gssd waiting for syslog or something?


>> Adding administrative interface complexity to work around
>> an underlying implementation problem might not be the best
>> long term choice.
> Well there already was way to stop gssd from starting when
> kerberos is configured but not for NFS. From the systemd/README:
> 
> rpc.gssd and rpc.svcgssd are assumed to be needed if /etc/krb5.keytab
> is present.
> If a site needs this file present but does not want the gss daemons
> running, it should create
>   /etc/systemd/system/rpc-gssd.service.d/01-disable.conf
> and
>   /etc/systemd/system/rpc-svcgssd.service.d/01-disable.conf
> 
> containing
>   [Unit]
>   ConditionNull=false
> 
> Which does work and will still work... but I'm thinking it is
> much similar to disable the service via systemd command
>   systemctl disable rpc-gssd
> 
> than creating and editing those .conf files.

This should all be automatic, IMO.

On Solaris, drop in a keytab and a krb5.conf, and add sec=krb5
to your mounts. No reboot, nothing to restart. Linux should be
that simple.


--
Chuck Lever



