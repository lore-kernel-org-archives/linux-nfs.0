From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: type check in fh_verify()
Date: Sun, 28 Jul 2002 14:20:19 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15683.28931.169253.908126@notabene.cse.unsw.edu.au>
References: <Pine.SOL.4.44.0207272311170.18815-100000@vanguard.gpcc.itd.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17YfXZ-0006je-00
	for <nfs@lists.sourceforge.net>; Sat, 27 Jul 2002 21:20:21 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <kmsmith@umich.edu>) (for <nfs@lists.sourceforge.net>) By tone
	With Smtp ; Sun, 28 Jul 2002 14:20:10 +1000
To: "Kendrick M. Smith" <kmsmith@umich.edu>
In-Reply-To: message from Kendrick M. Smith on Saturday July 27
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

On Saturday July 27, kmsmith@umich.edu wrote:
> 
> In fs/nfsd/nfsfh.c:fh_verify(), the following block of code is
> responsible for type checking:
> 
> 	/* Type check. The correct error return for type mismatches
> 	 * does not seem to be generally agreed upon. SunOS seems to
> 	 * use EISDIR if file isn't S_IFREG; a comment in the NFSv3
> 	 * spec says this is incorrect (implementation notes for the
> 	 * write call).
> 	 */
> 
> 	/* Type can be negative when creating hardlinks - not to a dir */
> 	if (type > 0 && (inode->i_mode & S_IFMT) != type) {
> 		error = (type == S_IFDIR)? nfserr_notdir : nfserr_isdir;
> 		goto out;
> 	}
> 	if (type < 0 && (inode->i_mode & S_IFMT) == type) {
> 		error = (type == -S_IFDIR)? nfserr_notdir : nfserr_isdir;
> 		goto out;
> 	}
> 
> I think that the assignment in the last block is backwards and should be
> 
> 		error = (type == -S_IFDIR)? nfserr_isdir : nfserr_notdir;

Looks right... but we should also change
 	if (type < 0 && (inode->i_mode & S_IFMT) == type) {
to
 	if (type < 0 && (inode->i_mode & S_IFMT) == -type) {

or we will never benefit from the change !!!

> 
> Also, how about changing the assignment in the first block to
> 
> 		if (type == S_IFDIR)
> 			error = nfserr_notdir;
> 		else if ((inode->i_mode & S_IFMT) == S_IFDIR)
> 			error = nfserr_isdir;
> 		else
> 			error = nfserr_inval;
> 		goto out;
> 
> to be consistent with the comment?

Sounds fair to me.
Would you like to convert this into a patch and send it to Linus with
my blessing ?
I probably wouldn't bother Marcelo with it until 2.4.19 is out.

Thanks,
NeilBrown


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
