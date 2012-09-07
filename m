Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:47026 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752518Ab2IGONG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Sep 2012 10:13:06 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Dick Streefland <dick.streefland@altium.nl>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: [3.2.5] NFSv3 CLOSE_WAIT hang
Date: Fri, 7 Sep 2012 14:13:04 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA908F8E302@SACEXCMBX04-PRD.hq.netapp.com>
References: <20110909194509.GB6195@hostway.ca>
 <1315610322.17611.112.camel@lade.trondhjem.org>
 <20111020190334.GA22772@hostway.ca> <20120301225524.GB27595@hostway.ca>
 <20120302002511.GA4495@hostway.ca> <20120302184918.GA20702@hostway.ca>
 <loom.20120905T093214-245@post.gmane.org>
 <loom.20120905T093214-245@post.gmane.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA908F86381@SACEXCMBX04-PRD.hq.netapp.com>
 <6cb9.5049fd40.b47c1@altium.nl>
In-Reply-To: <6cb9.5049fd40.b47c1@altium.nl>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> owner@vger.kernel.org] On Behalf Of Dick Streefland
> Sent: Friday, September 07, 2012 9:57 AM
> To: linux-nfs@vger.kernel.org
> Subject: Re: [3.2.5] NFSv3 CLOSE_WAIT hang
> 
> "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> | Clearly the comment is misleading and should be removed. That write
> | lock
> |
> | _is_ needed in order to throttle slots on TCP.
> |
> | As far as I know, kernel 3.3 is not in stable support any more, so I
> | can't help that. Can you reproduce the problem on a 3.5 kernel or
> | higher?
> 
> I can easily reproduce the hang on the latest kernel (eeea3ac912) with my
> script (http://permalink.gmane.org/gmane.linux.nfs/51833).

On TCP?

> With this change, it doesn't hang:

It doesn't matter as long as that change is wrong. That code _is_ needed for TCP.

Now if UDP is broken, then we can talk about a fix for that issue, but that's not going to be the one you propose.

Trond
