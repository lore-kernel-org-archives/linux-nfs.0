From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [Linux-cluster] [RFC] NLM lock failover admin interface
Date: Mon, 12 Jun 2006 11:00:53 -0400
Message-ID: <20060612150053.GC31596@fieldses.org>
References: <1150089943.26019.18.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FpnuT-0005qK-HH
	for nfs@lists.sourceforge.net; Mon, 12 Jun 2006 08:00:57 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FpnuS-0004CU-GF
	for nfs@lists.sourceforge.net; Mon, 12 Jun 2006 08:00:57 -0700
To: linux clustering <linux-cluster@redhat.com>
In-Reply-To: <1150089943.26019.18.camel@localhost.localdomain>
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

On Mon, Jun 12, 2006 at 01:25:43AM -0400, Wendy Cheng wrote:
> 2. Adding a new flag into "exportfs" command, say "h", such that
> 
>    "exportfs -uh *:/export_path"
> 
> would un-export the entry and drop the NLM locks associated with the
> entry.

What does the kernel interface end up looking like in that case?

--b.


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
