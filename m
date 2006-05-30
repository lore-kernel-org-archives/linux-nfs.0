From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: 2.4 vs 2.6
Date: Mon, 29 May 2006 21:59:18 -0400
Message-ID: <20060530015918.GA27940@fieldses.org>
References: <17526.44653.228663.713864@cse.unsw.edu.au> <20060526081905.73641.qmail@web51609.mail.yahoo.com> <20060526193118.GB17761@fieldses.org> <17530.36039.227704.325645@cse.unsw.edu.au> <20060529160236.GC6832@fieldses.org> <20060530011208.GB12818@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>,
	mehta kiran <kiranmehta1981@yahoo.com>, nfs@lists.sourceforge.net,
	Vijay Chauhan <kernel.vijay@gmail.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FktW1-0001I0-0n
	for nfs@lists.sourceforge.net; Mon, 29 May 2006 18:59:25 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FktVz-0004If-Pa
	for nfs@lists.sourceforge.net; Mon, 29 May 2006 18:59:25 -0700
To: Greg Banks <gnb@sgi.com>
In-Reply-To: <20060530011208.GB12818@sgi.com>
Sender: nfs-admin@lists.sourceforge.net
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

On Tue, May 30, 2006 at 11:12:08AM +1000, Greg Banks wrote:
> On Mon, May 29, 2006 at 12:02:36PM -0400, J. Bruce Fields wrote:
> > I don't see why this *has* to be done on demand, though, unless the
> > export table is extremely large and only sparsely used.  I might be
> > missing something.
> 
> /mnt/data *.domain1.company.com(ro,sync) *.domain2.company.com(rw,sync)

I realize that the ip->client-name mapping is too large to preload into
the kernel.

It's the (path, client-name) --> export options that I wonder about.

--b.


-------------------------------------------------------
All the advantages of Linux Managed Hosting--Without the Cost and Risk!
Fully trained technicians. The highest number of Red Hat certifications in
the hosting industry. Fanatical Support. Click to learn more
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=107521&bid=248729&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
