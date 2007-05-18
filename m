From: Ian Kent <raven@themaw.net>
Subject: Re: [PATCH 1/2] NFS: Add the mount option "nosharecache"
Date: Fri, 18 May 2007 11:12:26 +0800
Message-ID: <1179457946.3726.3.camel@raven.themaw.net>
References: <17994.32412.173039.15055@notabene.brown>
	<20070517021318.32447.94991.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, Paul Krizak <paul.krizak@amd.com>,
	nfs@lists.sourceforge.net
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HostN-0003qr-Dd
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 20:12:33 -0700
Received: from out1.smtp.messagingengine.com ([66.111.4.25])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HostP-0007lE-2v
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 20:12:36 -0700
In-Reply-To: <20070517021318.32447.94991.stgit@heimdal.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wed, 2007-05-16 at 22:13 -0400, Trond Myklebust wrote:
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> Prior to David Howell's mount changes in 2.6.18, users who mounted
> different directories which happened to be from the same filesystem on the
> server would get different super blocks, and hence could choose different
> mount options. As long as there were no hard linked files that crossed from
> one subtree to another, this was quite safe.
> Post the changes, if the two directories are on the same filesystem (have
> the same 'fsid'), they will share the same super block, and hence the same
> mount options.
> 
> Add a flag to allow users to elect not to share the NFS super block with
> another mount point, even if the fsids are the same. This will allow
> users to set different mount options for the two different super blocks, as
> was previously possible. It is still up to the user to ensure that there
> are no cache coherency issues when doing this, however the default
> behaviour will be to share super blocks whenever two paths result in
> the same fsid.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

This looks great, thanks Trond.

I've been wondering about a couple things.

How will the "read-only bind mounts" VFS changes affect this?
When the fscache patches are merged how will this it be affect by this?

Comments please?

Ian



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
