From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: i_generation = 0 special casing
Date: Thu, 25 Nov 2004 09:48:03 +1100
Message-ID: <16805.4003.661292.438937@cse.unsw.edu.au>
References: <20041124094320.GA10206@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CX5vj-0007wV-U2
	for nfs@lists.sourceforge.net; Wed, 24 Nov 2004 14:48:07 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CX5vi-0005Rj-VQ
	for nfs@lists.sourceforge.net; Wed, 24 Nov 2004 14:48:07 -0800
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: message from Christoph Hellwig on Wednesday November 24
Sender: nfs-admin@lists.sourceforge.net
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

On Wednesday November 24, hch@infradead.org wrote:
> export_iget (and routines based on it such as xfs_vget) check for
> i_generation beeing 0 meaning that every generation is okay.  Where in
> the NFS code is this wildcard needed?

On reflection, it is largely a coding convenience :-(

A filehandle can identify both an object, and it's parent directory.
An earlier version of the filehandle (2.2 kernel) contained the
generation number for the object, but not for the parent direction.
To stay compatible with that, we need to cope with not knowing the
generation number.

So the routine that finds a dentry given inode number and generation
number needs to be able to be told "I don't know the generation
number, just accept whatever you find", as that is safe enough when
hunting for the parent directory (if you get the wrong thing by
mistake, you will find out some other way).

To tell the "inum+generation -> dentry" routine "don't worry about the
gernation number", we use a generation number of 0.  This obviously
has problems as you have noted.

It should probably be changed to have an explicit "ignore the
generation number" flag, or just possibly require callers to map '0'
to (e.g.) 1 when passing in a genuine generation number (whether for
filehandle creation or lookup).

> 
> I had to find out that XFS starts it's i_generation at zero and either
> I have to fix up the i_generation or drop this wildcard if it's not
> actually used.

It would certainly be easiest to simply not have generation numbers
ever being zero, but it isn't a nice requirement to put on a
filesystem.

However I cannot immediately see a real solution that is anything
close to clean.  I might try again in a week or so and see if anything
comes to mind.

NeilBrown



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
