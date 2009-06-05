Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:33019 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754701AbZFENwi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Jun 2009 09:52:38 -0400
Subject: Re: Link performance over NFS degraded in RHEL5. -- was :
 Read/Write NFS I/O performance degraded by FLUSH_STABLE page flushing
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Steve Dickson <SteveD@redhat.com>
Cc: Tom Talpey <tmtalpey@gmail.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
In-Reply-To: <4A291DE3.2070105@RedHat.com>
References: <OF3EBF546E.60A83A8F-ON852575A8.006EBB38-852575A8.006EFDE6@us.ibm.com>
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
	 <OFB53BFCCB.0CEC7A7E-ON852575C <1244138698.5203.59.camel@heimdal.trondhjem.org>
	 <OF37FCED66.33F08949-ON852575CB.006DE109-852575CB.0071CFBD@us.ibm.com>
	 <4A2902E6.2080006@RedHat.com> <4A29144A.6030405@gmail.com>
	 <4A291DE3.2070105@RedHat.com>
Content-Type: text/plain
Date: Fri, 05 Jun 2009 09:52:36 -0400
Message-Id: <1244209956.5410.33.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2009-06-05 at 09:30 -0400, Steve Dickson wrote:
> 
> Tom Talpey wrote:
> > On 6/5/2009 7:35 AM, Steve Dickson wrote:
> >> Brian R Cowan wrote:
> >>> Trond Myklebust<trond.myklebust@fys.uio.no>  wrote on 06/04/2009
> >>> 02:04:58
> >>> PM:
> >>>
> >>>> Did you try turning off write gathering on the server (i.e. add the
> >>>> 'no_wdelay' export option)? As I said earlier, that forces a delay of
> >>>> 10ms per RPC call, which might explain the FILE_SYNC slowness.
> >>> Just tried it, this seems to be a very useful workaround as well. The
> >>> FILE_SYNC write calls come back in about the same amount of time as the
> >>> write+commit pairs... Speeds up building regardless of the network
> >>> filesystem (ClearCase MVFS or straight NFS).
> >>
> >> Does anybody had the history as to why 'no_wdelay' is an
> >> export default?
> > 
> > Because "wdelay" is a complete crock?
> > 
> > Adding 10ms to every write RPC only helps if there's a steady
> > single-file stream arriving at the server. In most other workloads
> > it only slows things down.
> > 
> > The better solution is to continue tuning the clients to issue
> > writes in a more sequential and less all-or-nothing fashion.
> > There are plenty of other less crock-ful things to do in the
> > server, too.
> Ok... So do you think removing it as a default would cause
> any regressions?

It might for NFSv2 clients, since they don't have the option of using
unstable writes. I'd therefore prefer a kernel solution that makes write
gathering an NFSv2 only feature.

Cheers
  Trond

