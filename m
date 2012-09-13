Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:41857 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752411Ab2IMFWq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Sep 2012 01:22:46 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1TC1t1-0000Yk-Dh
	for linux-nfs@vger.kernel.org; Thu, 13 Sep 2012 07:22:48 +0200
Received: from 59-124-179-67.HINET-IP.hinet.net ([59.124.179.67])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 13 Sep 2012 07:22:47 +0200
Received: from yanpai.chen by 59-124-179-67.HINET-IP.hinet.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 13 Sep 2012 07:22:47 +0200
To: linux-nfs@vger.kernel.org
From: Yan-Pai Chen <yanpai.chen@gmail.com>
Subject: Re: [3.2.5] NFSv3 =?utf-8?b?Q0xPU0VfV0FJVA==?= hang
Date: Thu, 13 Sep 2012 05:22:32 +0000 (UTC)
Message-ID: <loom.20120913T072025-998@post.gmane.org>
References: <loom.20120905T093214-245@post.gmane.org>  <4FA345DA4F4AE44899BD2B03EEEC2FA908F86381@SACEXCMBX04-PRD.hq.netapp.com>  <6cb9.5049fd40.b47c1@altium.nl> <6cb9.5049fd40.b47c1@altium.nl>  <4FA345DA4F4AE44899BD2B03EEEC2FA908F8E302@SACEXCMBX04-PRD.hq.netapp.com>  <447c.504a05c9.dd0a9@altium.nl> <447c.504a05c9.dd0a9@altium.nl>  <4FA345DA4F4AE44899BD2B03EEEC2FA908F8E833@SACEXCMBX04-PRD.hq.netapp.com>  <74c7.504b9d45.a5956@altium.nl> <loom.20120910T105944-416@post.gmane.org>  <20120911194051.GB11160@hostway.ca> <4FA345DA4F4AE44899BD2B03EEEC2FA908F9BDDD@SACEXCMBX04-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Myklebust, Trond <Trond.Myklebust@...> writes:

> > 
> > I suppose we could try 3.5 at this point.
> 
> If you've been keeping up with the 3.2 stable releases, then I wouldn't
> expect any major differences to the sunrpc code, but it might be worth a
> try in case the networking layer has changed.
> 

Hi Trond,

I got the same problem on kernel 3.5 when using TCP mounts.
The hung task info and rpc_debug messages were just the same as what
I got on kernel 3.3.

--
Regards,
Andrew


