From: Andrew Morton <akpm@digeo.com>
Subject: Re: [PATCH] Convert NFS client to use ->readpages()
Date: Wed, 06 Nov 2002 01:34:50 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3DC8E23A.2578323F@digeo.com>
References: <shssmyfe8nt.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
        NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from packet.digeo.com ([12.110.80.53])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 189MaP-0005Tv-00
	for <nfs@lists.sourceforge.net>; Wed, 06 Nov 2002 01:34:57 -0800
Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id BAA05671
	for <nfs@lists.sourceforge.net>; Wed, 6 Nov 2002 01:34:51 -0800 (PST)
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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

Trond Myklebust wrote:
> 
> +int
> +nfs_readpages(struct file *filp, struct address_space *mapping,
> +               struct list_head *pages, unsigned nr_pages)
> +{
> +       LIST_HEAD(head);
> +       struct nfs_readdesc desc = {
> +               .filp           = filp,
> +               .head           = &head,
> +       };
> +       struct nfs_server *server = NFS_SERVER(mapping->host);
> +       int is_sync = server->rsize < PAGE_CACHE_SIZE;
> +       int ret;
> +
> +       ret = read_cache_pages(mapping, pages,
> +                              is_sync ? readpage_sync_filler :
> +                                        readpage_async_filler,
> +                              &desc);
> +       if (!list_empty(pages)) {
> +               struct page *page = list_entry(pages->prev, struct page, list);
> +               list_del(&page->list);
> +               page_cache_release(page);
> +       }

What are the above few lines doing?  Looks odd.

Or should it be

	while (!list_empty(...))

?

> +       if (!list_empty(&head)) {
> +               int err = nfs_pagein_list(&head, server->rpages);
> +               if (!ret)
> +                       ret = err;
> +       }
> +       return ret;
> +}
> +


-------------------------------------------------------
This sf.net email is sponsored by: See the NEW Palm 
Tungsten T handheld. Power & Color in a compact size!
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
