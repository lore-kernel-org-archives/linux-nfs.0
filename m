From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] mount.nfs command: old glibc missing some flags
Date: Thu, 31 Jul 2008 09:18:38 +1000
Message-ID: <18576.63182.614286.878006@notabene.brown>
References: <20080729161512.7588.18445.stgit@manray.1015granger.net>
	<x6y73jyiek@gzp>
	<4890BA36.1060802@RedHat.com>
	<x6sktrfacd@gzp>
	<4890C58E.3060701@RedHat.com>
	<x6od4ff6qk@gzp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>,
	Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: "Gabor Z. Papp" <gzp-2g/1Y3AqmNE@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:34484 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752039AbYG3XSq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Jul 2008 19:18:46 -0400
In-Reply-To: message from Gabor Z. Papp on Wednesday July 30
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wednesday July 30, gzp-2g/1Y3AqmNE@public.gmane.org wrote:
> * Steve Dickson <SteveD@redhat.com>:
> 
> | > | In general, if there are file(s) in /var/lib/nfs/sm (or /var/lib/nfs/statd/sm 
> | > | depending on your distro) means sm-notify did not work. With Fedora, doing 
> | > | a 'service nfslock restart' will cause sm-notify to be rerun... I'm not 
> | > | sure how to do that with other distros... 
> | > 
> | > Those dirs are empty.
> | So either there were no locks to recover or sm-notify did indeed work... 
> 
> How sm-notify works in general? Called by statd?

Yes, it will be called by statd (unless -L was given).
It can also be run separately.

> If first time works, pid file left and second time didn't run as you
> mentoided. So something wrong here...

No, nothing wrong there.

sm-notify only needs to run once per boot, to tell peers (either
servers or clients) that this system has rebooted.  It deliberately
ensures that if you run it a second time it just exits.
There is even a comment in the source:
/*
 * Record pid in /var/run/sm-notify.pid
 * This file should remain until a reboot, even if the
 * program exits.
 * If file already exists, fail.
 */

This assumes that early in reboot /var/run gets cleared.  If this
doesn't happen it could be awkward.

NeilBrown
