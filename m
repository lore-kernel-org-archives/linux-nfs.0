From: Olaf Kirch <okir@suse.de>
Subject: Re: nfsd write throughput
Date: Tue, 3 Aug 2004 12:52:38 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040803105238.GH21365@suse.de>
References: <20040802162448.GB21365@suse.de> <20040803021018.GG5581@sgi.com> <20040803060213.GA21134@suse.de> <20040803075506.GL5581@sgi.com> <20040803103213.GE21365@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BrwuQ-0003M5-Kr
	for nfs@lists.sourceforge.net; Tue, 03 Aug 2004 03:52:42 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1BrwuQ-0000zt-5D
	for nfs@lists.sourceforge.net; Tue, 03 Aug 2004 03:52:42 -0700
Received: from hermes.suse.de (hermes-ext.suse.de [195.135.221.8])
	(using TLSv1 with cipher EDH-RSA-DES-CBC3-SHA (168/168 bits))
	(No client certificate requested)
	by Cantor.suse.de (Postfix) with ESMTP id 228CE9BAD3D
	for <nfs@lists.sourceforge.net>; Tue,  3 Aug 2004 12:52:39 +0200 (CEST)
To: nfs@lists.sourceforge.net
In-Reply-To: <20040803103213.GE21365@suse.de>
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

On Tue, Aug 03, 2004 at 12:32:14PM +0200, Olaf Kirch wrote:
> I'm wondering what could happen if we change nfsd_sync to not take the
> i_sem at all... I'll talk to a few VFS folks around here and try to find out.

Just for fun, I changed nfsd_sync to not take i_sem, and the
performance gain was about halfway inbetween the unmodified
nfsd and the one with the flushfast hack.

I think the reason this isn't better than flushfast is this: when several
commit calls for the same file come in (and as I mentioned, the Linux
client does send up to 80 commits per second), we end up with all nfsd
threads handling one commit, sitting in filemap_fdatawait or fsync,
waiting for the same file to be flushed.

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 


-------------------------------------------------------
This SF.Net email is sponsored by OSTG. Have you noticed the changes on
Linux.com, ITManagersJournal and NewsForge in the past few weeks? Now,
one more big change to announce. We are now OSTG- Open Source Technology
Group. Come see the changes on the new OSTG site. www.ostg.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
