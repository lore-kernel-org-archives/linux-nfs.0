From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFSD Help
Date: Fri, 21 Oct 2005 11:34:01 -0400
Message-ID: <20051021153400.GB13908@fieldses.org>
References: <20051021135034.44113.qmail@web81509.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ESyuF-0004UP-M6
	for nfs@lists.sourceforge.net; Fri, 21 Oct 2005 08:34:07 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1ESyuE-00045r-Ez
	for nfs@lists.sourceforge.net; Fri, 21 Oct 2005 08:34:07 -0700
To: Donald Mcknight <donald.mcknight@sbcglobal.net>
In-Reply-To: <20051021135034.44113.qmail@web81509.mail.yahoo.com>
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

On Fri, Oct 21, 2005 at 06:50:34AM -0700, Donald Mcknight wrote:
> Having issue getting nfs to start,  I am following the
> howto and have not encounterd this before.

> open("/proc/fs/nfsd/threads", O_WRONLY) = -1 ENOENT
> (No such file or directory)
> open("/proc/fs/nfs/threads", O_WRONLY)  = -1 ENOENT
> (No such file or directory)
> nfsservctl(0, 0x7fffffd47fe0, 0)        = -1 ENOSYS
> (Function not implemented)

At a guess, you either built a kernel without nfsd support, or your
kernel has nfsd support in a module and you haven't loaded that module.

--b.


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
