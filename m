From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: Re: broken umount -f
Date: Tue, 14 Jan 2003 14:56:08 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030114145608.A17237@redhat.com>
References: <6440EA1A6AA1D5118C6900902745938E07D551E8@black.eng.netapp.com> <20030114170755.GA18952@questra.com> <shs8yxn5z6m.fsf@charged.uio.no> <20030114143914.C15824@redhat.com> <15908.27290.467724.590229@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Mcdermott <smcdermott@questra.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from to-velocet.redhat.com ([216.138.202.10] helo=touchme.toronto.redhat.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18YXAV-0000Hh-00
	for <nfs@lists.sourceforge.net>; Tue, 14 Jan 2003 11:56:15 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <15908.27290.467724.590229@charged.uio.no>; from trond.myklebust@fys.uio.no on Tue, Jan 14, 2003 at 08:52:58PM +0100
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

On Tue, Jan 14, 2003 at 08:52:58PM +0100, Trond Myklebust wrote:
> What it does not do is hunt down every task that holds an open file,
> or has  been started from an NFS directory.

Leaving them with stale directories that EIO on everything should work 
fine.  The unmount is actually a distinct operation from the freeing 
of all the data structures, which thanks to Al Viro's changes will 
now be properly garbage collected as the processes die off.

		-ben
-- 
"Do you seek knowledge in time travel?"


-------------------------------------------------------
This SF.NET email is sponsored by: Take your first step towards giving 
your online business a competitive advantage. Test-drive a Thawte SSL 
certificate - our easy online guide will show you how. Click here to get 
started: http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0027en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
