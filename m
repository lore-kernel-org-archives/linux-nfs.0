From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: CITI page up to date?
Date: Tue, 13 Apr 2004 12:54:48 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040413165448.GA25896@fieldses.org>
References: <200404131319.19518.vincent.roqueta@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BDRBZ-0005jL-5z
	for nfs@lists.sourceforge.net; Tue, 13 Apr 2004 09:54:57 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net
	([66.93.2.214] helo=pumpkin.fieldses.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BDRBY-0005HV-Qq
	for nfs@lists.sourceforge.net; Tue, 13 Apr 2004 09:54:57 -0700
To: Vincent ROQUETA <vincent.roqueta@ext.bull.net>
In-Reply-To: <200404131319.19518.vincent.roqueta@ext.bull.net>
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

On Tue, Apr 13, 2004 at 01:19:19PM +0200, Vincent ROQUETA wrote:
> logs (without idmapd):
> Apr 13 09:11:53 nfs2 kernel: decode_getfattr: xdr error 5!
> Apr 13 09:11:53 nfs2 kernel: nfs_get_root: getattr error = 5
> Apr 13 09:11:53 nfs2 kernel: nfs_read_super: get root inode failed

Currently idmapd must be running on the client and the server for
anything to work.

> logs (with idmapd)
> Apr 13 10:31:01 nfs2 kernel: decode_getfattr: xdr error 10008!
> Apr 13 10:31:01 nfs2 kernel: nfs4_map_errors could not handle NFSv4 error 
> 10008
> Apr 13 10:31:01 nfs2 kernel: nfs_get_root: getattr error = 5
> Apr 13 10:31:01 nfs2 kernel: nfs_read_super: get root inode failed

There are some idmap fixes in the latest kernel patch:

http://www.citi.umich.edu/projects/nfsv4/linux/kernel-patches/2.6.5-1/linux-2.6.5-CITI_NFS4_ALL.dif

Could you try that (no need to rebuild the other stuff) and let me know
if that solves the problem?  Thanks.--b.


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
