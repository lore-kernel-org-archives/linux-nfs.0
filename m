From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: async vs. sync
Date: Thu, 25 Nov 2004 09:09:29 +1100
Message-ID: <16805.1689.739687.36138@cse.unsw.edu.au>
References: <482A3FA0050D21419C269D13989C611307CF4B56@lavender-fe.eng.netapp.com>
	<41A3AFC4.6080404@int-evry.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Lever, Charles" <Charles.Lever@netapp.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CX5KY-0004Zv-86
	for nfs@lists.sourceforge.net; Wed, 24 Nov 2004 14:09:42 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CX5KW-00048s-Vs
	for nfs@lists.sourceforge.net; Wed, 24 Nov 2004 14:09:42 -0800
To: jehan procaccia <jehan.procaccia@int-evry.fr>
In-Reply-To: message from jehan procaccia on Tuesday November 23
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

On Tuesday November 23, jehan.procaccia@int-evry.fr wrote:
> 
> Perhaps it's not the place to talk about ext3 here, but if someone on 
> the list did already put their journal on a separate device, please 
> confirm me those points:
>  From what I read on man mkefs for ext3 FS I can create a journal on a 
> separate FS :
> mke2fs -O journal_dev external-journal
> creates the journal FS, on which device ? -> internal scsi drive of my 
> server or better placed on the dell/EMC SP ?

Any device that is reliable and will respond very quickly to
sequential writes is fine.  A dedicated mirrored pair of fast SCSI drives is
ideal if you can afford it.
If the "dell/EMC SP" can be configured to provide a mirrored pair of
other-wise lightly used drives, then a partition on that would be
fine.
If you put the journal on a single drive, then a failure of that drive
will cost you some data loss, and a full 'fsck' of the main storage.

I put my journals on internal drives.  One cost of this is if the
server dies (e.g. bad power supply) then you need to move the internal
drives to some other computer before you can get your data back.  This
can be trivial, or frustratingly difficult(*).

> 
> mke2fs -J device=/dev/external-journal /dev/emcpower
> Format the FS and use the external journal just create above, but what is the recommended size of the 
> external journal ?  when journal is internal it is said  the size of the journal must be at least 1024 filesystem blocks
> (in my case blocks a 4K size) so journal is at least 4 Mb, but
> should it be bigger ?

I think 1gigabyte is a good size - probably much bigger than needed,
but not too big.  I wouldn't go below 128Meg myself.

I once had a 6gig journal (because there was plenty of space, so "why
not").
I found out why not:  On restart ext3 has to scan the whole journal.
For a 6gig journal that takes a while.  Not as long as fsck, but still
too long.

> 
> Finally, can I "externalize" an already internal journal from
> production FS  (convert journal from inside to outside without
> reformating the FS ) ? 

Yes, but not while the filesystem is mounted.

Use tune2fs to remove the internal journal:
   tune2fs -O ^has_journal
create an external journal
   mke2fs -O journal_dev /dev/external-journal
and attach the journal to the fs
   tune2fs -J device=/dev/external-journal

then re-mount.

NeilBrown

(*) I recently needed to move a large filesystem that was on an
external drive box from a failing machine to another machine.  Both
had hot-swap scsi drives for the internal system discs though they
were from different manufacturers.  
The drive caddies were different but unscrewing a drive from one and
putting it in the other didn't seem like too much trouble .... until
we tried it.  The caddy from one manufacturer was designed so there
was no tolerance. A drive 0.5mm larger than the one they provided
simply didn't fit.  The drive I wanted to put in was 0.5mm larger :-(

Fortunately, as it was a controlled change over, we could detach the
journal on the system discs of one machine and re-attach a new journal
on the other.  If the first computer had blown up instead of started
failing occasionally, it would have been *much* more awkward.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
