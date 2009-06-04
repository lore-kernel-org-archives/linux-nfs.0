Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:52563 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751151AbZFDU50 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Jun 2009 16:57:26 -0400
Subject: Re: Link performance over NFS degraded in RHEL5. -- was :
 Read/Write NFS I/O performance degraded by FLUSH_STABLE page flushing
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Brian R Cowan <brcowan@us.ibm.com>
Cc: Carlos Carvalho <carlos@fisica.ufpr.br>, linux-nfs@vger.kernel.org,
        linux-nfs-owner@vger.kernel.org
In-Reply-To: <OF37FCED66.33F08949-ON852575CB.006DE109-852575CB.0071CFBD@us.ibm.com>
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
Content-Type: text/plain
Date: Thu, 04 Jun 2009 16:57:22 -0400
Message-Id: <1244149042.5203.108.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2009-06-04 at 16:43 -0400, Brian R Cowan wrote:
> What I'm trying to understand is why RHEL 4 is not flushing anywhere near 
> as often. Either RHEL4 erred on the side of not writing, and RHEL5 is 
> erring on the opposite side, or RHEL5 is doing unnecessary flushes... I've 
> seen that 2.6.29 flushes less than the Red hat 2.6.18-derived kernels, but 
> it still flushes a lot more than RHEL 4 does.

Most of that increase is probably mainly due to the changes to the way
stat() works. More precisely, it would be due to this patch:

   http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git&a=commitdiff&h=70b9ecbdb9c5fdc731f8780bffd45d9519020c4a

which went into Linux 2.6.16 in order to fix a posix compatibility
issue.

Trond

