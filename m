From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Re: [NFS] htree+NFS (NFS client bug?)
Date: Thu, 28 Nov 2002 16:41:43 +0000
Sender: ext2-devel-admin@lists.sourceforge.net
Message-ID: <20021128164143.D2362@redhat.com>
References: <1038354285.1302.144.camel@sherkaner.pao.digeo.com> <shsptsrd761.fsf@charged.uio.no> <1038387522.31021.188.camel@ixodes.goop.org> <20021127150053.A2948@redhat.com> <15845.10815.450247.316196@charged.uio.no> <20021127205554.J2948@redhat.com> <shslm3e4or2.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Stephen C. Tweedie" <sct@redhat.com>,
   Jeremy Fitzhardinge <jeremy@goop.org>,
   Ext2 devel <ext2-devel@lists.sourceforge.net>,
   NFS maillist <nfs@lists.sourceforge.net>,
   Linux Kernel List <linux-kernel@vger.kernel.org>
Return-path: <ext2-devel-admin@lists.sourceforge.net>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shslm3e4or2.fsf@charged.uio.no>; from trond.myklebust@fys.uio.no on Wed, Nov 27, 2002 at 11:44:01PM +0100
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

On Wed, Nov 27, 2002 at 11:44:01PM +0100, Trond Myklebust wrote:

> We could possibly cache the EOF status by overloading some other field
> in the struct file. f_version comes to mind as a useful candidate,
> since it automatically gets reset by llseek.

If you want it to be preserved in cache, it needs to be in the inode,
not in the file.

--Stephen


-------------------------------------------------------
This SF.net email is sponsored by: Get the new Palm Tungsten T 
handheld. Power & Color in a compact size! 
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0002en
