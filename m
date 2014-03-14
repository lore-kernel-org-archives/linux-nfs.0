Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f53.google.com ([209.85.160.53]:36613 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752864AbaCNATg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Mar 2014 20:19:36 -0400
Received: by mail-pb0-f53.google.com with SMTP id rp16so1832771pbb.12
        for <linux-nfs@vger.kernel.org>; Thu, 13 Mar 2014 17:19:35 -0700 (PDT)
Message-ID: <53224B13.4040203@primarydata.com>
Date: Fri, 14 Mar 2014 02:19:31 +0200
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: linux-nfs <linux-nfs@vger.kernel.org>
CC: Michael Maymann <michael@maymann.org>
Subject: Fwd: Re: [nfsv4] PNFS questions
References: <047d7bf0e158e2cae904f485b5fc@google.com>
In-Reply-To: <047d7bf0e158e2cae904f485b5fc@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Resending as the original message bounced back (html).


-------- Original Message --------
From: Benny Halevy <bhalevy@primarydata.com>
Date: Fri, 14 Mar 2014 01:56:44 +0200
Subject: Re: [nfsv4] PNFS questions
To: Michael Maymann <michael@maymann.org>, NFS list <linux-nfs@vger.kernel.org>
Cc: "nfsv4@ietf.org" <nfsv4@ietf.org>

Michael, the IETF mailing list is really not the right place to ask about
commercial solutions in general or linux solutions in particular.
Cc'ing the linux-nfs mailing list. Comments in line below.


On Thu, Mar 13, 2014 at 9:02 PM, Michael Maymann <michael@maymann.org>wrote:

> Hi list,
>
> I'm setting up a new BIO-HPC facility and are looking for a fault
> tolerant, scalable, fast and priceeffective storage solution.
>
> I have been looking at Coraid, Panasas and Lustre, but would like to
> investigate my options also of building my own PNFS solution. Clients are
> all Debian based.
>
> Can anyone recommend:
> 1. If PNFS is ready for production or if I should stick with a commercial
> vendor or build a Lustre solution ?
>

There is no pNFS server implementation in upstream linux yet.
We maintain a development out-of-kernel tree in git://
linux-nfs.org/~bhalevy/linux-pnfs.git
but it is not production ready.


> 2. PNFS Metadata server SW prefferably for Debian ?
>

ditto #1


>  3. PNFS Diskshelfs to be used ?
>

In pNFS terminology, these are Data Servers.


>  4. If AOE (ATA Over Ethernet) would make any sense together with PNFS ?
>

Maybe using the Block layout and AoE as the block storage transport
protocol.


>  5. PNFS GUI SW prefferably for Debian ?
>

ditto #1



> Thanks in advance :-) !
>
> BR.
> ~Maymann
>
> _______________________________________________
> nfsv4 mailing list
> nfsv4@ietf.org
> https://www.ietf.org/mailman/listinfo/nfsv4
>
>


