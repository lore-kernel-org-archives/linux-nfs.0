From: David Dougall <davidd@et.byu.edu>
Subject: Re: file system handle
Date: Mon, 13 Dec 2004 08:41:12 -0700 (MST)
Message-ID: <Pine.LNX.4.58.0412130839540.13290@lewis.et.byu.edu>
References: <Pine.LNX.4.58.0412130809570.13290@lewis.et.byu.edu>
 <41BDB57B.2050703@moving-picture.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CdsKC-00056v-TR
	for nfs@lists.sourceforge.net; Mon, 13 Dec 2004 07:41:24 -0800
Received: from postal1.et.byu.edu ([128.187.122.131])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CdsKC-0007Gp-CB
	for nfs@lists.sourceforge.net; Mon, 13 Dec 2004 07:41:24 -0800
To: James Pearson <james-p@moving-picture.com>
In-Reply-To: <41BDB57B.2050703@moving-picture.com>
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

So, you are saying that if I add an fsid= option into the exports, the
server will work with both that filehandle and the default major/minor
number one?
--David Dougall


On Mon, 13 Dec 2004, James Pearson wrote:

> David Dougall wrote:
> > I am moving filesystems/disks to new NFS servers.  They are going to
> > change major and minor numbers.  Is there any way I can prevent stale
> > mounts with the fsid= option in the exports?
> > I have tried this on a test environment, but when I try to create an fsid=
> > option, it completely changes the filehandle format in the nfs packet.  Am
> > I missing something, or are the default and forced fsid options
> > incompatible?
>
> I believe using the fsid= option does use a different file handle id
> type, so you can't directly do what you want with the fsid option.
>
> However, you can re-export a file system with an added fsid= option -
> any existing mounts will still use the 'previous' file handle type based
> on the device id, but new mounts will use the new fsid file handle. You
> then will have to make sure all existing clients remount the file system
> before moving the disks.
>
> I've done this before - but I had to make the export change well in
> advance, so that I could make sure all existing clients remounted the
> file system before the move.
>
> James Pearson
>
>
>


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
