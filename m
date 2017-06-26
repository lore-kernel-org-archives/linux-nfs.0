Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:46062 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751782AbdFZRi2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 26 Jun 2017 13:38:28 -0400
Date: Mon, 26 Jun 2017 13:38:27 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Brian Cowan <brian.cowan@hcl.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: 2 potentially stupid questions.
Message-ID: <20170626173827.GE30943@fieldses.org>
References: <PS1PR04MB1692ED9241F275897AC5F320FEDB0@PS1PR04MB1692.apcprd04.prod.outlook.com>
 <PS1PR04MB16925A39FB7C41D10CDFAE54FEDB0@PS1PR04MB1692.apcprd04.prod.outlook.com>
 <20170623160602.GC31966@fieldses.org>
 <PS1PR04MB169239A023BD84231758EE09FED90@PS1PR04MB1692.apcprd04.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <PS1PR04MB169239A023BD84231758EE09FED90@PS1PR04MB1692.apcprd04.prod.outlook.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jun 24, 2017 at 12:42:22AM +0000, Brian Cowan wrote:
> Well, I'm trying to avoid having to test against 2 filers (Netapp and
> emc), at least 2 versions of each of 3 linux distributions (Red Hat
> 6.x and 7.x, SuSE 11 and 12, ubuntu 12, 14, and 16) and Solaris 11
> (Sparc and x86) as servers, against each of those Unix OS's as
> clients. Right about now I'm happy I don't need to test using WINDOWS
> NFS client/server products, because so few of those work consistently
> even inside the same major version.a complete test could trference as
> many as 99 client/server combinations. Given that a single test run
> takes just over an hour and a half for data collection... And my first
> attempt at data analysis took longer (need to write a script to
> process the log files into a summary instead of importing 20 400,000
> line TSV files into excel). 
> 
> My hope was that we someone could say that "x" was the server
> "reference" implementation. IOW, if the server didn't act like "x"
> (which used to be "Solaris" back in the day) it was arguable that the
> server was defective.

I don't think there's such a shortcut, sorry.

In the Linux case, if possible, testing on upstream code (on Fedora or a
similar relatively fast-to-update distro) is always helpful, as it helps
catch problems early.

> As it stands, I saw some odd behavior in the RH 7.4 beta that I may
> need to reproduce in 4.9... Apparently something is allergic to odd
> numbers in redhat's version of the NFSv4.1 client/server. I get odd
> peaks in the maximum lockf call time when there is an odd number of
> lockers. We're talking maximum times >10,000x the mean lock time. 

I was about to say we have a bug opened for that and realized you're
probably the reporter--sorry, I didn't make the connection.  Yes, we're
looking into that.  It uses a feature that I believe is so far only
implemented in Linux, which would explain why you'd need recent client
and server to hit it, and it's probably reproduceable with upstream too.

--b.
