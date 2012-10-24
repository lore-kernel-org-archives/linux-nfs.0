Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:44994 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932176Ab2JXNES convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Oct 2012 09:04:18 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Chris Perl <chris.perl@gmail.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: RPC Race Condition
Date: Wed, 24 Oct 2012 13:04:16 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA90928F571@SACEXCMBX04-PRD.hq.netapp.com>
References: <20121022180339.GC24763@nyc-qws-132.nyc.delacy.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA909289403@SACEXCMBX04-PRD.hq.netapp.com>
 <20121022202611.GA27191@nyc-qws-132.nyc.delacy.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA90928AB39@SACEXCMBX04-PRD.hq.netapp.com>
 <20121023134551.GB27191@nyc-qws-132.nyc.delacy.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA90928C74A@SACEXCMBX04-PRD.hq.netapp.com>
 <20121023200855.GC27191@nyc-qws-132.nyc.delacy.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA90928DCDD@SACEXCMBX04-PRD.hq.netapp.com>
 <20121024124047.GD27191@nyc-qws-132.nyc.delacy.com>
In-Reply-To: <20121024124047.GD27191@nyc-qws-132.nyc.delacy.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> owner@vger.kernel.org] On Behalf Of Chris Perl
> Sent: Wednesday, October 24, 2012 8:41 AM
> To: Myklebust, Trond
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: RPC Race Condition
> 
> On Tue, Oct 23, 2012 at 09:58:35PM +0000, Myklebust, Trond wrote:
> > The only problem there would be the call to xs_sock_mark_closed() in
> > xs_abort_connection. As far as I can tell, all we want to do there is
> > clear all those flags.
> >
> > How about the following?
> 
> Looks good!  With all 4 patches applied things recover correctly and I no
> longer see anything racing.
> 
> Just to be clear, I took your patches and integrated them into the CentOS
> 2.6.32-279.5.2.el6.centos.plus kernel.  Basically everything was the same
> except the offsets and perhaps a little of the surrounding context.  I do not
> believe the meaning of the patches was changed at all.

Cool! Would you mind if I add "Tested-by" tags?

> If you want me to test your latest git where these commits live, I can, just
> point me at the git repo url.

Sure. I'll let you know as soon as I push them out later today...

Thanks!
   Trond
