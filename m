From: Brad Boyer <flar@allandria.com>
Subject: Re: [PATCH 3/14] locks: factor out generic/filesystem switch
	from setlock code
Date: Fri, 2 Feb 2007 21:16:38 -0800
Message-ID: <20070203051638.GA29763@cynthia.pants.nu>
References: <ad8373acbb12f165b625f6065bc0ca86f3982b7f.1170479265.git.bfields@citi.umich.edu>
	<1dd47bf9aeb6f19c82a59efb2f4236f23f73019d.1170479265.git.bfields@citi.umich.edu>
	<20070203085136.GC18828@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-fsdevel@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	nfs@lists.sourceforge.net, Marc Eshel <eshel@almaden.ibm.com>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HDWQh-0005Jw-8g
	for nfs@lists.sourceforge.net; Sat, 03 Feb 2007 17:44:31 -0800
Received: from adsl-216-102-214-42.dsl.snfc21.pacbell.net
	([216.102.214.42] helo=cynthia.pants.nu ident=Debian-exim)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HDWQi-0000GD-1N
	for nfs@lists.sourceforge.net; Sat, 03 Feb 2007 17:44:33 -0800
In-Reply-To: <20070203085136.GC18828@infradead.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Sat, Feb 03, 2007 at 08:51:36AM +0000, Christoph Hellwig wrote:
> On Sat, Feb 03, 2007 at 12:33:59AM -0500, J. Bruce Fields wrote:
> > + */
> > +int vfs_lock_file(struct file *filp, unsigned int cmd, struct file_lock *fl)
> > +{
> > +	if (filp->f_op && filp->f_op->lock)
> > +		return filp->f_op->lock(filp, cmd, fl);
> > +	else
> > +		return posix_lock_file(filp, fl);
> > +}
> > +EXPORT_SYMBOL(vfs_lock_file);
> 
> _GPL please (and same for the last patch)

Any particular reason? It seems like this is a function that
would be exactly the sort of thing to be publically exported.
I know it's not a popular opinion around here, but I think
that the GPL exports should be primarily for things that
aren't intended to be used by normal modules. It seems to
me that people pushing for everything to be marked GPL are
trying to get a backdoor enforcement of their own dislike
of proprietary kernel modules in spite of Linus' known
stance on the issue. I hope this doesn't start a flamewar,
but I do want to bring up this even if many people don't
want to hear it. I'm sure I'm not the only one with this
stance on it.

	Brad Boyer
	flar@allandria.com


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
