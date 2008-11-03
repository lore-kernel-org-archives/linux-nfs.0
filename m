From: "Kevin Coffman" <kwc@umich.edu>
Subject: Re: stuck/hung nfsv4 mounts
Date: Mon, 3 Nov 2008 15:28:11 -0500
Message-ID: <4d569c330811031228r5bb9aefs7a970303910810e2@mail.gmail.com>
References: <1225724721.2247.29.camel@brian-laptop>
	 <1225731544.6958.6.camel@heimdal.trondhjem.org>
	 <1225734631.2247.76.camel@brian-laptop>
	 <4d569c330811031158r26963e0w5bcf8331e0fb14b7@mail.gmail.com>
	 <1225742958.2247.128.camel@brian-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "Brian J. Murrell" <brian-SquOHqY54CVWr29BmMi2cA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.171]:4760 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753958AbYKCU2M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Nov 2008 15:28:12 -0500
Received: by wf-out-1314.google.com with SMTP id 27so2728998wfd.4
        for <linux-nfs@vger.kernel.org>; Mon, 03 Nov 2008 12:28:12 -0800 (PST)
In-Reply-To: <1225742958.2247.128.camel@brian-laptop>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 3, 2008 at 3:09 PM, Brian J. Murrell <brian-SquOHqY54CVWr29BmMi2cA@public.gmane.org> wrote:
> On Mon, 2008-11-03 at 14:58 -0500, Kevin Coffman wrote:
>>
>> These are all from librpcsecgss (from the -rrr).  I don't see an error here.
>
> Good.
>
>> You should have gotten output from gssd itself as well.  You might
>> also look for any errors on the server from rpc.svcgssd.
>
> Nothing.
>
>> This looks fine.  (Assuming linux.interlinx.bc.ca is the NFS server
>> and pc.interlinx.bc.ca is the client.)
>
> Indeed, they both are as you assume.
>
> So I've restarted both the rpc.svcgssd and rpc.gssd with -rrr -vvv on
> the server and client (respectively) to see what more I can see but I
> can't get the upcall to trigger.  I would have thought simply issuing a
> mount would do that, but it seems not.  What exactly causes the upcall
> to be made and what might prevent it from being made?

There should definitely be corresponding debug output from rpc.gssd
(-vvv) if you got those librpcsecgss (-rrr) messages.  I would suggest
that you leave off the -rrr for now as it appears to be extra clutter
at this point.  It might help if you run rpc.gssd in the foreground
(-f) while debugging.  Also, make sure this is the only rpc.gssd
running.

Re: the upcall.  Any new mount using Kerberos should cause the upcall
to create a new context with the server.  Make sure the filesystem is
not already mounted.  After the mount, any new user accessing that
mounted filesystem should cause an upcall to create a context for that
user.

K.C.
