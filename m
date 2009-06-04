Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:58823 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751297AbZFDSFC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Jun 2009 14:05:02 -0400
Subject: Re: Read/Write NFS I/O performance degraded by FLUSH_STABLE page
 flushing
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Brian R Cowan <brcowan@us.ibm.com>
Cc: Carlos Carvalho <carlos@fisica.ufpr.br>, linux-nfs@vger.kernel.org,
        linux-nfs-owner@vger.kernel.org
In-Reply-To: <OFB53BFCCB.0CEC7A7E-ON852575CA.006BA196-852575CB.00613ABC@us.ibm.com>
References: <OF3EBF546E.60A83A8F-ON852575A8.006EBB38-852575A8.006EFDE6@us.ibm.com>
	 <49FA0CE8.9090706@redhat.com>
	 <1241126587.15476.62.camel@heimdal.trondhjem.org>
	 <OF820C8732.74757E21-ON852575C5.0055C089-852575C5.00578071@us.ibm.com>
	 <1243615595.7155.48.camel@heimdal.trondhjem.org>
	 <OF0EEDB635.561D17D4-ON852575C5.005CBABA-852575C5.005FAD0D@us.ibm.com>
	 <1243618500.7155.56.camel@heimdal.trondhjem.org>
	 <ac442c870905291722x1ec811b2sda997d464898fcda@mail.gmail.com>
	 <1243686363.5209.16.camel@heimdal.trondhjem.org>
	 <ac442c870905300602v6950ec42y5195d2d6ea7dd4c@mail.gmail.com>
	 <BA67D2A4-1752-4789-ADB9-D1B3C6D197F6@oracle.com>
	 <1243963631.4868.124.camel@heimdal.trondhjem.org>
	 <18982.41770.293636.786518@fisica.ufpr.br>
	 <1244049027.5603.5.camel@heimdal.trondhjem.org>
	 <OFB53BFCCB.0CEC7A7E-ON852575CA.006BA196-852575CB.00613ABC@us.ibm.com>
Content-Type: text/plain
Date: Thu, 04 Jun 2009 14:04:58 -0400
Message-Id: <1244138698.5203.59.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2009-06-04 at 13:42 -0400, Brian R Cowan wrote:
> I've been looking in more detail in the network traces that started all 
> this, and doing some additional testing with the 2.6.29 kernel in an 
> NFS-only build...
> 
> In brief:
> 1) RHEL 5 generates >3x the network write traffic than RHEL4 when linking 
> Samba's smbd.
> 2) In RHEL 5, Those unnecessary writes are slowed down by the "FILE_SYNC" 
> optimization put in place for small writes.
> 3) That optimization seems to be removed from the kernel somewhere between 
> 2.6.18 and 2.6.29.
> 4) Unfortunately the "unnecessary write before read" behavior is still 
> present in 2.6.29.
> 
> In detail:
> In RHEL 5, I see a lot of reads from offset {whatever} *immediately* 
> preceded by a write to *the same offset*. This is obviously a bad thing, 
> now the trick is finding out where it is coming from. The 
> write-before-read behavior is happening on the smbd file itself (not 
> surprising since that's the only file we're writing in this test...). This 
> happens with every 2.6.18 and later kernel I've tested to date.
> 
> In RHEL 5, most of the writes are FILE_SYNC writes, which appear to take 
> something on the order of 10ms to come back. When using a 2.6.29 kernel, 
> the TOTAL time for the write+commit rpc set (write rpc, write reply, 
> commit rpc, commit reply), to come back is something like 2ms. I guess the 
> NFS servers aren't handling FILE_SYNC writes very well. in 2.6.29, ALL the 
> write calls appear to be unstable writes, in RHEL5, most are FILE_SYNC 
> writes. (Network traces available upon request.)

Did you try turning off write gathering on the server (i.e. add the
'no_wdelay' export option)? As I said earlier, that forces a delay of
10ms per RPC call, which might explain the FILE_SYNC slowness.

> Neither is quite as fast as RHEL 4, because the link under RHEL 4 only 
> puts about 150 WRITE rpc's on the wire. RHEL 5 generates more than 500 
> when building on NFS, and 2.6.29 puts about 340 write rpc's, plus a 
> similar number of COMMITs, on the wire. 
> 
> The bottom line:
> * If someone can help me find where 2.6 stopped setting small writes to 
> FILE_SYNC, I'd appreciate it. It would save me time walking through >50 
> commitdiffs in gitweb...

It still does set FILE_SYNC for single page writes.

> * Is this the correct place to start discussing the annoying 
> write-before-almost-every-read behavior that 2.6.18 picked up and 2.6.29 
> continues? 

Yes, but you'll need to tell us a bit more about the write patterns. Are
these random writes, or are they sequential? Is there any file locking
involved?

As I've said earlier in this thread, all NFS clients will flush out the
dirty data if a page that is being attempted read also contains
uninitialised areas.

Trond

