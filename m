Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:52939 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752053AbZFENy5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Jun 2009 09:54:57 -0400
Subject: Re: Link performance over NFS degraded in RHEL5. -- was :
 Read/Write NFS I/O performance degraded by FLUSH_STABLE page flushing
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Tom Talpey <tmtalpey@gmail.com>
Cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
In-Reply-To: <4A2922A5.5070101@gmail.com>
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
	 <4A291D83.1000508@RedHat.com>  <4A2922A5.5070101@gmail.com>
Content-Type: text/plain
Date: Fri, 05 Jun 2009 09:54:56 -0400
Message-Id: <1244210096.5410.35.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2009-06-05 at 09:50 -0400, Tom Talpey wrote:
> I'm not 100% clear on what you mean by removing it. Since it's
> a "no_" option, removing it means that "wdelay" becomes the
> default? That would certainly cause a regression for many.

You've misunderstood. The current default is to _set_ 'wdelay' on all
exports that do not explicitly turn it off.

Trond

