From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Re: [PATCH] zerocopy NFS for 2.5.43
Date: Mon, 28 Oct 2002 09:46:53 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15804.27869.374555.242999@notabene.cse.unsw.edu.au>
References: <15797.63730.223181.75888@notabene.cse.unsw.edu.au>
	<20021025.185234.08315285.taka@valinux.co.jp>
	<15801.15328.866301.720864@notabene.cse.unsw.edu.au>
	<20021026.121150.74753877.taka@valinux.co.jp>
	<20021025234634.A26957@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hirokazu Takahashi <taka@valinux.co.jp>,
    nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 185wBX-00029s-00
	for <nfs@lists.sourceforge.net>; Sun, 27 Oct 2002 14:47:07 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.204] == wireless-204.wireless.cse.unsw.EDU.AU)
	(for <bcrl@redhat.com>) (for <taka@valinux.co.jp>)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Mon, 28 Oct 2002 09:46:54 +1100
To: Benjamin LaHaise <bcrl@redhat.com>
In-Reply-To: message from Benjamin LaHaise on Friday October 25
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Friday October 25, bcrl@redhat.com wrote:
> On Sat, Oct 26, 2002 at 12:11:50PM +0900, Hirokazu Takahashi wrote:
> > OK.
> > 
> > It's goot that you're implementing vfs_readv and vfs_writev which
> > I've also realized it doesn't support aio yet.
> 
> The aio methods are soon switching over to vectored operations for a 
> few reasons.  It's likely that non-vectored methods will be gone soon.

If you are introducing new 'vectored' operations, it would be nice if
they work well for kernel-space as well as user-space.

In the 'old days' before CONFIG_HIMEM, you could just

	oldfs = get_fs(); set_fs(KERNEL_DS);
        ...whatever....
	set_fs(oldfs);

to use kernel addresses.  But with CONFIG_HIMEM the kernel often
wants to work with "struct page *" instead of just a "void *",
so this doesn't always work.
It would be nice if you could pass in an 'actor' which for user-space
access would call copy-to/from-user for kernel-space would do
kmap/copy/kunmap

Just a thought.....

NeilBrown


-------------------------------------------------------
This SF.net email is sponsored by: ApacheCon, November 18-21 in
Las Vegas (supported by COMDEX), the only Apache event to be
fully supported by the ASF. http://www.apachecon.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
