Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from elasmtp-kukur.atl.sa.earthlink.net ([209.86.89.65]:40262 "EHLO
        elasmtp-kukur.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751456AbdF0AY4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Jun 2017 20:24:56 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'J. Bruce Fields'" <bfields@fieldses.org>,
        "'Brian Cowan'" <brian.cowan@hcl.com>
Cc: <linux-nfs@vger.kernel.org>
References: <PS1PR04MB1692ED9241F275897AC5F320FEDB0@PS1PR04MB1692.apcprd04.prod.outlook.com> <PS1PR04MB16925A39FB7C41D10CDFAE54FEDB0@PS1PR04MB1692.apcprd04.prod.outlook.com> <20170623160602.GC31966@fieldses.org> <PS1PR04MB169239A023BD84231758EE09FED90@PS1PR04MB1692.apcprd04.prod.outlook.com> <20170626173827.GE30943@fieldses.org> <PS1PR04MB1692DC73385ECC045B112334FEDF0@PS1PR04MB1692.apcprd04.prod.outlook.com> <20170626221233.GA2186@fieldses.org>
In-Reply-To: <20170626221233.GA2186@fieldses.org>
Subject: RE: 2 potentially stupid questions.
Date: Mon, 26 Jun 2017 16:24:35 -0700
Message-ID: <007e01d2eed3$638534b0$2a8f9e10$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
        charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Have you added nfs-ganesha to your list of servers?

> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> owner@vger.kernel.org] On Behalf Of J. Bruce Fields
> Sent: Monday, June 26, 2017 3:13 PM
> To: Brian Cowan <brian.cowan@hcl.com>
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: 2 potentially stupid questions.
> 
> On Mon, Jun 26, 2017 at 09:09:49PM +0000, Brian Cowan wrote:
> > The "feature implemented only in linux" statement worries me... Does
> > this mean that only Linux's NFS client server implements this NFSv4.1
> > "lock freed" behavior?
> 
> Actually, I shouldn't have said that.  The linux (client and server)
> implementation is the one I know of, but there may well be others.  It's
an
> optional feature of NFSv4.1:
> 
> 	https://tools.ietf.org/html/rfc5661#section-20.11
> 
> If you notice 1-second-ish delays acquiring contended locks against other
> servers then it may be worth filing bugs with them and suggesting they
> support CB_NOTIFY_LOCK.  It shouldn't be especially difficult.

Adding that support to nfs-ganesha is on our todo list...

Frank


---
This email has been checked for viruses by Avast antivirus software.
https://www.avast.com/antivirus

