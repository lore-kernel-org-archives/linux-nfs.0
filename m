From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Re: [NFS] htree+NFS (NFS client bug?)
Date: Thu, 28 Nov 2002 17:09:24 +0000
Sender: ext2-devel-admin@lists.sourceforge.net
Message-ID: <20021128170924.F2362@redhat.com>
References: <1038354285.1302.144.camel@sherkaner.pao.digeo.com> <shsptsrd761.fsf@charged.uio.no> <1038387522.31021.188.camel@ixodes.goop.org> <20021127150053.A2948@redhat.com> <15845.10815.450247.316196@charged.uio.no> <20021127205554.J2948@redhat.com> <shslm3e4or2.fsf@charged.uio.no> <20021128164143.D2362@redhat.com> <15846.19228.868861.629722@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Stephen C. Tweedie" <sct@redhat.com>,
   Jeremy Fitzhardinge <jeremy@goop.org>,
   Ext2 devel <ext2-devel@lists.sourceforge.net>,
   NFS maillist <nfs@lists.sourceforge.net>,
   Linux Kernel List <linux-kernel@vger.kernel.org>
Return-path: <ext2-devel-admin@lists.sourceforge.net>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <15846.19228.868861.629722@charged.uio.no>; from trond.myklebust@fys.uio.no on Thu, Nov 28, 2002 at 05:58:04PM +0100
Errors-To: ext2-devel-admin@lists.sourceforge.net
List-Help: <mailto:ext2-devel-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:ext2-devel@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ext2-devel>,
	<mailto:ext2-devel-request@lists.sourceforge.net?subject=subscribe>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ext2-devel>,
	<mailto:ext2-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=ext2-devel>
List-ID: <nfs.lists.sourceforge.net>

Hi,

On Thu, Nov 28, 2002 at 05:58:04PM +0100, Trond Myklebust wrote:
> >>>>> " " == Stephen C Tweedie <sct@redhat.com> writes:
 
>      > If you want it to be preserved in cache, it needs to be in the
>      > inode, not in the file.
> 
> You misunderstand the problem. It isn't that the page cache has an
> incorrect representation of the stream: the page cache is indeed
> stopping filling as soon as it hits the EOF marker.

I know that.

> The problem is that we are stuffing the server-supplied cookies into
> file->f_pos and using them to reconstruct where we are in the readdir
> stream.
> As there is no reserved 'EOF cookie' defined by the protocol that we
> might use, we must either rely on the server giving us a unique cookie
> also for the EOF case, or else mark the fact that filp->f_pos points
> to EOF in some other way.

Right.  But marking the fact can be done in the inode.  We do that for
regular files, after all --- we have an i_size field which marks the
value of f_pos which represents EOF.  And _that_ is what I'm
suggesting for the NFS case --- record in the inode the cookie which
represents EOF, so that in future reads from cache, we still know when
we've got to the end of the stream.

This gets complicated by the possible presence of hash collisions,
though.

Ted, I think there's a problem with the logic for that case.  We can
really only deal sensibly with hash collisions if we do everything in
our power to prevent returning f_pos back to the user in the middle of
a collision, but there's nothing in the ext3 code to do that right now
afaict.  (And even if there were, NFS would just keep calling us to
get more dirents, so fixing it just in ext3 doesn't stop a hash
collision from spanning an NFS reply.)

--Stephen


-------------------------------------------------------
This SF.net email is sponsored by: Get the new Palm Tungsten T 
handheld. Power & Color in a compact size! 
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0002en
