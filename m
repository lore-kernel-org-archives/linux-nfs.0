From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfs write problems
Date: Wed, 3 Oct 2007 09:31:18 -0400
Message-ID: <20071003133118.GP21675@fieldses.org>
References: <4702A279.3080001@panix.com>
	<1191370059.6707.38.camel@heimdal.trondhjem.org>
	<47036D3F.8070904@panix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: For users of Fedora <fedora-list@redhat.com>,
	nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Bob Kryger <bobk@panix.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Id4Js-0007Lv-H7
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 06:31:20 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Id4Jw-0003XB-Gr
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 06:31:25 -0700
In-Reply-To: <47036D3F.8070904@panix.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wed, Oct 03, 2007 at 06:21:51AM -0400, Bob Kryger wrote:
> Trond Myklebust wrote:
> > Feel free to describe your test in a bit more detail. Without more
> > information, we obviously can't rule out the existence of an NFS bug,
> >   
> I was trying to be thorough, I hope I succeeded.

The dd test sounded simple enough, but if you could include a transcript
of the commands you ran (together with the C code of any test programs)
just to be sure, that might help.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
