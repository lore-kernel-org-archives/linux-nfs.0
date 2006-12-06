From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] [PATCH 10/10] gfs2: nfs lock support for gfs2
Date: Wed, 6 Dec 2006 17:00:29 -0500
Message-ID: <20061206220029.GC25465@fieldses.org>
References: <8eb625184e6025f7f3d081dfe0a805abdd62a068.1165380892.git.bfields@citi.umich.edu> <70549752c06e54117024429649fd7aa813f21bec.1165380893.git.bfields@citi.umich.edu> <20061206154951.GB16378@redhat.com> <20061206195722.GH1714@fieldses.org> <20061206205822.GB25322@redhat.com> <20061206212347.GA25465@fieldses.org> <20061206214231.GC25322@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	Marc Eshel <eshel@almaden.ibm.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: David Teigland <teigland@redhat.com>
In-Reply-To: <20061206214231.GC25322@redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Wed, Dec 06, 2006 at 03:42:31PM -0600, David Teigland wrote:
> Oh yeah, that's painful, I knew it sounded too easy.

Yeah.  Well, we could try to teach GFS2 to reliably cancel posix locks.
I think that may turn out to be necessary some day anyway.

Or we could look at why we're timing out and figure out whether there's
something else we should be doing instead in that case.  In what
situations is the GFS2 lock call likely to take overly long?

--b.
