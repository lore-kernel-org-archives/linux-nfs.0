From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Configuring NFS service for speed - Re: async vs. sync
Date: Tue, 23 Nov 2004 09:34:59 +1100
Message-ID: <16802.27027.931420.574610@cse.unsw.edu.au>
References: <482A3FA0050D21419C269D13989C61130435EB6E@lavender-fe.eng.netapp.com>
	<20041122153655.GH1291@suse.de>
	<41A2280B.1010005@int-evry.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CWMmB-0002Rd-O7
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 14:35:15 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CWMm6-00048s-Vw
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 14:35:14 -0800
To: "jehan.procaccia" <jehan.procaccia@int-evry.fr>
In-Reply-To: message from jehan.procaccia on Monday November 22
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

On Monday November 22, jehan.procaccia@int-evry.fr wrote:
> 
> My users won't accept the sync performances ! . I have no choice, but is 
> running in async mode is really evil as you mentioned it ? is there a 
> way to have better performances in sync in my case ?  As anyone had the 
> same gap in performance as me ( here 55 times longer in sync mode !)  ?

The best way to get good nfs performance with a sync export is to use
a data-journalling filesystem, and have the journal somewhere fast.

I use ext3.  I believe that some other filesystems support data
journalling, but I don't know the details.

An ext3 filesystem exported with "data=journal" is significantly
faster that with the default "data=ordered".

With ext3, it also helps to export with the "no_wdelay" export
option.  I'm not entirely sure why this helps, and I haven't confirmed
that it is still the case (I discovered this at least 2 years ago) but
it is worth checking in your environment.

Ext3 supports having the journal on a separate device.  If you put it
on a fast device, you will get faster response.

One option is to buy an NV-RAM card and put the journal on that.
www.umem.com is one supplier that I know of.  There are doubtlessly
others.

Another option is to put it on a separate drive, or preferably a
separate mirrored pair.  As journal writes are sequential, you won't
suffer seek time on the journal device and it will be quite fast.

My typical fileserver configuration is to have a pair of small (36gig
is the smallest I can easily get) 15K SCSI drives as a mirrored pair,
and to put root, swap, and a journal partition on this.
Then a separate box contains a dozen or so drives of whatever size I
want in a raid5 configuration.  The ext3 filesystem is on the raid5
array, the journal is on the mirrored pair with root and swap.  There
is almost no IO to root and swap, so the journal gets the drives
almost to itself.
This configuration is adequately fast.

NeilBrown


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
