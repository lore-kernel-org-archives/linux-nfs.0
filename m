Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from hoggar.fisica.ufpr.br ([200.238.171.242]:36254 "EHLO
        hoggar.fisica.ufpr.br" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755085AbcHXPB4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Aug 2016 11:01:56 -0400
Date: Wed, 24 Aug 2016 12:01:51 -0300
From: Carlos Carvalho <carlos@fisica.ufpr.br>
To: linux-nfs@vger.kernel.org
Subject: Re: crashes in 4.6.5
Message-ID: <20160824150151.3ps3g3iv7rttkhwd@fisica.ufpr.br>
References: <20160804203612.xqzevnqyzkfxwfv3@fisica.ufpr.br>
 <20160824134020.GE3938@fieldses.org>
 <20160824135725.5fcto7cy34zqhwsl@fisica.ufpr.br>
 <20160824144300.GI3938@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20160824144300.GI3938@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields (bfields@fieldses.org) wrote on Wed, Aug 24, 2016 at 11:43:00AM BRT:
> On Wed, Aug 24, 2016 at 10:57:26AM -0300, Carlos Carvalho wrote:
> > The latest one, 4.7.2 in a nfs3-only
> > machine that I reported yesterday, just outputs a few lines with rcu_sched
> > stall warnings, only to the console and nothing in logs. I didn't write them
> > down this time. The machine still reacted to SysRq commands; I used a forced
> > umount and then an immediate reboot. However there was still non-negligible
> > filesystem corruption...
> 
> What kind of filesystem corruption, and what filesystem is this?  I'm a
> little surprised that what looks like a crash in NFSv4 state code should
> be corrupting the filesystem.

I think that what corrupted the filesystem is the unclean reboot. I typed
Alt+SysRq+u, waited for the prompt and then typed Alt+SysRq+b. Apparently the
Alt+SysRq+u didn't properly flush to the disks. I only mentioned the corruption
to show that the machine was really frozen.

Also note that this happened on a nfs3-only machine, running 4.7.2, and the
ONLY message, in the console only, was the rcu_sched stall warning. This is my
second report; the first one was about another machine, which does both nf3 and
nfs4+kerberos and was running 4.6.5 at the moment. That machine shows both the
rcu_sched stalls and general protection fault. We tried many 4.* versions and
they all crash in the same way. Now it's been running 3.16.0 from Debian for 14
days and is stable.

At first I thought the problem was nfs4-related because that machine was the
only crashing one. However, on Monday I tried 4.7.2 on the nfs3-only machine
and it also crashed, so now I have no idea at all.

4.7.0 didn't last 5min in the nfs3/nfs4+kerberos machine, so it seems the
problem is worse with 4.7 than with previous versions.

I saw someone mention a gib change from 3.16->3.17 about a new lockless nfs.
Could it be at the root of this problem?

Furthermore, the crashes only happen on high load servers. It seems to be load
dependent but I cannot demonstrate it. Also, the only reason to look at nfs is
that these are the only crashing ones. We run 4.6.5 on other machines with
really big loads (and the same hardware) without any problem.
