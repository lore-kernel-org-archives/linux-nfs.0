Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:37518 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751331AbZFDVjl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Jun 2009 17:39:41 -0400
In-Reply-To: <4A283791.9090505@redhat.com>
References: <OF3EBF546E.60A83A8F-ON852575A8.006EBB38-852575A8.006EFDE6@us.ibm.com>	 <1243615595.7155.48.camel@heimdal.trondhjem.org>
	 <OF0EEDB635.561D17D4-ON852575C5.005CBABA-852575C5.005FAD0D@us.ibm.com>	 <1243618500.7155.56.camel@heimdal.trondhjem.org>
	 <ac442c870905291722x1ec811b2sda997d464898fcda@mail.gmail.com>	 <1243686363.5209.16.camel@heimdal.trondhjem.org>
	 <ac442c870905300602v6950ec42y5195d2d6ea7dd4c@mail.gmail.com>	 <BA67D2A4-1752-4789-ADB9-D1B3C6D197F6@oracle.com>
	 <1243963631.4868.124.camel@heimdal.trondhjem.org>	 <18982.41770.293636.786518@fisica.ufpr.br>
	 <1244049027.5603.5.camel@heimdal.trondhjem.org>	 <OFB53BFCCB.0CEC7A7E-ON852575C
 <1244138698.5203.59.camel@heimdal.trondhjem.org> <OF37FCED66.33F08949-ON852575CB. <4A283791.9090505@redhat.com>
To: Peter Staubach <staubach@redhat.com>
Cc: Carlos Carvalho <carlos@fisica.ufpr.br>, linux-nfs@vger.kernel.org,
        linux-nfs-owner@vger.kernel.org,
        Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Link performance over NFS degraded in RHEL5. -- was : Read/Write NFS I/O
 performance degraded by FLUSH_STABLE page flushing
From: Brian R Cowan <brcowan@us.ibm.com>
Message-ID: <OFB3EB982B.0A57EB3E-ON852575CB.00765190-852575CB.0076FDCC@us.ibm.com>
Date: Thu, 4 Jun 2009 17:39:42 -0400
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Peter Staubach <staubach@redhat.com> wrote on 06/04/2009 05:07:29 PM:

> > What I'm trying to understand is why RHEL 4 is not flushing anywhere 
near 
> > as often. Either RHEL4 erred on the side of not writing, and RHEL5 is 
> > erring on the opposite side, or RHEL5 is doing unnecessary flushes... 
I've 
> > seen that 2.6.29 flushes less than the Red hat 2.6.18-derived kernels, 
but 
> > it still flushes a lot more than RHEL 4 does.
> >
> > 
> 
> I think that you are making a lot of assumptions here, that
> are not necessarily backed by the evidence.  The base cause
> here seems more likely to me to be the setting of PG_uptodate
> being different on the different releases, ie. RHEL-4, RHEL-5,
> and 2.6.29.  All of these kernels contain the support to
> write out pages which are not marked as PG_uptodate.
> 
>        ps
I'm trying to find out why the paging/flushing is happening. It's 
incredibly trivial to reproduce, just link something large over NFS. RHEL4 
writes to the smbd file about 150x, RHEL 5 writes to it > 500x, and 2.6.29 
writes about 340x. I have network traces showing that. I'm now trying to 
understand why... So we an determine if there is anything that can be done 
about it...

Trond's note about a getattr change that went into 2.6.16 may be important 
since we have also seen this slowdown on SuSE 10, which is based on 2.6.16 
kernels. I'm just a little unsure of why the gcc linker would be calling 
getattr... Time to collect more straces, I guess, and then to see what 
happens under the covers... (Be just my luck if the seek eventually causes 
nfs_getattr to be called, though it would certainly explain the behavior.)
