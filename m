Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from gws05.hcl.com ([203.105.185.23]:47681 "EHLO GWS05.hcl.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751887AbdF0OAx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 27 Jun 2017 10:00:53 -0400
From: Brian Cowan <brian.cowan@hcl.com>
To: "'J. Bruce Fields'" <bfields@fieldses.org>,
        Frank Filz <ffilzlnx@mindspring.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: 2 potentially stupid questions.
Date: Tue, 27 Jun 2017 14:00:47 +0000
Message-ID: <PS1PR04MB1692FA359C22C06AC2FD2B15FEDC0@PS1PR04MB1692.apcprd04.prod.outlook.com>
References: <PS1PR04MB1692ED9241F275897AC5F320FEDB0@PS1PR04MB1692.apcprd04.prod.outlook.com>
 <PS1PR04MB16925A39FB7C41D10CDFAE54FEDB0@PS1PR04MB1692.apcprd04.prod.outlook.com>
 <20170623160602.GC31966@fieldses.org>
 <PS1PR04MB169239A023BD84231758EE09FED90@PS1PR04MB1692.apcprd04.prod.outlook.com>
 <20170626173827.GE30943@fieldses.org>
 <PS1PR04MB1692DC73385ECC045B112334FEDF0@PS1PR04MB1692.apcprd04.prod.outlook.com>
 <20170626221233.GA2186@fieldses.org>,<007e01d2eed3$638534b0$2a8f9e10$@mindspring.com>
 <PS1PR04MB1692E34FE8FEFC1CB28D4F5AFEDC0@PS1PR04MB1692.apcprd04.prod.outlook.com>
In-Reply-To: <PS1PR04MB1692E34FE8FEFC1CB28D4F5AFEDC0@PS1PR04MB1692.apcprd04.prod.outlook.com>
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


RE: nfs-ganesha... Luckily, or unluckily, it's not on the list of supported storage platforms for the product I support. Might be an interesting side project one this one's done. 

________________________________________
From: Frank Filz <mailto:ffilzlnx@mindspring.com>
Sent: Monday, June 26, 2017 7:24:35 PM
To: 'J. Bruce Fields'; Brian Cowan
Cc: mailto:linux-nfs@vger.kernel.org
Subject: RE: 2 potentially stupid questions.
 
Have you added nfs-ganesha to your list of servers?

> -----Original Message-----
> From: mailto:linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> mailto:owner@vger.kernel.org] On Behalf Of J. Bruce Fields
> Sent: Monday, June 26, 2017 3:13 PM
> To: Brian Cowan <mailto:brian.cowan@hcl.com>
> Cc: mailto:linux-nfs@vger.kernel.org
> Subject: Re: 2 potentially stupid questions.
> 
> On Mon, Jun 26, 2017 at 09:09:49PM +0000, Brian Cowan wrote:
> > The "feature implemented only in linux" statement worries me... Does
> > this mean that only Linux's NFS client server implements this NFSv4.1
> > "lock freed" behavior?
> 
> Actually, I shouldn't have said that.  The linux (client and server)
> implementation is the one I know of, but there may well be others.  It's
an
> optional feature of NFSv4.1:
> 
>        https://tools.ietf.org/html/rfc5661#section-20.11
> 
> If you notice 1-second-ish delays acquiring contended locks against other
> servers then it may be worth filing bugs with them and suggesting they
> support CB_NOTIFY_LOCK.  It shouldn't be especially difficult.

Adding that support to nfs-ganesha is on our todo list...

Frank


---
This email has been checked for viruses by Avast antivirus software.
https://www.avast.com/antivirus


::DISCLAIMER::
----------------------------------------------------------------------------------------------------------------------------------------------------

The contents of this e-mail and any attachment(s) are confidential and intended for the named recipient(s) only.
E-mail transmission is not guaranteed to be secure or error-free as information could be intercepted, corrupted,
lost, destroyed, arrive late or incomplete, or may contain viruses in transmission. The e mail and its contents
(with or without referred errors) shall therefore not attach any liability on the originator or HCL or its affiliates.
Views or opinions, if any, presented in this email are solely those of the author and may not necessarily reflect the
views or opinions of HCL or its affiliates. Any form of reproduction, dissemination, copying, disclosure, modification,
distribution and / or publication of this message without the prior written consent of authorized representative of
HCL is strictly prohibited. If you have received this email in error please delete it and notify the sender immediately.
Before opening any email and/or attachments, please check them for viruses and other defects.

----------------------------------------------------------------------------------------------------------------------------------------------------

