Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:64436 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751911Ab1LUN7t convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Dec 2011 08:59:49 -0500
Message-ID: <1324475851.7709.12.camel@lade.trondhjem.org>
Subject: Re: Session timeout on RHEL6.2
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: tigran.mkrtchyan@desy.de
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Date: Wed, 21 Dec 2011 14:57:31 +0100
In-Reply-To: <CAGue13pWcOKeQH9nr=VK2ZCMLpC2s1=yQwuyxAEuuizjSh1Z+g@mail.gmail.com>
References: <CAGue13pWcOKeQH9nr=VK2ZCMLpC2s1=yQwuyxAEuuizjSh1Z+g@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2011-12-21 at 10:24 +0100, Tigran Mkrtchyan wrote: 
> Dear friends,
> 
> We are observing strange behavior with RHEL 6.2:
> 
> Our the server lease time is 90 seconds. I can see that client
> sends SEQUENCE every 60 sec. And this is for some hours ( ~8 ).
> At some point client sends SEQUENCE after 127 seconds and
> gets, as expected, EXPIRED.

Why shouldn't the client be allowed to let the lease expire if nothing
is using that filesystem?

> I this point I have to blame myself.
> Client comes with EXCHANGE_ID using the same clientid.
> We did not garbage collected clientid internally as this happens after
> 2*LEASE_TIME
> and return EXPIRE. This ping-pong never ends.
> 
> This is probably mostly a bug on my side. Nevertheless we never observed late
> SEQUENCE with kernel > 2.6.39. A short packet dump attached.
> 
> I can open bug at RHEL if required.

I wouldn't consider that a bug.

Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

