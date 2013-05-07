Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:13797 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753738Ab3EGO14 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 May 2013 10:27:56 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Jiri Slaby <jslaby@suse.cz>
CC: "jirislaby@gmail.com" <jirislaby@gmail.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        NeilBrown <neilb@suse.de>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 09/15] Make selection of 'readdir-plus' adapt to usage
 patterns.
Date: Tue, 7 May 2013 14:27:54 +0000
Message-ID: <1367936852.3580.6.camel@leira.trondhjem.org>
References: <1367936303-13386-1-git-send-email-jslaby@suse.cz>
	 <1367936303-13386-9-git-send-email-jslaby@suse.cz>
In-Reply-To: <1367936303-13386-9-git-send-email-jslaby@suse.cz>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-05-07 at 16:18 +0200, Jiri Slaby wrote:
> From: NeilBrown <neilb@suse.de>
> 
> While the use of READDIRPLUS is significantly more efficient than
> READDIR followed by many GETATTR calls, it is still less efficient
> than just READDIR if the attributes are not required.
> 
> We can get a hint as to whether the application requires attr information
> by looking at whether any ->getattr calls are made between
> ->readdir calls.
> If there are any, then getting the attributes seems to be worth while.
> 
> This patch tracks whether there have been recent getattr calls on
> children of a directory and uses that information to selectively
> disable READDIRPLUS on that directory.
> 
> The first 'readdir' call is always served using READDIRPLUS.
> Subsequent calls only use READDIRPLUS if there was a getattr on a child
> in the mean time.
> 
> The locking of ->d_parent access needs to be reviewed.
> As the bit is simply a hint, it isn't critical that it is set
> on the "correct" parent if a rename is happening, but it is
> critical that the 'set' doesn't set a bit in something that
> isn't even an inode any more.
> 
> Acked-by: NeilBrown <neilb@suse.de>
> Signed-off-by: Neil Brown <neilb@suse.de>
> Signed-off-by: Jiri Slaby <jslaby@suse.cz>
> Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: linux-nfs@vger.kernel.org
> ---

Why am I being Cced on this?

You have looked at commit d69ee9b85541a69a1092f5da675bd23256dc62af (NFS:
Adapt readdirplus to application usage patterns) which was upstreamed in
Linux 3.5, right?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
