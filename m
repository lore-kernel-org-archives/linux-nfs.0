From: "Bill Rugolsky Jr." <brugolsky@telemetry-investments.com>
Subject: Re: knfsd brought to its knees, by a simple rsync or cp operation
Date: Tue, 1 Mar 2005 11:08:07 -0500
Message-ID: <20050301160806.GE4848@ti64.telemetry-investments.com>
References: <20050226082854.2a496ec3@be.back.l8r.net> <20050228100633.GA4822@suse.de> <20050228102307.3788a184@be.back.l8r.net> <20050228154455.GS4822@suse.de> <20050228112018.34fdeb2b@be.back.l8r.net> <20050301095548.GJ14402@suse.de> <20050301065703.7e52cf4e@be.back.l8r.net> <20050301150446.GD4848@ti64.telemetry-investments.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D69vC-0007TM-0i
	for nfs@lists.sourceforge.net; Tue, 01 Mar 2005 08:08:30 -0800
Received: from 209-166-240-202.cust.walrus.com ([209.166.240.202] helo=ti41.telemetry-investments.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D69uu-000509-Um
	for nfs@lists.sourceforge.net; Tue, 01 Mar 2005 08:08:29 -0800
To: Brad Barnett <lists@L8R.net>
In-Reply-To: <20050301150446.GD4848@ti64.telemetry-investments.com>
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

On Tue, Mar 01, 2005 at 10:04:46AM -0500, Bill Rugolsky Jr. wrote:
> How about ls -lR /raid/home on the server?  It could be that knfsd is
> returning file attribute information, hence reading the whole inode
> for each file, and not just for the directories.  getdents64() returns
> d_type=DT_DIR for directory entries, which allows ls -R to optimize the
> traversal so as to only call fstat64() on directories, not regular files.
> So on the server, ls -R would only fstat64() the entries, while
> on the client ls -R can cause knfsd to do the equivalent of ls -lR.

Sorry for replying to myself; I've had a look at the 2.6.10 code, and I think
I may understand what is going on.

In the *ideal* case, the client NFS and server NFS implementations support
READDIRPLUS.  Additionally, the filesystem stores the file type in the
directory entry; such is the case with EXT3 with the "filetype" feature.

If all of the above is true, when a directory is read on the client,
the nfs client issues a READDIRPLUS call to the server.  The server in
turn, issues a readdir to the VFS, which will call down into the underlying
filesystem.  If the underlying filesystem stores type information in the
directory, then it will populate the the type field, and this can then
be returned to the caller without reading the on-disk inode.

If the filesystem does not store filetype information in the directory,
then filldir() on the server will return with DT_UNKNOWN, and this will
get passed back to the getdents64() caller (ls), which then has to
[f]stat() the file, which will translate into a GETATTR call, which
will require reading the on-disk inode.  If the client or server doesn't
implement READDIRPLUS, then the nfs client will be unable to receive the
type information, and will either have to return DT_UNKNOWN to satisfy
the getdents64 call, will issue a GETATTR on each directory entry itself.

Note that READDIRPLUS is missing from many/most deployed 2.4 kernels, though
patches are at client.linux-nfs.org.

	Bill Rugolsky


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
