From: Olivier Galibert <galibert@pobox.com>
Subject: Re: Make NFS userspace and server directories cookies independant [patch, fc3, 2.6.10-1.766_FC3]
Date: Tue, 22 Mar 2005 17:00:07 +0100
Message-ID: <20050322160007.GA7631@dspnet.fr.eu.org>
References: <20050321162142.GB46055@dspnet.fr.eu.org> <1111427218.10508.27.camel@lade.trondhjem.org> <20050322000210.GA4681@dspnet.fr.eu.org> <1111450936.10980.55.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Hack inc." <linux-kernel@vger.kernel.org>,
	nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1111450936.10980.55.camel@lade.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Mon, Mar 21, 2005 at 07:22:16PM -0500, Trond Myklebust wrote:
> This sort of thing worries me: I think we can do better by hooking
> lseek() on directories. I'll see what I can do.

And the patch is buggy somehow, sometimes loses entries.  Keep it on
hold whie I trace the probm and fix it please.

  OG.
