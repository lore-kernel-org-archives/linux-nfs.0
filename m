Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:34394 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751082AbaCJBpy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 9 Mar 2014 21:45:54 -0400
Date: Mon, 10 Mar 2014 01:45:52 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: NeilBrown <neilb@suse.de>
Cc: David Heidelberger <david.heidelberger@ixit.cz>, linux-nfs@vger.kernel.org
Subject: Re: DNOTIFY to INOTIFY migration
Message-ID: <20140310014551.GI18016@ZenIV.linux.org.uk>
References: <b59b1e4ede0b1d0a476c85465d480c8a@ixit.cz>
 <20140310102102.3c886726@notabene.brown>
 <20140310002015.GH18016@ZenIV.linux.org.uk>
 <20140310115659.098a7c06@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140310115659.098a7c06@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 10, 2014 at 11:56:59AM +1100, NeilBrown wrote:

> > I still don't understand WTF does rpc.imapd *want* either of those, TBH.
> 
> The rpc_pipefs filesysem which is mounted on /var/lib/nfs/rpc_pipefs creates
> new channels for talking to userspace by making new pipes appear in some
> directory.  Any client needs to arrange some notification for these new pipes
> appearing so that it can open them and hold a conversation over them.
> This calls for dnotify (in gssd and idmapd) or inotify (in blkmapd).

... or just adding ->poll() to the directory in question and using the
normal syscalls instead of all that weird crap.
