From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: corruption over NFS with 2.6 client, locking, truncating and
 appending...
Date: Tue, 5 Apr 2005 11:39:33 +1000
Message-ID: <16977.60501.153237.389021@cse.unsw.edu.au>
References: <16977.57630.766727.608029@cse.unsw.edu.au>
	<1112664792.11910.12.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DIdx2-0008BU-Gy
	for nfs@lists.sourceforge.net; Mon, 04 Apr 2005 19:38:00 -0700
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DIdx1-0006cz-2c
	for nfs@lists.sourceforge.net; Mon, 04 Apr 2005 19:38:00 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by externalmx-1.sourceforge.net with esmtp (Exim 4.41)
	id 1DId7a-0000nJ-Me
	for nfs@lists.sourceforge.net; Mon, 04 Apr 2005 18:44:51 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: message from Trond Myklebust on Monday April 4
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

On Monday April 4, trond.myklebust@fys.uio.no wrote:
> ty den 05.04.2005 Klokka 10:51 (+1000) skreiv Neil Brown:
> 
> > 		switch(*action) {
> > 		case 'a': /* append */
> > 			off = lseek(fd, 0, SEEK_END);
> > 			sprintf(buf, "%09lu\n", off);
> > 			write(fd, buf, 10);
> > 			fsync(fd);
> > 			break;
> 
> Argh... OK, I see the problem here.
> 
> When you call lseek(SEEK_END), the kernel really needs to be calling
> nfs_revalidate_inode() in order to update the cached attribute info.
> Currently that is not the case, since we just default to the VFS
> generic_file_llseek().
> 
> I'll code something up in the morning.

Thanks.

Your explanation would explain that value of 'off' being wrong as I
found with the lockf locking in 2.4. 
However as the file was open for O_APPEND, there would be an implicit
seek to the end on every write.  Is this implicit seek expected to do
the right thing or would it need fixing too?

NeilBrown


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
