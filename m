Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from gws08.hcl.com ([192.8.186.131]:35150 "EHLO GWS08.hcl.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754075AbdFXAm3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 23 Jun 2017 20:42:29 -0400
From: Brian Cowan <brian.cowan@hcl.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: 2 potentially stupid questions.
Date: Sat, 24 Jun 2017 00:42:22 +0000
Message-ID: <PS1PR04MB169239A023BD84231758EE09FED90@PS1PR04MB1692.apcprd04.prod.outlook.com>
References: <PS1PR04MB1692ED9241F275897AC5F320FEDB0@PS1PR04MB1692.apcprd04.prod.outlook.com>
 <PS1PR04MB16925A39FB7C41D10CDFAE54FEDB0@PS1PR04MB1692.apcprd04.prod.outlook.com>
 <20170623160602.GC31966@fieldses.org>
In-Reply-To: <20170623160602.GC31966@fieldses.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Well, I'm trying to avoid having to test against 2 filers (Netapp and emc), at least 2 versions of each of 3 linux distributions (Red Hat 6.x and 7.x, SuSE 11 and 12, ubuntu 12, 14, and 16) and Solaris 11 (Sparc and x86) as servers, against each of those Unix OS's as clients. Right about now I'm happy I don't need to test using WINDOWS NFS client/server products, because so few of those work consistently even inside the same major version.a complete test could trference as many as 99 client/server combinations. Given that a single test run takes just over an hour and a half for data collection... And my first attempt at data analysis took longer (need to write a script to process the log files into a summary instead of importing 20 400,000 line TSV files into excel). 

My hope was that we someone could say that "x" was the server "reference" implementation. IOW, if the server didn't act like "x" (which used to be "Solaris" back in the day) it was arguable that the server was defective.

At least some of the 4.9 changes are getting backported to 3.10 kernels, at least for Red Hat 7. Since the RH Bugzilla doesn't talk about RH 6.x, I can remove it from consideration, but if I don't test, and test across client/server releases, I don't think anyone will, at which time we wind up playing distro roulette.  

As it stands, I saw some odd behavior in the RH 7.4 beta that I may need to reproduce in 4.9... Apparently something is allergic to odd numbers in redhat's version of the NFSv4.1 client/server. I get odd peaks in the maximum lockf call time when there is an odd number of lockers. We're talking maximum times >10,000x the mean lock time. 

If someone else wants to verify the odd findings I can post my c source and the script file to run the 1-20-locker tests.

-----Original Message-----
From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of J. Bruce Fields
Sent: Friday, June 23, 2017 12:06 PM
To: Brian Cowan <brian.cowan@hcl.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: 2 potentially stupid questions.

On Thu, Jun 22, 2017 at 06:51:05PM +0000, Brian Cowan wrote:
> I need to do some stress testing the product I support accessing 
> storage over NFS v4.1 and compare the performance with NFSv3 (with its 
> lovely NLM) and NFSv4 (with its fun integral client lock retry 
> interval). This brings me to the 2 potentially stupid questions:
> 
> 1) Is there a "gold standard" server? I know that the "de facto 
> standard" is usually Solaris, but I'm looking for a something like a 
> "least common denominator" NFS v4.1 server implementation. I'm trying 
> to avoid "test this client [red hat 7.4 snapshot 3 ATM] with this 
> half-dozen servers and see what happens on each" kind of tests since 
> that seriously muddies the waters. Especially since I will need to 
> test Ubuntu 14/16, SuSE 11 & 12, CentOS, etc., clients.

I don't think so.  But I'm not sure I understand what you're looking for.  The server your users are most likely to use?  The server likely to perform best in your test?  The server most likely to expose corner cases or bugs in your product?  But I'm afraid I wouldn't know the answers to any of those questions....

> 2) Is there a simple way to set the maximum NFS version on a 
> PER-EXPORT basis on a single server. The "exports" man page is mum on 
> the subject. I'm getting around this by explicitly mounting my 
> "control" (NFSv3) export as NFSv3, but if there is a way to set a max 
> protocol version on the EXPORT, that would simplify testing since I 
> could just use autofs. Yes, I can enable use of, and then tweak, 
> /etc/auto.net to do this, but I'm trying to do the fiddling in just 
> one place as I know that I'll need to do these tests for other Linux 
> distros. Especially since it seems autofs is somewhat twitchy when 
> using /net mounts (sometimes -hosts works, sometimes it doesn't, 
> sometimes using the auto.net file works, other times it doesn't).

On the client side, /etc/nfs.conf can set per-mount protocol version preferences.

On the server side, there's no per-export setting.  I don't think that would really work--protocol versions are negotiated before the client even gets around to looking at a particular export.  You can set supported versions globally with options to rpc.nfsd (see man rpc.nfsd) and in Fedora you'd set those in /etc/sysconfig/nfs.

> Thanks for any hints.
> 
> Bruce, this is the issue where lock contention on NFSv4 would cause 
> lockers on the same machine to go asleep for integral #'s of seconds.

I've forgotten the report, apologies, but that sort of problem should in theory be fixed with changes in 4.9 by Jeff Layton that allow the server to notify clients when contended locks are unlocked.

--b.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in the body of a message to majordomo@vger.kernel.org More majordomo info at  http://vger.kernel.org/majordomo-info.html


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

