Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:40958 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753447AbdFWQGD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 23 Jun 2017 12:06:03 -0400
Date: Fri, 23 Jun 2017 12:06:02 -0400
To: Brian Cowan <brian.cowan@hcl.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: 2 potentially stupid questions.
Message-ID: <20170623160602.GC31966@fieldses.org>
References: <PS1PR04MB1692ED9241F275897AC5F320FEDB0@PS1PR04MB1692.apcprd04.prod.outlook.com>
 <PS1PR04MB16925A39FB7C41D10CDFAE54FEDB0@PS1PR04MB1692.apcprd04.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <PS1PR04MB16925A39FB7C41D10CDFAE54FEDB0@PS1PR04MB1692.apcprd04.prod.outlook.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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

I don't think so.  But I'm not sure I understand what you're looking
for.  The server your users are most likely to use?  The server likely
to perform best in your test?  The server most likely to expose corner
cases or bugs in your product?  But I'm afraid I wouldn't know the
answers to any of those questions....

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

On the client side, /etc/nfs.conf can set per-mount protocol version
preferences.

On the server side, there's no per-export setting.  I don't think that
would really work--protocol versions are negotiated before the client
even gets around to looking at a particular export.  You can set
supported versions globally with options to rpc.nfsd (see man rpc.nfsd)
and in Fedora you'd set those in /etc/sysconfig/nfs.

> Thanks for any hints.
> 
> Bruce, this is the issue where lock contention on NFSv4 would cause
> lockers on the same machine to go asleep for integral #'s of seconds. 

I've forgotten the report, apologies, but that sort of problem should in
theory be fixed with changes in 4.9 by Jeff Layton that allow the server
to notify clients when contended locks are unlocked.

--b.
