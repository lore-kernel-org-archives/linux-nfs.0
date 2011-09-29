Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:18221 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754012Ab1I2S7o convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Sep 2011 14:59:44 -0400
Subject: Re: 3.1rc7+ FSX failure over NFS
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Dave Jones <davej@redhat.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Thu, 29 Sep 2011 14:59:32 -0400
In-Reply-To: <20110929184127.GA12236@redhat.com>
References: <20110929184127.GA12236@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1317322772.8708.30.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-09-29 at 14:41 -0400, Dave Jones wrote: 
> Client is running 3.1rc7+ from a day before rc8 landed.
> Server is 3.0.4. FSX dies after a half hour or so.
> Mount options are..
> (rw,relatime,vers=3,rsize=524288,wsize=524288,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=192.168.42.10,mountvers=3,mountport=45114,mountproto=tcp,local_lock=none,addr=192.168.42.10)
> 
> I noticed a few NFS commits that I might be missing from
> the last few days, would they explain this ?

Hi Dave,

No, there shouldn't be anything in recent patches that can explain or
fix this.

I have a few questions:

1) What filesystem are you using on the server, and does that filesystem
support high resolution timestamps?
2) Does the file length on the server match the reported erroneous file
length on the client?
3) Do the mtime and ctime on the erroneous file match on the client and
server?

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

