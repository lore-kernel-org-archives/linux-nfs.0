From: Abhishek Rai <abbashake007@yahoo.com>
Subject: queer error in kernel
Date: Mon, 21 Apr 2003 00:45:11 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030421074511.61529.qmail@web11406.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from web11406.mail.yahoo.com ([216.136.131.236])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 197VzD-0001tx-00
	for <nfs@lists.sourceforge.net>; Mon, 21 Apr 2003 00:45:11 -0700
To: nfs@lists.sourceforge.net
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

Hi,
  I have a small hack for the linux kernel's nfs
module which was working just fine before the
following code was introduced:

static void nfs_print_path(struct dentry *d) {
	struct dentry *parent;
	struct inode *inode_parent, *inode;
	unsigned long p, me;

	if(!d) {
		return;
	}	
	parent = d->d_parent;
	
	if(parent) {
		inode_parent = parent->d_inode;
		inode = d->d_inode;
// till here everything works just fine
		
/* the following code just doesn't work. None of it
works, neither the assignments to 'p' and 'me', nor
the printk, nor the comparision in the if statement
after that. I tested each of these 3 different cases
separately and each time i got the same error (see
below) */
                p = (unsigned long)inode_parent;
		me = (unsigned long)inode;

		printk("parent inode: %x child inode: %x\n",
inode_parent, inode);

                if( ((char *)inode_parent == 
                              (char *)inode) ) { 
		       
............
}


I got an error something like this: Kernel couldn't
dereference pointer 00...0f blah blah blah...
(If sb feels the need, i'll send the complete error)		
As i see it, there is error in just 'reading' the
values of the variable 'inode_parent' and 'inode'. But
considering the object code the C Compiler must have
produced, there is nothing that actually *does* some
real task - all that is being done is reading some
arbit value from the function's stack: whats so wrong
with that ???

thanks in advance
abhishek


__________________________________________________
Do you Yahoo!?
The New Yahoo! Search - Faster. Easier. Bingo
http://search.yahoo.com


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
