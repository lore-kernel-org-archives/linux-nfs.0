From: "Gabor Z. Papp" <gzp-2g/1Y3AqmNE@public.gmane.org>
Subject: Re: [PATCH] mount.nfs command: old glibc missing some flags
Date: Wed, 30 Jul 2008 22:37:55 +0200
Message-ID: <x6od4ff6qk@gzp>
References: <20080729161512.7588.18445.stgit@manray.1015granger.net>
	<x6y73jyiek@gzp> <4890BA36.1060802@RedHat.com> <x6sktrfacd@gzp>
	<4890C58E.3060701@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from odpn1.odpn.net ([212.40.96.53]:48443 "EHLO odpn1.odpn.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750823AbYG3Uh4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Jul 2008 16:37:56 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

* Steve Dickson <SteveD@redhat.com>:

| > | In general, if there are file(s) in /var/lib/nfs/sm (or /var/lib/nfs/statd/sm 
| > | depending on your distro) means sm-notify did not work. With Fedora, doing 
| > | a 'service nfslock restart' will cause sm-notify to be rerun... I'm not 
| > | sure how to do that with other distros... 
| > 
| > Those dirs are empty.
| So either there were no locks to recover or sm-notify did indeed work... 

How sm-notify works in general? Called by statd?
If first time works, pid file left and second time didn't run as you
mentoided. So something wrong here...
