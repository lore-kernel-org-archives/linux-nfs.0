From: Peter Fedorow <fedorowp@earthlink.net>
Subject: Hard link to symbolic link hack
Date: Mon, 23 Jun 2003 18:49:26 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EF783F6.10508@earthlink.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mallard.mail.pas.earthlink.net ([207.217.120.48])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Ua8c-0001zV-00
	for <nfs@lists.sourceforge.net>; Mon, 23 Jun 2003 15:50:14 -0700
Received: from user-12hdh6r.cable.mindspring.com ([69.22.196.219] helo=earthlink.net)
	by mallard.mail.pas.earthlink.net with esmtp (Exim 3.33 #1)
	id 19Ua8Z-0006MR-00
	for nfs@lists.sourceforge.net; Mon, 23 Jun 2003 15:50:12 -0700
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi,
I need to install some software who's installer generates hard links to 
  and NFS server which does not support them.

What changes need to be made to nfs_proc_link to map the hard links to 
symlinks?

-------------------

static int
nfs_proc_link(struct inode *inode, struct inode *dir, struct qstr *name)
{
	struct nfs_linkargs	arg = { NFS_FH(inode), NFS_FH(dir),
					name->name, name->len };
	int			status;

	dprintk("NFS call  link %s\n", name->name);
	status = rpc_call(NFS_CLIENT(inode), NFSPROC_LINK, &arg, NULL, 0);
	dprintk("NFS reply link: %d\n", status);
	return status;
}

-------------------

static int
nfs_proc_symlink(struct inode *dir, struct qstr *name, struct qstr *path,
		 struct iattr *sattr, struct nfs_fh *fhandle,
		 struct nfs_fattr *fattr)
{
	struct nfs_symlinkargs	arg = { NFS_FH(dir), name->name, name->len,
					path->name, path->len, sattr };
	int			status;

	dprintk("NFS call  symlink %s -> %s\n", name->name, path->name);
	fattr->valid = 0;
	status = rpc_call(NFS_CLIENT(dir), NFSPROC_SYMLINK, &arg, NULL, 0);
	dprintk("NFS reply symlink: %d\n", status);
	return status;
}



-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
