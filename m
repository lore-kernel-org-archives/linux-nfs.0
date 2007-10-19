From: Erez Zadok <ezk@cs.sunysb.edu>
Subject: Re: nfsv2 ref leak in 2.6.24?
Date: Fri, 19 Oct 2007 18:59:36 -0400
Message-ID: <200710192259.l9JMxaAT006804@agora.fsl.cs.sunysb.edu>
References: <1192830752.7466.32.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: bfields@fieldses.org, neilb@suse.de,
	Erez Zadok <ezk@cs.sunysb.edu>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ij0om-0004Qy-JR
	for nfs@lists.sourceforge.net; Fri, 19 Oct 2007 15:59:48 -0700
Received: from filer.fsl.cs.sunysb.edu ([130.245.126.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Ij0or-0006kl-Qe
	for nfs@lists.sourceforge.net; Fri, 19 Oct 2007 15:59:54 -0700
In-reply-to: Your message of "Fri, 19 Oct 2007 17:52:32 EDT."
	<1192830752.7466.32.camel@heimdal.trondhjem.org>
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

In message <1192830752.7466.32.camel@heimdal.trondhjem.org>, Trond Myklebust writes:
> 
> On Fri, 2007-10-19 at 17:40 -0400, Erez Zadok wrote:
[...]
> > Trond, I was able to narrow down the problem w/o using unionfs at all (yay!
> > :-).  All I do is setup a loop device, mkfs it as ext2, mount it, then
> > export it to localhost and mount it locally as nfs2.  I go and touch a new
> > file in the ext2 directory.  Then I readdir the export point to find the new
> > file indeed.  Then I stat(1) the new file, and get the appropriate stat
> > output.  Now the strange thing is that right after the stat through the
> > export point, the file DISAPPEARS from the lower ext2 dir, but REAPPEARS a
> > few seconds later.
> 
> Let me get this straight:
> 
>   1) You create the file on the server
>   2) You readdir the file from the client
>   3) You stat the file from the client
> 
> ....with the result that the file disappears from sight on the server?

Yup.

> That would indicate some dcache issues with the server code. What export
> options are you using?

The explicit command I use is:

exportfs -o no_root_squash,rw localhost:/n/export/b0

The options recorded in exportfs -v:

/n/export/b0  localhost.localdomain(rw,wdelay,no_root_squash,no_subtree_check,anonuid=65534,anongid=65534)

Erez.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
