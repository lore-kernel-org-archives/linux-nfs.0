From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: dentry/inode cache invalidation when using nfsd filesystem on 2.6
Date: Fri, 24 Oct 2003 14:59:09 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16280.45469.770950.354371@notabene.cse.unsw.edu.au>
References: <20031021142414.GW1516@dbz.austin.ibm.com>
	<16279.20926.488909.525633@notabene.cse.unsw.edu.au>
	<20031023124016.GH6172@dbz.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1ADNfF-0004ct-00
	for <nfs@lists.sourceforge.net>; Sat, 25 Oct 2003 05:37:05 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 1ACu8V-0001mD-C0
	for nfs@lists.sourceforge.net; Thu, 23 Oct 2003 22:05:19 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <jrsantos@austin.ibm.com>) (for <nfs@lists.sourceforge.net>) By
	note With Smtp ; Fri, 24 Oct 2003 14:59:15 +1000
To: "Jose R. Santos" <jrsantos@austin.ibm.com>
In-Reply-To: message from Jose R. Santos on Thursday October 23
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

On Thursday October 23, jrsantos@austin.ibm.com wrote:
> On 10/22/03 22:57:50, Neil Brown wrote:
> > 
> > The problem is NOT that the inode or dentry caches are being flushed.
> > 
> > The problem is that the inode and dentry caches
> > *for*the*(tiny)*nfsd*filesystem*
> > are being flushed, and this requires iterating through each cache under a
> > spinlock, and this can take a while.
> 
> I saw some weirdness that led me to believe kernel was invalidating more than  
> it should.  I will investigate further to make sure this is not happening.
>  
> > Basically, "mount" and "unmount" are slow operations.
> 
> The only problem is that it seems to get worst as the memory of the system get  
> bigger, but I'll agree with you on the SEP. So, I'll just drop
> it. :)

The more memory, the bigger the caches, the longer it takes to hunt
through them for inodes/dentries on the target filesystem.

>  
> > As you note, "unmount" can be avoided by mounting the nfsd filesystem
> > somewhere.  I recommend /proc/fs/nfsd.
> > The "mount" can be avoided by not using the nfsservctl systemcall at all.
> > This is achived by mounting nfsd at /proc/fs/nfsd, and running the latest
> > release of nfs-utils.
> 
> >From what you say here, it seems that the old nfsservctl systemcall method is  
> deprecated and the new method is the one to use.  If this a fact? Would be  
> nice to have this documented in the post-halloween document.  I could drop a  
> note to Dave Jones to have this change.

I guess.... I really wanted the syscall and the nfsd filesystem to
both work equally side by side in 2.6, and the syscall would be gone
in 2.8.  So I didn't really want to 'deprecate' it.  Just make it
disappear after everyone had a very good likelyhood of upgrading.

But it might be worth saying something to that effect in the
post-halloween document.



> 
> BTW:  What version of nfs-utils introduce this new interface for /proc/fs/ 
> nfsd?

About 1.0.4 I think, but it was buggy until 1.0.6 which is current.

NeilBrown


-------------------------------------------------------
This SF.net email is sponsored by: The SF.net Donation Program.
Do you like what SourceForge.net is doing for the Open
Source Community?  Make a contribution, and help us add new
features and functionality. Click here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
