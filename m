From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: PATCH[2/2] Display nfsv4 server operations statistics
Date: Wed, 17 May 2006 17:38:32 -0400
Message-ID: <20060517213832.GF11237@fieldses.org>
References: <4469C83D.AD69.00CC.0@novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org
Return-path: <nfsv4-bounces@linux-nfs.org>
To: Shankar Anand <shanand@novell.com>
In-Reply-To: <4469C83D.AD69.00CC.0@novell.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

On Tue, May 16, 2006 at 01:10:28AM -0600, Shankar Anand wrote:
> This patch adds code to nfsstat to read /proc/net/rpc/nfsd for nfsv4
> server statistics and print them.

I don't see any showstoppers; thanks for doing this.

By the way, you seem to be attaching two copies of each patch; any
reason for that?

It'd actually be preferable just to append a copy in the body of the
email, as long as your mail client can be persuaded not to mess with the
white space.

--b.
