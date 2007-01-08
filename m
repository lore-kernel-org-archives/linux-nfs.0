From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: setacl, data caching
Date: Mon, 08 Jan 2007 18:58:16 -0500
Message-ID: <1168300696.6964.49.camel@lade.trondhjem.org>
References: <20070108212848.GB1686@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H44Nt-00009K-3s
	for nfs@lists.sourceforge.net; Mon, 08 Jan 2007 15:58:33 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1H44Ns-0000OF-O7
	for nfs@lists.sourceforge.net; Mon, 08 Jan 2007 15:58:34 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20070108212848.GB1686@fieldses.org>
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

On Mon, 2007-01-08 at 16:28 -0500, J. Bruce Fields wrote:
> Why does the nfs3_proc_setacls() need the begin_data_update() and
> end_data_update()?:
> 
> 	nfs_begin_data_update(inode);
>         msg.rpc_proc = &server->client_acl->cl_procinfo[ACLPROC3_SETACL];
>         status = rpc_call_sync(server->client_acl, &msg, 0);
>         spin_lock(&inode->i_lock);
>         NFS_I(inode)->cache_validity |= NFS_INO_INVALID_ACCESS;
>         spin_unlock(&inode->i_lock);
>         nfs_end_data_update(inode);
> 
> It looks like the effect of those are to invalidate the page cache for that
> inode.  Why do we want to do that when we modify the ACL?

The cache invalidation is only true for directories, however even there
it is not strictly necessary. What is necessary, though, is to declare
the attribute cache as unstable while the setacl call is on the wire.

Note that we have a similar inefficiency in nfs_rename().

Cheers,
  Trond

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
