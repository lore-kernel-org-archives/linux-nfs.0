Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:49331 "EHLO
	relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750774AbaKYAwo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Nov 2014 19:52:44 -0500
Date: Mon, 24 Nov 2014 16:52:21 -0800
From: Josh Triplett <josh@joshtriplett.org>
To: Pieter Smith <pieter@boesman.nl>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Alexei Starovoitov <ast@plumgrid.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Bertrand Jacquin <beber@meleeweb.net>,
        Catalina Mocanu <catalina.mocanu@gmail.com>,
        Daniel Borkmann <dborkman@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Fabian Frederick <fabf@skynet.be>,
        "open list:FUSE: FILESYSTEM..." <fuse-devel@lists.sourceforge.net>,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        Hugh Dickins <hughd@google.com>, Iulia Manda <iulia.manda21@gmail.com>,
        Jan Beulich <JBeulich@suse.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        "open list:ABI/API" <linux-api@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org,
        open list <linux-kernel@vger.kernel.org>,
        "open list:KERNEL NFSD, SUNR..." <linux-nfs@vger.kernel.org>,
        "Luis R. Rodriguez" <mcgrof@suse.com>,
        Matt Turner <mattst88@gmail.com>, Mel Gorman <mgorman@suse.de>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Miklos Szeredi <miklos@szeredi.hu>,
        "open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>,
        Oleg Nesterov <oleg@redhat.com>,
        Paul Durrant <Paul.Durrant@citrix.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Peter Foley <pefoley2@pefoley.com>, Thomas Graf <tgraf@suug.ch>,
        Tom Herbert <therbert@google.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Willem de Bruijn <willemb@google.com>,
        Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>,
        =?utf-8?B?6JSh5q2j6b6Z?= <zhenglong.cai@cs2c.com.cn>
Subject: Re: [PATCH v4 0/7] kernel tinification: optionally compile out
 splice family of syscalls (splice, vmsplice, tee and sendfile)
Message-ID: <20141125005221.GB21653@thin>
References: <1416870079-15254-1-git-send-email-pieter@boesman.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1416870079-15254-1-git-send-email-pieter@boesman.nl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 25, 2014 at 12:00:59AM +0100, Pieter Smith wrote:
> REPO: https://github.com/smipi1/linux-tinification.git
> 
> BRANCH: tiny/config-syscall-splice
> 
> BACKGROUND: This patch-set forms part of the Linux Kernel Tinification effort (
>   https://tiny.wiki.kernel.org/).
> 
> GOAL: Support compiling out the splice family of syscalls (splice, vmsplice,
>   tee and sendfile) along with all supporting infrastructure if not needed.
>   Many embedded systems will not need the splice-family syscalls. Omitting them
>   saves space.
> 
> HISTORY:
>   PATCH v4:
>     - Drops __splice_p()
>     - Let nfsd fall back to non-splice support when splice is compiled out
>     - Style fixes
[...]
> RESULTS: A tinyconfig bloat-o-meter score for the entire patch-set:
> 
> add/remove: 0/41 grow/shrink: 5/7 up/down: 23/-8422 (-8399)

I replied to one patch with a minor nit in the commit message.  Other
than that, I don't see any obvious issues with this.

- Josh Triplett
