From: Burton Windle <bwindle@fint.org>
Subject: Re: 2.6.3: oops reading /proc/net/rpc/auth.unix.ip/content
Date: Tue, 24 Feb 2004 19:37:40 -0500 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0402241935240.889@morpheus>
References: <Pine.LNX.4.58.0402240909310.889@morpheus>
 <16443.55224.556737.70553@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Avn4U-0002z7-M6
	for nfs@lists.sourceforge.net; Tue, 24 Feb 2004 16:38:42 -0800
Received: from mta02.alltel.net ([166.102.165.144] helo=mta02-srv.alltel.net)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1Avmr2-00021o-Ph
	for nfs@lists.sourceforge.net; Tue, 24 Feb 2004 16:24:48 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16443.55224.556737.70553@notabene.cse.unsw.edu.au>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Upon doing a 'make clean', and setting my gcc symlink back to trusty old
GCC 2.95, kernel 2.6.3 works just fine.

Let it be know that GCC 3.3 (or at least the GCC 3.3.3-0pre3 that is in
Debian Testing) is broken.

I'm sorry to have wasted your time.

--
Burton Windle                           bwindle@fint.org


On Wed, 25 Feb 2004, Neil Brown wrote:

> On Tuesday February 24, bwindle@fint.org wrote:
> > Hello.  I just upgraded a workstation from 2.6.2 to 2.6.3, and am now
> > seeing an oops on boot when my init scripts run the nfs-kernel-server
> > script. The oops actually happens whenever trying to read
> > /proc/net/rpc/auth.unix.ip/content
> >
> > Is this a known-issue?
>
> I hate to say this, but this cannot possibly happen :-)
>
> It is fairly clear from:
>
> > Unable to handle kernel NULL pointer dereference at virtual address 00000044
> > EIP is at content_open+0x5b/0x80
> > eax: 00000000   ebx: cfb49628   ecx: 00000000   edx: cf92d738
> > esi: 00000000   edi: cfb29df4   ebp: cfc45f3c   esp: cfc45f28
> > ds: 007b   es: 007b   ss: 0068
> >
> > Code: 89 58 44 89 f0 8b 5d f4 8b 75 f8 8b 7d fc 89 ec 5d c3 8d 76
> >
>
> that the oops is happening :
>
> static int content_open(struct inode *inode, struct file *file)
> {
> 	int res;
> 	struct handle *han;
> 	struct cache_detail *cd = PDE(inode)->data;
>
> 	han = kmalloc(sizeof(*han), GFP_KERNEL);
> 	if (han == NULL)
> 		return -ENOMEM;
>
> 	han->cd = cd;
>
> 	res = seq_open(file, &cache_content_op);
> 	if (res)
> 		kfree(han);
> 	else
> /*HERE*/	((struct seq_file *)file->private_data)->private = han;
>
> 	return res;
> }
>
> The instruction that is oopsing is:
>    0:   89 58 44                  mov    %ebx,0x44(%eax)
> which is storing the value "han" (in %ebx, 0xcfb49628) into element
> "private" (offset 0x44) of ((struct seq_file *)file->private_data)
> (in %eax, 0x00).
>
> So file->private_data must be NULL.
>
> However seq_open has just returned zero (or we wouldn't have got to
> this code) and you can see from
>
> int seq_open(struct file *file, struct seq_operations *op)
> {
> 	struct seq_file *p = kmalloc(sizeof(*p), GFP_KERNEL);
> 	if (!p)
> 		return -ENOMEM;
> 	memset(p, 0, sizeof(*p));
> 	sema_init(&p->sem, 1);
> 	p->op = op;
> 	file->private_data = p;
> 	return 0;
> }
>
> that this means that file->private_data is most definitely not NULL.
>
> As I said, it cannot happen....
>
> Maybe a compiler bug ???? (wouldn't be the first time).
>
> Would you be able to use gdb to disassemble all of content_open and
> seq_file so I can see what is happening?
>
> NeilBrown
>


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
