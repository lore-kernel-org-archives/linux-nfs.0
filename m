From: Olaf Kirch <okir@suse.de>
Subject: [PATCH] groups_alloc(0) badness
Date: Tue, 6 Apr 2004 15:43:30 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040406134330.GE29906@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: nfs@lists.sourceforge.net, Marcus Meissner <meissner@suse.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BAqrV-0004UD-Aq
	for nfs@lists.sourceforge.net; Tue, 06 Apr 2004 06:43:33 -0700
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BAqrV-00074U-1v
	for nfs@lists.sourceforge.net; Tue, 06 Apr 2004 06:43:33 -0700
Received: from hermes.suse.de (Hermes.suse.de [195.135.221.8])
	(using TLSv1 with cipher EDH-RSA-DES-CBC3-SHA (168/168 bits))
	(No client certificate requested)
	by Cantor.suse.de (Postfix) with ESMTP id 0E7E63FB4AC
	for <nfs@lists.sourceforge.net>; Tue,  6 Apr 2004 15:43:31 +0200 (CEST)
To: akpm@suse.de
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

Hi,

We're looking into an nfsd oops that is caused by a corrupted
group_info struct. I haven't nailed down the exact cause of
the oops, but Marcus Meissner pointed out one problem in
the current groups_alloc code.

When we do groups_alloc(0), which can happen e.g. in the nfsd
code, the code allocates a group_info struct with _no_ space for
group_info->blocks. Nevertheless it proceeds to set 
group_info->blocks[0] = group_info->small_block, clobbering whatever is
after the group_info block.

Here's a pseudo-diff to kernel/sys.c:groups_alloc:
------------------------------------------------------------------

        nblocks = (gidsetsize/NGROUPS_PER_BLOCK) +
            (gidsetsize%NGROUPS_PER_BLOCK?1:0);
+	if (unlikely(nblocks == 0))
+		nblocks = 1
        group_info = kmalloc(sizeof(*group_info) + nblocks*sizeof(gid_t *),
            GFP_USER);
        if (!group_info)

------------------------------------------------------------------

Cheers
Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
