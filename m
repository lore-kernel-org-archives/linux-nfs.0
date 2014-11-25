Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:36301 "EHLO
	relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750726AbaKYWIy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Nov 2014 17:08:54 -0500
Date: Tue, 25 Nov 2014 14:08:41 -0800
From: josh@joshtriplett.org
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Pieter Smith <pieter@boesman.nl>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
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
        Jeff Layton <jlayton@poochiereds.net>, linux-api@vger.kernel.org,
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
        Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 0/7] kernel tinification: optionally compile out
 splice family of syscalls (splice, vmsplice, tee and sendfile)
Message-ID: <20141125220841.GB25683@cloud>
References: <1416870079-15254-1-git-send-email-pieter@boesman.nl>
 <5474ABB6.3030400@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5474ABB6.3030400@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[Resending this mail due to some email encoding brokenness that
prevented it from reaching LKML the first time; sorry to anyone who
receives two copies.]

On Tue, Nov 25, 2014 at 08:17:58AM -0800, Randy Dunlap wrote:
> On 11/24/2014 03:00 PM, Pieter Smith wrote:
> >REPO: https://github.com/smipi1/linux-tinification.git
> >
> >BRANCH: tiny/config-syscall-splice
> >
> >BACKGROUND: This patch-set forms part of the Linux Kernel Tinification effort (
> >   https://tiny.wiki.kernel.org/).
> >
> >GOAL: Support compiling out the splice family of syscalls (splice, vmsplice,
> >   tee and sendfile) along with all supporting infrastructure if not needed.
> >   Many embedded systems will not need the splice-family syscalls. Omitting them
> >   saves space.
> 
> Hi,
> 
> Is the splice family of syscalls the only one that tiny has identified
> for optional building or can we expect similar treatment for other
> syscalls?

Pretty much any system call that you could conceive of writing a
userspace without.

There's a partial project list at https://tiny.wiki.kernel.org/projects.

> Why will many embedded systems not need these syscalls?  You know
> exactly what apps they run and you are positive that those apps do
> not use splice?

Yes, precisely.  We're talking about embedded systems small enough that
you're booting with init=/your/app and don't even call fork(), where you
know exactly what code you're putting in and what libraries you use.
And they're almost certainly not running glibc.

> >RESULTS: A tinyconfig bloat-o-meter score for the entire patch-set:
> >
> >add/remove: 0/41 grow/shrink: 5/7 up/down: 23/-8422 (-8399)
> 
> The summary is that this patch saves around 8 KB of code space --
> is that correct?

Right.  For reference, we're talking about kernels where the *total*
size is a few hundred kB.

> How much storage space do embedded systems have nowadays?

For the embedded systems we're targeting for the tinification effort, in
a first pass: 512k-2M of storage (often for an *uncompressed* kernel, to
support execute-in-place), and 128k-512k of memory.  We've successfully
built useful kernels and userspaces for such environments, and we'd like
to go even smaller.

- Josh Triplett
