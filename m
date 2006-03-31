From: Olaf Kirch <okir@suse.de>
Subject: Re: NFS directio
Date: Fri, 31 Mar 2006 16:58:49 +0200
Message-ID: <20060331145849.GF18629@suse.de>
References: <20060330151544.GA11915@suse.de> <1143734612.8093.8.camel@lade.trondhjem.org> <20060331074900.GC32461@suse.de> <12E368A4-2262-4EBF-8769-581DB3500A36@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FPL5S-0000yA-JB
	for nfs@lists.sourceforge.net; Fri, 31 Mar 2006 06:58:54 -0800
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FPL5S-0001C6-FS
	for nfs@lists.sourceforge.net; Fri, 31 Mar 2006 06:58:54 -0800
To: Chuck Lever <cel@citi.umich.edu>
In-Reply-To: <12E368A4-2262-4EBF-8769-581DB3500A36@citi.umich.edu>
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

On Fri, Mar 31, 2006 at 09:35:34AM -0500, Chuck Lever wrote:
> the check isn't in 2.6.16.  it was removed sometime after 2.6.5.

It is still in the 2.6.16 tree I'm looking at; else I wouldn't ask :)

linux/fs/nfs/direct.c has this:

#define MAX_DIRECTIO_SIZE       (4096UL << PAGE_SHIFT)
...
static inline int
nfs_get_user_pages(int rw, unsigned long user_addr, size_t size,
                struct page ***pages)
{
        int result = -ENOMEM;
        unsigned long page_count;
        size_t array_size;

        /* set an arbitrary limit to prevent type overflow */
        /* XXX: this can probably be as large as INT_MAX */
        if (size > MAX_DIRECTIO_SIZE) {
                *pages = NULL;
                return -EFBIG;
        }




Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
