Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:39125 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753296AbZFCRKc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Jun 2009 13:10:32 -0400
Subject: Re: Read/Write NFS I/O performance degraded by FLUSH_STABLE page
 flushing
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Carlos Carvalho <carlos@fisica.ufpr.br>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <18982.41770.293636.786518@fisica.ufpr.br>
References: <OF3EBF546E.60A83A8F-ON852575A8.006EBB38-852575A8.006EFDE6@us.ibm.com>
	 <5ECD2205-4DC9-41F1-AC5C-ADFA984745D3@oracle.com>
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
Content-Type: text/plain
Date: Wed, 03 Jun 2009 13:10:27 -0400
Message-Id: <1244049027.5603.5.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2009-06-03 at 13:22 -0300, Carlos Carvalho wrote:
> Trond Myklebust (trond.myklebust@fys.uio.no) wrote on 2 June 2009 13:27:
>  >Write gathering relies on waiting an arbitrary length of time in order
>  >to see if someone is going to send another write. The protocol offers no
>  >guidance as to how long that wait should be, and so (at least on the
>  >Linux server) we've coded in a hard wait of 10ms if and only if we see
>  >that something else has the file open for writing.
>  >One problem with the Linux implementation is that the "something else"
>  >could be another nfs server thread that happens to be in nfsd_write(),
>  >however it could also be another open NFSv4 stateid, or a NLM lock, or a
>  >local process that has the file open for writing.
>  >Another problem is that the nfs server keeps a record of the last file
>  >that was accessed, and also waits if it sees you are writing again to
>  >that same file. Of course it has no idea if this is truly a parallel
>  >write, or if it just happens that you are writing again to the same file
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

