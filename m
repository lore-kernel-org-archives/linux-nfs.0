From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] mount: enable retry for nfs23 to set the correct protocol
 for mount.
Date: Wed, 16 Jul 2008 13:12:06 -0400
Message-ID: <487E2BE6.5050500@RedHat.com>
References: <18556.40594.897682.204554@notabene.brown> <76bd70e30807150811p56feb02bo6e4a366d5577b398@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
To: chucklever@gmail.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:42629 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751169AbYGPRMl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Jul 2008 13:12:41 -0400
In-Reply-To: <76bd70e30807150811p56feb02bo6e4a366d5577b398-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
> On Tue, Jul 15, 2008 at 8:56 AM, Neil Brown <neilb@suse.de> wrote:
>> on the NFS server.
>> Accessing an NFS server over an SSH tunnel would also be a good test
>> that people are using in real life (IRL as my son says...).
>>
>> NeilBrown
>>
>>
>> From cec4bf512cce4686ed5dd25a9bb489f9e521721d Mon Sep 17 00:00:00 2001
>> From: Neil Brown <neilb@suse.de>
>> Date: Tue, 15 Jul 2008 22:38:17 +1000
>>
>> If an NFS server is only listening on TCP for portmap (as apparently
>> MS-Windows-Server2003R2SP2 does), mount doesn't cope.  There is retry
>> logic in case the initial choice of version/etc doesn't work, but it
>> doesn't cope with mountd needing tcp.
>> So:
>>  Fix probe_port so that a TIMEDOUT error doesn't simply abort
>>    but probes with other protocols (e.g. tcp).
> 
> That seems reasonable and will update the behavior for both legacy and
> text-based mounts.
I agree... 
> 
> But should you teach connect_to() to specifically handle ECONNREFUSED
> as well?  I don't see why there would be a long timeout in that case.
> 
>>  Fix rewrite_mount_options to extract the mountproto option before
>>    doing a probe, then set mountproto  (and mount prot) based
>>    on the result.
> 
> Yes, it should have been doing that anyway.  There's a patch queued up
> in my IPv6 series that addresses this along with other issues, but
> it's reasonable to fix it now.
I agree... 
> 
>>  Enable retry if the mount call returns EIO, as that is what happens
>>    if the UDP requests to portmap get no response.
> 
> I would rather see this one addressed in the kernel.  I think the EIO
> return is a kernel bug.  If the server doesn't support a particular
> transport protocol for portmap, mountd, or NFS, the mount(2) system
> call should always return EPROTONOSUPPORT.
Since EIO has so many meanings... I think it should stay as a fatal 
error as well...

steved.
