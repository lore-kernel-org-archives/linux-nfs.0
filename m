Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([83.163.148.79]:54759 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752063Ab1HWPt0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Aug 2011 11:49:26 -0400
Date: Tue, 23 Aug 2011 17:49:24 +0200
From: Frank van Maarseveen <frankvm@frankvm.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Pavel Emelyanov <xemul@openvz.org>,
        jlayton@redhat.com
Subject: Re: [NLM] support for a per-mount grace period.
Message-ID: <20110823154924.GB2861@janus>
References: <1311878660-24482-1-git-send-email-frankvm@frankvm.com>
 <20110729171126.GN23194@fieldses.org>
 <20110823141909.GA2861@janus>
 <20110823143257.GE16261@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110823143257.GE16261@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Aug 23, 2011 at 10:32:57AM -0400, J. Bruce Fields wrote:
> On Tue, Aug 23, 2011 at 04:19:09PM +0200, Frank van Maarseveen wrote:
> > On Fri, Jul 29, 2011 at 01:11:27PM -0400, J. Bruce Fields wrote:
> > > On Thu, Jul 28, 2011 at 08:44:18PM +0200, Frank van Maarseveen wrote:
> > > > The following two patches implement support for a per-mount NLM
> > > > grace period. The first patch is a minor cleanup which pushes
> > > > down locks_in_grace() calls into functions shared by NFS[234]. Two
> > > > locks_in_grace() tests have been reordered to avoid duplicate calls at
> > > > run-time (assuming gcc is smart enough). nlmsvc_grace_period is now a
> > > > function instead of an unused variable.
> > > > 
> > > > The second patch is the actual implementation. It is currently in use for
> > > > a number of NFSv3 virtual servers on one physical machine running 2.6.39.3
> > > > where the virtualization is based on using different IPv4 addresses.
> > > 
> > > Thanks, that is something we'd like to have working well.
> > 
> > Are the patches queued anywhere for inclusion in mainline?
> 
> To merge it upstream, at a minimum we need NFSv4 working as well.  It
> causes problems when version n+1 lacks features that version n has,
> especially in the presence of clients automatically negotiate up.

This is not possible since there are no (standard) userland tools which
start the new per-mount grace time. Anyway, The patch implements it for
all NFS versions including NFSv4.

> 
> I'm also inclined to think that making the various data structures and
> interfaces network-namespace-dependent is going to result in the cleaner
> and more useful solution.

I don't understand this. NLM has been refactored in the past for NFSv4,
adding a shared fs/lockd/grace.c for all NFS versions. I think this
is good.

> 
> I probably should take that first cleanup patch at least, though.

Which git repo do you use for this?


-- 
Frank
