From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Re: [NFS] htree+NFS (NFS client bug?)
Date: Wed, 27 Nov 2002 20:55:54 +0000
Sender: ext2-devel-admin@lists.sourceforge.net
Message-ID: <20021127205554.J2948@redhat.com>
References: <1038354285.1302.144.camel@sherkaner.pao.digeo.com> <shsptsrd761.fsf@charged.uio.no> <1038387522.31021.188.camel@ixodes.goop.org> <20021127150053.A2948@redhat.com> <15845.10815.450247.316196@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Stephen C. Tweedie" <sct@redhat.com>,
   Jeremy Fitzhardinge <jeremy@goop.org>,
   Ext2 devel <ext2-devel@lists.sourceforge.net>,
   NFS maillist <nfs@lists.sourceforge.net>,
   Linux Kernel List <linux-kernel@vger.kernel.org>
Return-path: <ext2-devel-admin@lists.sourceforge.net>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <15845.10815.450247.316196@charged.uio.no>; from trond.myklebust@fys.uio.no on Wed, Nov 27, 2002 at 09:25:35PM +0100
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

On Wed, Nov 27, 2002 at 09:25:35PM +0100, Trond Myklebust wrote:
> >>>>> " " == Stephen C Tweedie <sct@redhat.com> writes:
>      > So I suspect that this is a root a client problem --- the
>      > client has repeated a READDIR despite being told that the
>      > previous reply was EOF
 
> I disagree. As far as the client is concerned, it has just been asked
> to read the entry that corresponds to that particular cookie.

No, it hasn't --- at least not unless there has been a seekdir in
between.  If the client has already been told that we're at EOF, then
it's wrong to go back to the server again for more data. 

Having said that, the server is clearly in error in sending a
duplicate cookie in the first place, and if it did so we'd never get
into such a state.

> If
> glibc issued a new readdir request (which is what I suspect has
> happened here), the NFS client has no idea what the previous reply
> was

Well, glibc will *always* issue another readdir, because the only way
we can ever tell glibc that we're at EOF on the directory is when we
eventually return 0 from getdents.  The question about client
behaviour is, if we've already been told that the stream is at EOF,
should the client simply discard that info and keep reading
regardless, or should it cache the EOF status?

> IOW: A cookie should *always* be unique. There are no exceptions to
> this rule.

Agreed.

--Stephen


-------------------------------------------------------
This SF.net email is sponsored by: Get the new Palm Tungsten T 
handheld. Power & Color in a compact size! 
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0002en
