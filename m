From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: RE: [PATCH] kNFSd - 2 of 7 - Revlaidate inodes after filehandle and name lookup in nfsd
Date: Wed, 18 Dec 2002 09:50:53 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15871.43597.215534.671112@notabene.cse.unsw.edu.au>
References: <E18O714-0000ot-00@notabene.cse.unsw.edu.au>
	<000201c2a5d9$adcec250$6902a8c0@Iralaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>,
    "'Brian Dixon'" <dixonbp@us.ibm.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18OQYN-0005jI-00
	for <nfs@lists.sourceforge.net>; Tue, 17 Dec 2002 14:51:07 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <ira@ibrix.com>) (for <nfs@lists.sourceforge.net>)
	(for <dixonbp@us.ibm.com>) By tone With Smtp ;
	Wed, 18 Dec 2002 09:51:00 +1100
To: "Irina Slutsky" <ira@ibrix.com>
In-Reply-To: message from Irina Slutsky on Tuesday December 17
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

On Tuesday December 17, ira@ibrix.com wrote:
> Thanks for this patch. Problem, this patch is addressing is very
> important for me. This is the behaviors I am missing and is trying to
> work around. When do you think this patch can be incorporated in the
> official kernel release?

Hopefully in 2.4.21, whenever that comes out.

> 
> Small note: there is an inline routine 
> do_reavlidate(struct denty *) in the kernel
> that could be used instead. It has all the "if"s checking inside.

So there is... but it is in lots of .c files and no .h's.
I guess I could copy it but I don't know that it is worth it.

> 
> I also have a question on the same topic:
> 
> Is there any particular reason for not allowing a fs to create file
> handle for exported entry? I know the code is easier this way, but it
> would be very useful. 

It isn't so much that it is not "allowed", but rather that it is not
"required".  knfsd can find the file without any help from the
filesystem, so it doesn't even both to ask.

How would it be useful to you if it did?

NeilBrown


-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
