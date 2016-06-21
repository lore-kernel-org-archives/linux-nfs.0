Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43652 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751983AbcFURUb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Jun 2016 13:20:31 -0400
Subject: Re: [PATCH 1/1 v2] systemd: Only start the gssd daemons when they are
 enabled
To: Chuck Lever <chuck.lever@oracle.com>
References: <1466520807-4340-1-git-send-email-steved@redhat.com>
 <09ECB137-8EC4-4713-B5F4-44D0405B2700@oracle.com>
 <c21d7a5d-853f-1722-53b4-99f66f263d74@RedHat.com>
 <AA20A3F4-82FB-4118-B0F2-012890D24042@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <a82a0e31-a0e0-409a-8310-bd62cf0436b5@RedHat.com>
Date: Tue, 21 Jun 2016 13:20:20 -0400
MIME-Version: 1.0
In-Reply-To: <AA20A3F4-82FB-4118-B0F2-012890D24042@oracle.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey,

On 06/21/2016 11:47 AM, Chuck Lever wrote:
>>> >> When you say "the upcall fails" do you mean there is
>>> >> no reply, or that there is a negative reply after a
>>> >> delay, or there is an immediate negative reply?
>> > Good point.. the upcalls did not fail, they
>> > just received negative replies.
> I would say that the upcalls themselves are not the
> root cause of the delay if they all return immediately.
Well when rpc.gssd is not running (aka no upcalls)
the delays stop happening. 

> 
> Are you saying that each negative reply takes a moment?
Yes. Even on sec=sys mounts. Which is the issue. 

> If that's the case, is there something that gssd should
> do to reply more quickly when there's no host or nfs
> service principal in the keytab?
I don't think so... unless we start caching negative
negative response or something like which is way 
overkill especially since the problem is solved
by not starting rpc.gssd.
 
> 
> Adding administrative interface complexity to work around
> an underlying implementation problem might not be the best
> long term choice.
Well there already was way to stop gssd from starting when
kerberos is configured but not for NFS. From the systemd/README:

rpc.gssd and rpc.svcgssd are assumed to be needed if /etc/krb5.keytab
is present.
If a site needs this file present but does not want the gss daemons
running, it should create
   /etc/systemd/system/rpc-gssd.service.d/01-disable.conf
and
   /etc/systemd/system/rpc-svcgssd.service.d/01-disable.conf

containing
   [Unit]
   ConditionNull=false

Which does work and will still work... but I'm thinking it is
much similar to disable the service via systemd command
   systemctl disable rpc-gssd

than creating and editing those .conf files.

steved
