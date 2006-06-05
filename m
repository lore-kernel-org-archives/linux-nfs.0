From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFS4 and host restrictions
Date: Mon, 5 Jun 2006 13:09:14 -0400
Message-ID: <20060605170914.GI16064@fieldses.org>
References: <20060605092321.GA25450@daper.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FnIaE-0003lT-UK
	for nfs@lists.sourceforge.net; Mon, 05 Jun 2006 10:09:43 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FnIaC-00024x-1A
	for nfs@lists.sourceforge.net; Mon, 05 Jun 2006 10:09:42 -0700
To: Damian Pietras <daper@daper.net>
In-Reply-To: <20060605092321.GA25450@daper.net>
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

On Mon, Jun 05, 2006 at 11:23:21AM +0200, Damian Pietras wrote:
> /nfs4 *(rw,sync,fsid=0)
> /nfs4/host1dir host1(rw,sync)
> /nfs4/host2dir host2(rw,sync)
> 
> This allows anyone to mount /nfs4/host1dir and /nfs4/host2dir

It'll let anyone mount those paths, but it shouldn't actually let you
see the contents of any filesystems mounted at those paths.

--b.


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
