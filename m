Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:50510 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750879Ab3FWTnE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 23 Jun 2013 15:43:04 -0400
Date: Sun, 23 Jun 2013 15:42:50 -0400
From: Jim Rees <rees@umich.edu>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: James <purpleidea@gmail.com>, Chuck Lever <chuck.lever@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFS clientaddr, kerberos
Message-ID: <20130623194250.GA11422@umich.edu>
References: <1371913167.28295.8.camel@freed.purpleidea.com>
 <E910FB58-8E56-4E96-A197-B25084B135BD@oracle.com>
 <1371926549.9337.7.camel@leira.trondhjem.org>
 <1372001734.28295.15.camel@freed.purpleidea.com>
 <1372002787.3799.2.camel@leira.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1372002787.3799.2.camel@leira.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Myklebust, Trond wrote:

  > > 	echo "options nfs callback_tcpport=<port>" >>/etc/modprobe.d/options-local.conf
  > This is very useful to know.
  > Is there any way to specify this as a mount option?
  
  No. The NFSv4 callback channel port number is a global property. It does
  not want to be a per-mount thing.

Would it make sense as a sysctl? I can sort of imagine cases where this
might be useful. Not that I'm volunteering to implement it.
