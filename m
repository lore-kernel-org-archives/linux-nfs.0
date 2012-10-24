Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f46.google.com ([209.85.212.46]:42117 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933678Ab2JXUT2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Oct 2012 16:19:28 -0400
Received: by mail-vb0-f46.google.com with SMTP id ff1so1036917vbb.19
        for <linux-nfs@vger.kernel.org>; Wed, 24 Oct 2012 13:19:27 -0700 (PDT)
Date: Wed, 24 Oct 2012 16:19:23 -0400
From: Chris Perl <chris.perl@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: RPC Race Condition
Message-ID: <20121024201923.GG27191@nyc-qws-132.nyc.delacy.com>
References: <4FA345DA4F4AE44899BD2B03EEEC2FA90928AB39@SACEXCMBX04-PRD.hq.netapp.com>
 <20121023134551.GB27191@nyc-qws-132.nyc.delacy.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA90928C74A@SACEXCMBX04-PRD.hq.netapp.com>
 <20121023200855.GC27191@nyc-qws-132.nyc.delacy.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA90928DCDD@SACEXCMBX04-PRD.hq.netapp.com>
 <20121024124047.GD27191@nyc-qws-132.nyc.delacy.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA90928F571@SACEXCMBX04-PRD.hq.netapp.com>
 <20121024142333.GE27191@nyc-qws-132.nyc.delacy.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA90928F920@SACEXCMBX04-PRD.hq.netapp.com>
 <20121024161004.GF27191@nyc-qws-132.nyc.delacy.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121024161004.GF27191@nyc-qws-132.nyc.delacy.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 24, 2012 at 12:10:04PM -0400, Chris Perl wrote:
> On Wed, Oct 24, 2012 at 02:56:55PM +0000, Myklebust, Trond wrote:
> > OK, I've now posted the patches in the "bugfixes" branch of
> > 
> >        git://git.linux-nfs.org/projects/trondmy/linux-nfs.git
> 
> Cool, I'll try to get that pulled, compiled and tested by the end of the
> day.

Pulled, compiled and tested in the same manner described before without
problems.

Thanks for getting this resolved!

Chris
