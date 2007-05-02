From: Ian Kent <raven@themaw.net>
Subject: Re: time_after cannot be used alone by NFS code in
	32bit	architectures
Date: Wed, 02 May 2007 19:52:50 +0800
Message-ID: <1178106770.5960.28.camel@raven.themaw.net>
References: <20070426043344.GO10449@sleipnir.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs <nfs@lists.sourceforge.net>
To: Fabio Olive Leite <fleite@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HjDPn-0002Ay-Oe
	for nfs@lists.sourceforge.net; Wed, 02 May 2007 04:54:36 -0700
Received: from out1.smtp.messagingengine.com ([66.111.4.25])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HjDPo-0008Sh-V9
	for nfs@lists.sourceforge.net; Wed, 02 May 2007 04:54:38 -0700
In-Reply-To: <20070426043344.GO10449@sleipnir.redhat.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, 2007-04-26 at 01:33 -0300, Fabio Olive Leite wrote: 
> This leads to several problematic situations in long-lived NFS mounts.
> We can see old attributes not being updated, negative dentries that do
> not revalidate even after touching their parent dir, etc.
> 

This is quite an interesting issue and I'm still having trouble
understanding it so let me try and explain my understanding of part of
it.

Lets consider the d_fsdata field of a negative dentry and the
nfs_neg_need_reval() function. Assuming no in progress io and the
request is not an exclusive open then nfs_neg_need_reval() will return
false when d_fsdata is after the modification timestamp of the
directory. This leads to the dentry being considered valid and so no
(VFS) lookup is performed. This is the only problem case I can see here
because otherwise the dentry is unhashed by nfs_lookup_revalidate()
forcing a new (VFS) lookup to be done (assuming the reference count of
the negative dentry is really 0).

So the problem you describe actually happens when the directory inode
cache_change_attribute warps and the dentry d_fstada timestamp is later
than inode cache_change_attribute. So updating the
cache_change_attribute field, as in the patch that Neil referred to,
will often not fix it.

Have I got this right yet?

Ian



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
