From: "Kendrick M. Smith" <kmsmith@umich.edu>
Subject: Re: type check in fh_verify()
Date: Sun, 28 Jul 2002 01:00:02 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.SOL.4.44.0207280057190.9491-100000@rygar.gpcc.itd.umich.edu>
References: <15683.28931.169253.908126@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from berzerk.gpcc.itd.umich.edu ([141.211.2.162])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17YgA1-0008AD-00
	for <nfs@lists.sourceforge.net>; Sat, 27 Jul 2002 22:00:05 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <15683.28931.169253.908126@notabene.cse.unsw.edu.au>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


On Sun, 28 Jul 2002, Neil Brown wrote:

> On Saturday July 27, kmsmith@umich.edu wrote:
> >
> > In fs/nfsd/nfsfh.c:fh_verify(), the following block of code is
> > responsible for type checking:
> >
> > 	/* Type check. The correct error return for type mismatches
> > 	 * does not seem to be generally agreed upon. SunOS seems to
> > 	 * use EISDIR if file isn't S_IFREG; a comment in the NFSv3
> > 	 * spec says this is incorrect (implementation notes for the
> > 	 * write call).
> > 	 */
> >
> > 	/* Type can be negative when creating hardlinks - not to a dir */
> > 	if (type > 0 && (inode->i_mode & S_IFMT) != type) {
> > 		error = (type == S_IFDIR)? nfserr_notdir : nfserr_isdir;
> > 		goto out;
> > 	}
> > 	if (type < 0 && (inode->i_mode & S_IFMT) == type) {
> > 		error = (type == -S_IFDIR)? nfserr_notdir : nfserr_isdir;
> > 		goto out;
> > 	}
> >
> > I think that the assignment in the last block is backwards and should be
> >
> > 		error = (type == -S_IFDIR)? nfserr_isdir : nfserr_notdir;
>
> Looks right... but we should also change
>  	if (type < 0 && (inode->i_mode & S_IFMT) == type) {
> to
>  	if (type < 0 && (inode->i_mode & S_IFMT) == -type) {
>
> or we will never benefit from the change !!!

Sorry!  This was a typo in my message: it should have been -type
to begin with...

> > Also, how about changing the assignment in the first block to
> >
> > 		if (type == S_IFDIR)
> > 			error = nfserr_notdir;
> > 		else if ((inode->i_mode & S_IFMT) == S_IFDIR)
> > 			error = nfserr_isdir;
> > 		else
> > 			error = nfserr_inval;
> > 		goto out;
> >
> > to be consistent with the comment?
>
> Sounds fair to me.
> Would you like to convert this into a patch and send it to Linus with
> my blessing ?
> I probably wouldn't bother Marcelo with it until 2.4.19 is out.

OK, I will send a patch in the next day or two.

Cheers,
 Kendrick



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
