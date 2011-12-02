Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 5350504D.static.ziggozakelijk.nl ([83.80.80.77]:40385 "EHLO
	ns2.tasking.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753278Ab1LBJrd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 Dec 2011 04:47:33 -0500
Received: from leonino.tasking.nl (nl-fg300a-1-dmz.tasking.nl [172.16.1.8])
	by ns2.tasking.nl (8.14.5/8.14.5) with ESMTP id pB29lVEB000867
	for <linux-nfs@vger.kernel.org>; Fri, 2 Dec 2011 10:47:31 +0100 (MET)
Received: from lahti.tasking.nl (lahti.tasking.nl [172.17.2.45])
	by leonino.tasking.nl (8.14.3/8.14.3) with ESMTP id pB29lVFx004551
	for <linux-nfs@vger.kernel.org>; Fri, 2 Dec 2011 10:47:31 +0100 (MET)
To: linux-nfs@vger.kernel.org
Mime-Version: 1.0
Reply-To: dick@streefland.net (Dick Streefland)
References: <37c5.4ed7ba54.3cfb1@altium.nl> <37c5.4ed7ba54.3cfb1@altium.nl> <4ED7E678.2050104@RedHat.com>
From: dick@streefland.net (Dick Streefland)
Subject: Re: [PATCH] retry for NFS v3 mounts
Content-Type: text/plain; charset=us-ascii
Message-ID: <1dbc.4ed89eb3.a3351@altium.nl>
Date: Fri, 02 Dec 2011 09:47:31 -0000
From: rnews@altium.nl
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve Dickson <SteveD@redhat.com> wrote:
| I think the problem is more of nfs_rewrite_pmap_mount_options()
| is not interrupting RPC correctly.... How about something like this:
[...]
| +               else if (rpc_createerr.cf_stat == RPC_TIMEDOUT)
| +                       errno = ETIMEDOUT;

OK, that works as well.

-- 
Dick

