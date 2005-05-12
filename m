From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Stale File handles keep coming back
Date: Thu, 12 May 2005 11:14:09 +1000
Message-ID: <17026.44513.429648.189605@cse.unsw.edu.au>
References: <1114463253.2487.73.camel@localhost.localdomain>
	<17006.13241.129839.558300@cse.unsw.edu.au>
	<1115155275.2894.20.camel@localhost.localdomain>
	<42786148.1000201@bio.ifi.lmu.de>
	<1115859694.23663.3.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DW2HL-0004Fd-GU
	for nfs@lists.sourceforge.net; Wed, 11 May 2005 18:14:19 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DW2HJ-0001UA-PP
	for nfs@lists.sourceforge.net; Wed, 11 May 2005 18:14:19 -0700
To: Kris Vassallo <kris@linuxcertified.com>
In-Reply-To: message from Kris Vassallo on Wednesday May 11
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

On Wednesday May 11, kris@linuxcertified.com wrote:
> Ok, well I have found very good success in killing this stupid stale
> file handle problem in the 2.6.11 kernel by switching from ext3 to ext2
> and then rebooting. For the past 5 days not 1 of my developers has
> complained about this issue. 
> Obviously if this machine goes down and a fsck starts running on the 750
> GB of data, I am in some deep doo doo, but for now I am using this as a
> way of getting around the problem until someone comes up with a nifty
> patch. 

It seems likely that this problem is related to the b-tree based
directory indexing use in ext3.

You could try using tune2fs to make sure this is turned off, and try
ext3 again.

NeilBrown


-------------------------------------------------------
This SF.Net email is sponsored by Oracle Space Sweepstakes
Want to be the first software developer in space?
Enter now for the Oracle Space Sweepstakes!
http://ads.osdn.com/?ad_id=7393&alloc_id=16281&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
