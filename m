From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] NFS Digest, Vol 18, Issue 70 (NFS performance problems)
Date: Sun, 25 Nov 2007 23:41:49 -0500
Message-ID: <1196052109.7804.7.camel@heimdal.trondhjem.org>
References: <mailman.194659.1195581701.26582.nfs@lists.sourceforge.net>
	<BAY104-W43766F661E50E7FFCDA8EBA7F0@phx.gbl>	<47434ED7.4010100@redhat.com>
	<47435049.1010800@redhat.com> <47445727.5090705@oracle.com>
	<474A3D6B.2060208@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: chuck.lever@oracle.com, nfs@lists.sourceforge.net
To: wcheng@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IwVnK-00079g-F0
	for nfs@lists.sourceforge.net; Sun, 25 Nov 2007 20:42:06 -0800
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IwVnQ-0003QF-2n
	for nfs@lists.sourceforge.net; Sun, 25 Nov 2007 20:42:12 -0800
In-Reply-To: <474A3D6B.2060208@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


On Sun, 2007-11-25 at 22:28 -0500, Wendy Cheng wrote:
> Setting aside NFS for a moment...  for a locally mounted filesystem, the 
> file data stays in the cache until write-back occurs. Upon crashing, 
> there are always possibilities that the data could be lost. Journaling 
> filesystems such as EXT3 can only ensure no meta-data corruption, there 
> is no guarantee that data would be saved unless the filesystem is 
> mounted with "sync" option. With non-trivial performance hits, most of 
> the filesystems are hardly mounted with "sync" option. Applications 
> normally understand the problem and whenever required, fsync() and/or 
> similar mechanisms are applied.
> 
> For Linux NFS servers to deviate from this common practice, by reading 
> the FAQ, I assume something has been done (particularly from client 
> ends) to alleviate the performance hit ? Could you elaborate more about 
> this ?
> 
> Again, I'm not trying to argue and/or start a flamewar. I have a need to 
> understand more about this issue. The "sync" operation is very expensive 
> for us (cluster filesystem) and I'm under the gun to improve our NFS 
> file serving performance at this moment.

You've got it wrong. The 'async' option was the Linux-specific option
that violates the NFS spec, not 'sync'.

Please read the RFCs: NFS has always imposed strict requirements on the
server w.r.t. data integrity. 'async' violates those requirements
because it allows the server to cache data in circumstances where the
client is under the belief that the data is on permanent storage.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

