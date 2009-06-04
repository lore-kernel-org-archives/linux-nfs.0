Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:47048 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751457AbZFDRmP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Jun 2009 13:42:15 -0400
In-Reply-To: <1244049027.5603.5.camel@heimdal.trondhjem.org>
References: <OF3EBF546E.60A83A8F-ON852575A8.006EBB38-852575A8.006EFDE6@us.ibm.com>	 <49FA0CE8.9090706@redhat.com>
	 <1241126587.15476.62.camel@heimdal.trondhjem.org>	 <OF820C8732.74757E21-ON852575C5.0055C089-852575C5.00578071@us.ibm.com>
	 <1243615595.7155.48.camel@heimdal.trondhjem.org>	 <OF0EEDB635.561D17D4-ON852575C5.005CBABA-852575C5.005FAD0D@us.ibm.com>
	 <1243618500.7155.56.camel@heimdal.trondhjem.org>	 <ac442c870905291722x1ec811b2sda997d464898fcda@mail.gmail.com>
	 <1243686363.5209.16.camel@heimdal.trondhjem.org>	 <ac442c870905300602v6950ec42y5195d2d6ea7dd4c@mail.gmail.com>
	 <BA67D2A4-1752-4789-ADB9-D1B3C6D197F6@oracle.com>	 <1243963631.4868.124.camel@heimdal.trondhjem.org>
	 <18982.41770.293636.786518@fisica.ufpr.br> <1244049027.5603.5.camel@heimdal.trondhjem.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Carlos Carvalho <carlos@fisica.ufpr.br>, linux-nfs@vger.kernel.org,
        linux-nfs-owner@vger.kernel.org
Subject: Re: Read/Write NFS I/O performance degraded by FLUSH_STABLE page flushing
From: Brian R Cowan <brcowan@us.ibm.com>
Message-ID: <OFB53BFCCB.0CEC7A7E-ON852575CA.006BA196-852575CB.00613ABC@us.ibm.com>
Date: Thu, 4 Jun 2009 13:42:00 -0400
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I've been looking in more detail in the network traces that started all 
this, and doing some additional testing with the 2.6.29 kernel in an 
NFS-only build...

In brief:
1) RHEL 5 generates >3x the network write traffic than RHEL4 when linking 
Samba's smbd.
2) In RHEL 5, Those unnecessary writes are slowed down by the "FILE_SYNC" 
optimization put in place for small writes.
3) That optimization seems to be removed from the kernel somewhere between 
2.6.18 and 2.6.29.
4) Unfortunately the "unnecessary write before read" behavior is still 
present in 2.6.29.

In detail:
In RHEL 5, I see a lot of reads from offset {whatever} *immediately* 
preceded by a write to *the same offset*. This is obviously a bad thing, 
now the trick is finding out where it is coming from. The 
write-before-read behavior is happening on the smbd file itself (not 
surprising since that's the only file we're writing in this test...). This 
happens with every 2.6.18 and later kernel I've tested to date.

In RHEL 5, most of the writes are FILE_SYNC writes, which appear to take 
something on the order of 10ms to come back. When using a 2.6.29 kernel, 
the TOTAL time for the write+commit rpc set (write rpc, write reply, 
commit rpc, commit reply), to come back is something like 2ms. I guess the 
NFS servers aren't handling FILE_SYNC writes very well. in 2.6.29, ALL the 
write calls appear to be unstable writes, in RHEL5, most are FILE_SYNC 
writes. (Network traces available upon request.)

Neither is quite as fast as RHEL 4, because the link under RHEL 4 only 
puts about 150 WRITE rpc's on the wire. RHEL 5 generates more than 500 
when building on NFS, and 2.6.29 puts about 340 write rpc's, plus a 
similar number of COMMITs, on the wire. 

The bottom line:
* If someone can help me find where 2.6 stopped setting small writes to 
FILE_SYNC, I'd appreciate it. It would save me time walking through >50 
commitdiffs in gitweb...
* Is this the correct place to start discussing the annoying 
write-before-almost-every-read behavior that 2.6.18 picked up and 2.6.29 
continues? 

=================================================================
Brian Cowan
Advisory Software Engineer
ClearCase Customer Advocacy Group (CAG)
Rational Software
IBM Software Group
81 Hartwell Ave
Lexington, MA
 
Phone: 1.781.372.3580
Web: http://www.ibm.com/software/rational/support/
 

Please be sure to update your PMR using ESR at 
http://www-306.ibm.com/software/support/probsub.html or cc all 
correspondence to sw_support@us.ibm.com to be sure your PMR is updated in 
case I am not available.



From:
Trond Myklebust <trond.myklebust@fys.uio.no>
To:
Carlos Carvalho <carlos@fisica.ufpr.br>
Cc:
linux-nfs@vger.kernel.org
Date:
06/03/2009 01:10 PM
Subject:
Re: Read/Write NFS I/O performance degraded by FLUSH_STABLE page flushing
Sent by:
linux-nfs-owner@vger.kernel.org



On Wed, 2009-06-03 at 13:22 -0300, Carlos Carvalho wrote:
> Trond Myklebust (trond.myklebust@fys.uio.no) wrote on 2 June 2009 13:27:
>  >Write gathering relies on waiting an arbitrary length of time in order
>  >to see if someone is going to send another write. The protocol offers 
no
>  >guidance as to how long that wait should be, and so (at least on the
>  >Linux server) we've coded in a hard wait of 10ms if and only if we see
>  >that something else has the file open for writing.
>  >One problem with the Linux implementation is that the "something else"
>  >could be another nfs server thread that happens to be in nfsd_write(),
>  >however it could also be another open NFSv4 stateid, or a NLM lock, or 
a
>  >local process that has the file open for writing.
>  >Another problem is that the nfs server keeps a record of the last file
>  >that was accessed, and also waits if it sees you are writing again to
>  >that same file. Of course it has no idea if this is truly a parallel
>  >write, or if it just happens that you are writing again to the same 
file
>  >using O_SYNC...
> 
> I think the decision to write or wait doesn't belong to the nfs
> server; it should just send the writes immediately. It's up to the
> fs/block/device layers to do the gathering. I understand that the
> client should try to do the gathering before sending the request to
> the wire

This isn't something that we've just pulled out of a hat. It dates back
to pre-NFSv3 times, when every write had to be synchronously committed
to disk before the RPC call could return.

See, for instance,

http://books.google.com/books?id=y9GgPhjyOUwC&pg=PA243&lpg=PA243&dq=What
+is+nfs+write
+gathering&source=bl&ots=M8s0XS2SLd&sig=ctmxQrpII2_Ti4czgpGZrF9mmds&hl=en&ei=Xa0mSrLMC8iptgfSsqHsBg&sa=X&oi=book_result&ct=result&resnum=3

The point is that while it is a good idea for NFSv2, we have much better
methods of dealing with multiple writes in NFSv3 and v4...

Trond

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html


