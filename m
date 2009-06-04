Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:51981 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750814AbZFDUnS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Jun 2009 16:43:18 -0400
In-Reply-To: <1244138698.5203.59.camel@heimdal.trondhjem.org>
References: <OF3EBF546E.60A83A8F-ON852575A8.006EBB38-852575A8.006EFDE6@us.ibm.com>	 <OF820C8732.74757E21-ON852575C5.0055C089-852575C5.00578071@us.ibm.com>
	 <1243615595.7155.48.camel@heimdal.trondhjem.org>	 <OF0EEDB635.561D17D4-ON852575C5.005CBABA-852575C5.005FAD0D@us.ibm.com>
	 <1243618500.7155.56.camel@heimdal.trondhjem.org>	 <ac442c870905291722x1ec811b2sda997d464898fcda@mail.gmail.com>
	 <1243686363.5209.16.camel@heimdal.trondhjem.org>	 <ac442c870905300602v6950ec42y5195d2d6ea7dd4c@mail.gmail.com>
	 <BA67D2A4-1752-4789-ADB9-D1B3C6D197F6@oracle.com>	 <1243963631.4868.124.camel@heimdal.trondhjem.org>
	 <18982.41770.293636.786518@fisica.ufpr.br>	 <1244049027.5603.5.camel@heimdal.trondhjem.org>
	 <OFB53BFCCB.0CEC7A7E-ON852575C <1244138698.5203.59.camel@heimdal.trondhjem.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Carlos Carvalho <carlos@fisica.ufpr.br>, linux-nfs@vger.kernel.org,
        linux-nfs-owner@vger.kernel.org
Subject: Link performance over NFS degraded in RHEL5. -- was : Read/Write NFS I/O
 performance degraded by FLUSH_STABLE page flushing
From: Brian R Cowan <brcowan@us.ibm.com>
Message-ID: <OF37FCED66.33F08949-ON852575CB.006DE109-852575CB.0071CFBD@us.ibm.com>
Date: Thu, 4 Jun 2009 16:43:07 -0400
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trond Myklebust <trond.myklebust@fys.uio.no> wrote on 06/04/2009 02:04:58 
PM:

> Did you try turning off write gathering on the server (i.e. add the
> 'no_wdelay' export option)? As I said earlier, that forces a delay of
> 10ms per RPC call, which might explain the FILE_SYNC slowness.

Just tried it, this seems to be a very useful workaround as well. The 
FILE_SYNC write calls come back in about the same amount of time as the 
write+commit pairs... Speeds up building regardless of the network 
filesystem (ClearCase MVFS or straight NFS).

> > The bottom line:
> > * If someone can help me find where 2.6 stopped setting small writes 
to 
> > FILE_SYNC, I'd appreciate it. It would save me time walking through 
>50 
> > commitdiffs in gitweb...
> 
> It still does set FILE_SYNC for single page writes.

Well, the network trace *seems* to say otherwise, but that could be 
because the 2.6.29 kernel is now reliably following a code path that 
doesn't set up to do FILE_SYNC writes for these flushes... Just like the 
RHEL 5 traces didn't have every "small" write to the link output file go 
out as a FILE_SYNC write.

> 
> > * Is this the correct place to start discussing the annoying 
> > write-before-almost-every-read behavior that 2.6.18 picked up and 
2.6.29 
> > continues? 
> 
> Yes, but you'll need to tell us a bit more about the write patterns. Are
> these random writes, or are they sequential? Is there any file locking
> involved?

Well, it's just a link, so it's random read/write traffic. (read object 
file/library, add stuff to output file, seek somewhere else and update a 
table, etc., etc.) All I did here was build Samba over nfs, remove 
bin/smbd, and then do a "make bin/smbd" to rebuild it. My network traces 
show that the file is opened "UNCHECKED" when doing the build in straight 
NFS, and "EXCLUSIVE" when building in a ClearCase view. This change does 
not seem to impact the behavior. We never lock the output file. The 
write-before-read happens all over the place. And when we did straces and 
lined up the call times, is it a read operation triggering the write. 

> 
> As I've said earlier in this thread, all NFS clients will flush out the
> dirty data if a page that is being attempted read also contains
> uninitialised areas.

What I'm trying to understand is why RHEL 4 is not flushing anywhere near 
as often. Either RHEL4 erred on the side of not writing, and RHEL5 is 
erring on the opposite side, or RHEL5 is doing unnecessary flushes... I've 
seen that 2.6.29 flushes less than the Red hat 2.6.18-derived kernels, but 
it still flushes a lot more than RHEL 4 does.

In any event, that doesn't help us here since 1) ClearCase can't work with 
that kernel; 2) Red Hat won't support use of that kernel on RHEL 5; and 3) 
the amount of code review my customer would have to go through to get the 
whole kernel vetted for use in their environment is frightening.

