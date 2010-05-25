Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:57749 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932693Ab0EYOEg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 May 2010 10:04:36 -0400
Subject: Re: Deadlock in NFSv4 in all kernels
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Cc: Lukas Hejtmanek <xhejtman@ics.muni.cz>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        salvet@ics.muni.cz
In-Reply-To: <AANLkTimsQTYWndbQo2nU01pcJfTRSZlPCMEY8m-CnksM@mail.gmail.com>
References: <20100507153920.GP28167@ics.muni.cz>
	 <AANLkTimsQTYWndbQo2nU01pcJfTRSZlPCMEY8m-CnksM@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 25 May 2010 10:04:30 -0400
Message-ID: <1274796270.5377.48.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-05-25 at 09:45 -0400, William A. (Andy) Adamson wrote: 
> 2010/5/7 Lukas Hejtmanek <xhejtman@ics.muni.cz>:
> > Hi,
> >
> > I encountered the following problem. We use short expiration time for
> > kerberos contexts created by rpc.gssd (some patches were included in mainline
> > nfs-utils). In particular, we use 120secs expiration time.
> >
> > Now, I run application that eats 80% of available RAM. Then I run 10 parallel
> > dd processes that write data into NFS4 volume with sec=krb5.
> >
> > As soon as the kerberos context expires (i.e., up to 120 secs), the whole
> > system gets stuck in do_page_fault and succesive functions. It is because
> > there is no free memory in kernel, all free memory is used as cache for NFS4
> > (due to dd traffic), kernel ask NFS to write back its pages but NFS cannot do
> > anything as it is missing valid context. NFS contacts rpc.gssd to provide
> > a renewed context, the rpc.gssd does not provide the context as it needs some memory
> > to scan /tmp for a ticket. I.e., it deadlocks.
> >
> > Longer context expiration time is no real solution as it only makes the
> > deadlock less often.
> >
> > Any ideas what can be done here?
> 
> Not get into the problem in the first place: this means
> 
> 1) determine a 'lead time' where the NFS client declares a context
> expired even though it really as 'lead time' until it actually
> expires.
> 
> 2) flush all writes on any contex that will expire within the lead
> time which needs to be long enough for flushes to take place.

That too is only a partial solution. The GSS context can expire early
due to totally unforeseeable circumstances such as a server reboot, for
instance.


