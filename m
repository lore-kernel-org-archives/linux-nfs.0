From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: [NFS] htree+NFS (NFS client bug?)
Date: Thu, 28 Nov 2002 18:57:45 +0100
Sender: ext2-devel-admin@lists.sourceforge.net
Message-ID: <15846.22809.438838.989047@charged.uio.no>
References: <1038354285.1302.144.camel@sherkaner.pao.digeo.com>
	<shsptsrd761.fsf@charged.uio.no>
	<1038387522.31021.188.camel@ixodes.goop.org>
	<20021127150053.A2948@redhat.com>
	<15845.10815.450247.316196@charged.uio.no>
	<20021127205554.J2948@redhat.com>
	<shslm3e4or2.fsf@charged.uio.no>
	<20021128164143.D2362@redhat.com>
	<15846.19228.868861.629722@charged.uio.no>
	<20021128170924.F2362@redhat.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeremy Fitzhardinge <jeremy@goop.org>,
    Ext2 devel <ext2-devel@lists.sourceforge.net>,
    NFS maillist <nfs@lists.sourceforge.net>,
    Linux Kernel List <linux-kernel@vger.kernel.org>
Return-path: <ext2-devel-admin@lists.sourceforge.net>
To: "Stephen C. Tweedie" <sct@redhat.com>
In-Reply-To: <20021128170924.F2362@redhat.com>
Errors-To: ext2-devel-admin@lists.sourceforge.net
List-Help: <mailto:ext2-devel-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:ext2-devel@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ext2-devel>,
	<mailto:ext2-devel-request@lists.sourceforge.net?subject=subscribe>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ext2-devel>,
	<mailto:ext2-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=ext2-devel>
List-ID: <nfs.lists.sourceforge.net>

>>>>> " " == Stephen C Tweedie <sct@redhat.com> writes:

     > Right.  But marking the fact can be done in the inode.  We do
     > that for regular files, after all --- we have an i_size field
     > which marks the value of f_pos which represents EOF.  And
     > _that_ is what I'm suggesting for the NFS case --- record in
     > the inode the cookie which represents EOF, so that in future
     > reads from cache, we still know when we've got to the end of
     > the stream.

That wouldn't really help much here, since that scheme also has a
uniqueness assumption on the cookie. I agree that it would cause a
more graceful failure, since we'd end up truncating the readdir rather
than endlessly looping, but as far as the user is concerned, it's
still wrong behaviour.

The real solution here would be to augment the cookie information in
the struct file with something like a filename in order to define
where we are in the readdir stream.
That doesn't work too well with telldir/seekdir though, and glibc
(grr....) relies heavily on using those in order in their 'heuristic'
that corrects for dirent being larger than the kernel dirent.

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: Get the new Palm Tungsten T 
handheld. Power & Color in a compact size! 
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0002en
