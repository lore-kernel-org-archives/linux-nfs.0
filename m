Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:52651 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751354Ab3FWPxL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 23 Jun 2013 11:53:11 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: James <purpleidea@gmail.com>
CC: Chuck Lever <chuck.lever@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFS clientaddr, kerberos
Date: Sun, 23 Jun 2013 15:53:09 +0000
Message-ID: <1372002787.3799.2.camel@leira.trondhjem.org>
References: <1371913167.28295.8.camel@freed.purpleidea.com>
	 <E910FB58-8E56-4E96-A197-B25084B135BD@oracle.com>
	 <1371926549.9337.7.camel@leira.trondhjem.org>
	 <1372001734.28295.15.camel@freed.purpleidea.com>
In-Reply-To: <1372001734.28295.15.camel@freed.purpleidea.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2013-06-23 at 11:35 -0400, James wrote:
> On Sat, 2013-06-22 at 18:42 +0000, Myklebust, Trond wrote:
> > 
> > Kernel parameters cannot be per-namespace; containers don't boot a
> > separate kernel.
> > 
> > Note that if you have compiled nfs as a module, you will want to do
> > something along the lines of:
> > 
> > 	echo "options nfs callback_tcpport=<port>" >>/etc/modprobe.d/options-local.conf
> This is very useful to know.
> Is there any way to specify this as a mount option?

No. The NFSv4 callback channel port number is a global property. It does
not want to be a per-mount thing.

> Will NFSv4.1 silently ignore this and use the same RPC connection if I
> include it for both 4.0, and 4.1 machines?

Yes.


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
