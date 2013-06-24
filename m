Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:31443 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751952Ab3FXNhS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Jun 2013 09:37:18 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Jim Rees <rees@umich.edu>
CC: James <purpleidea@gmail.com>, Chuck Lever <chuck.lever@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: NFS clientaddr, kerberos
Date: Mon, 24 Jun 2013 13:37:17 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA93F43248B@SACEXCMBX04-PRD.hq.netapp.com>
References: <1371913167.28295.8.camel@freed.purpleidea.com>
 <E910FB58-8E56-4E96-A197-B25084B135BD@oracle.com>
 <1371926549.9337.7.camel@leira.trondhjem.org>
 <1372001734.28295.15.camel@freed.purpleidea.com>
 <1372002787.3799.2.camel@leira.trondhjem.org>
 <20130623194250.GA11422@umich.edu>
In-Reply-To: <20130623194250.GA11422@umich.edu>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> owner@vger.kernel.org] On Behalf Of Jim Rees
> Sent: Sunday, June 23, 2013 3:43 PM
> To: Myklebust, Trond
> Cc: James; Chuck Lever; linux-nfs@vger.kernel.org
> Subject: Re: NFS clientaddr, kerberos
> 
> Myklebust, Trond wrote:
> 
>   > > 	echo "options nfs callback_tcpport=<port>"
> >>/etc/modprobe.d/options-local.conf
>   > This is very useful to know.
>   > Is there any way to specify this as a mount option?
> 
>   No. The NFSv4 callback channel port number is a global property. It does
>   not want to be a per-mount thing.
> 
> Would it make sense as a sysctl? I can sort of imagine cases where this might
> be useful. Not that I'm volunteering to implement it.

Hi Jim,

With the sysfs interface to kernel parameters, there is little advantage in implementing a sysctl.
Since this is a writeable kernel parameter, it means that you can also change it via the pseudofile in /sys/module/nfs/parameters/callback_tcpport after the module has been loaded (but you still need to do so before mounting any NFSv4 volumes).

Cheers
  Trond
