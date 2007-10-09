From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: linux-2.6.23-rc9-CITI_NFS4_ALL-1
Date: Tue, 9 Oct 2007 11:24:40 -0400
Message-ID: <20071009152440.GA22750@fieldses.org>
References: <E1Idoz6-0000W5-SM@fieldses.org> <4709FBF6.4090700@bull.net>
	<1191943060.8739.9.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, Le Rouzic <aime.le-rouzic@bull.net>,
	nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfGxQ-0003pN-6d
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 08:25:16 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IfGxT-00035p-6b
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 08:25:21 -0700
In-Reply-To: <1191943060.8739.9.camel@heimdal.trondhjem.org>
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

On Tue, Oct 09, 2007 at 11:17:40AM -0400, Trond Myklebust wrote:
> 
> On Mon, 2007-10-08 at 11:44 +0200, Le Rouzic wrote:
> > Hi,
> > 
> > Running 2.6.23-rc9-CITI_NFS4_ALL-1 on two Intel X86_64 two ways machines as client and
> > server, the runtest (-b) of the basic commands of the connectathon suite gives
> > the following errors:
> > 
> > ./runtests -b -t /mnt/nosec1/test_nfs1_nfs4_gb
> > /test6: readdir
> >         ./test6: (/mnt/nosec1/test_nfs1_nfs4_gb) unlinked 'file.0' dir entry
> > read pass 1
> >         ./test6: (/mnt/nosec1/test_nfs1_nfs4_gb) Test failed with 1 errors
> > 
> > 
> > Bug has been registered at:
> > 
> > Bug: 
> >   http://bugzilla.linux-nfs.org/show_bug.cgi?id=148  
> > 
> > Cheers
> 
> I believe that applying the following 2 patches should fix this problem.

Thanks for taking care of this, Trond....

I've been wondering whether to keep putting out these patches.  Looks
like they're still getting some testing, so I guess I should!  The name
doesn't make as much sense any more, but oh well.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
