Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:46444 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751381AbdFZWMe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 26 Jun 2017 18:12:34 -0400
Date: Mon, 26 Jun 2017 18:12:33 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Brian Cowan <brian.cowan@hcl.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: 2 potentially stupid questions.
Message-ID: <20170626221233.GA2186@fieldses.org>
References: <PS1PR04MB1692ED9241F275897AC5F320FEDB0@PS1PR04MB1692.apcprd04.prod.outlook.com>
 <PS1PR04MB16925A39FB7C41D10CDFAE54FEDB0@PS1PR04MB1692.apcprd04.prod.outlook.com>
 <20170623160602.GC31966@fieldses.org>
 <PS1PR04MB169239A023BD84231758EE09FED90@PS1PR04MB1692.apcprd04.prod.outlook.com>
 <20170626173827.GE30943@fieldses.org>
 <PS1PR04MB1692DC73385ECC045B112334FEDF0@PS1PR04MB1692.apcprd04.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <PS1PR04MB1692DC73385ECC045B112334FEDF0@PS1PR04MB1692.apcprd04.prod.outlook.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 26, 2017 at 09:09:49PM +0000, Brian Cowan wrote:
> The "feature implemented only in linux" statement worries me... Does
> this mean that only Linux's NFS client server implements this NFSv4.1
> "lock freed" behavior?

Actually, I shouldn't have said that.  The linux (client and server)
implementation is the one I know of, but there may well be others.  It's
an optional feature of NFSv4.1:

	https://tools.ietf.org/html/rfc5661#section-20.11

If you notice 1-second-ish delays acquiring contended locks against
other servers then it may be worth filing bugs with them and suggesting
they support CB_NOTIFY_LOCK.  It shouldn't be especially difficult.

--b.


> 
> -----Original Message-----
> From: J. Bruce Fields [mailto:bfields@fieldses.org] 
> Sent: Monday, June 26, 2017 1:38 PM
> To: Brian Cowan <brian.cowan@hcl.com>
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: 2 potentially stupid questions.
> 
> On Sat, Jun 24, 2017 at 12:42:22AM +0000, Brian Cowan wrote:
> > Well, I'm trying to avoid having to test against 2 filers (Netapp and 
> > emc), at least 2 versions of each of 3 linux distributions (Red Hat 
> > 6.x and 7.x, SuSE 11 and 12, ubuntu 12, 14, and 16) and Solaris 11 
> > (Sparc and x86) as servers, against each of those Unix OS's as 
> > clients. Right about now I'm happy I don't need to test using WINDOWS 
> > NFS client/server products, because so few of those work consistently 
> > even inside the same major version.a complete test could trference as 
> > many as 99 client/server combinations. Given that a single test run 
> > takes just over an hour and a half for data collection... And my first 
> > attempt at data analysis took longer (need to write a script to 
> > process the log files into a summary instead of importing 20 400,000 
> > line TSV files into excel).
> > 
> > My hope was that we someone could say that "x" was the server 
> > "reference" implementation. IOW, if the server didn't act like "x"
> > (which used to be "Solaris" back in the day) it was arguable that the 
> > server was defective.
> 
> I don't think there's such a shortcut, sorry.
> 
> In the Linux case, if possible, testing on upstream code (on Fedora or a similar relatively fast-to-update distro) is always helpful, as it helps catch problems early.
> 
> > As it stands, I saw some odd behavior in the RH 7.4 beta that I may 
> > need to reproduce in 4.9... Apparently something is allergic to odd 
> > numbers in redhat's version of the NFSv4.1 client/server. I get odd 
> > peaks in the maximum lockf call time when there is an odd number of 
> > lockers. We're talking maximum times >10,000x the mean lock time.
> 
> I was about to say we have a bug opened for that and realized you're probably the reporter--sorry, I didn't make the connection.  Yes, we're looking into that.  It uses a feature that I believe is so far only implemented in Linux, which would explain why you'd need recent client and server to hit it, and it's probably reproduceable with upstream too.
> 
> --b.
> 
> 
> ::DISCLAIMER::
> ----------------------------------------------------------------------------------------------------------------------------------------------------
> 
> The contents of this e-mail and any attachment(s) are confidential and intended for the named recipient(s) only.
> E-mail transmission is not guaranteed to be secure or error-free as information could be intercepted, corrupted,
> lost, destroyed, arrive late or incomplete, or may contain viruses in transmission. The e mail and its contents
> (with or without referred errors) shall therefore not attach any liability on the originator or HCL or its affiliates.
> Views or opinions, if any, presented in this email are solely those of the author and may not necessarily reflect the
> views or opinions of HCL or its affiliates. Any form of reproduction, dissemination, copying, disclosure, modification,
> distribution and / or publication of this message without the prior written consent of authorized representative of
> HCL is strictly prohibited. If you have received this email in error please delete it and notify the sender immediately.
> Before opening any email and/or attachments, please check them for viruses and other defects.
> 
> ----------------------------------------------------------------------------------------------------------------------------------------------------
