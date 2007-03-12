From: Ming Zhang <blackmagic02881@gmail.com>
Subject: Re: about quota implementation
Date: Mon, 12 Mar 2007 13:44:03 -0400
Message-ID: <1173721443.3889.51.camel@dhcp-107.ibrix.com>
References: <1173715909.3889.23.camel@dhcp-107.ibrix.com>
	<20070312163517.GA8690@infradead.org>
	<1173719485.6436.35.camel@heimdal.trondhjem.org>
	<1173720257.3889.35.camel@dhcp-107.ibrix.com>
	<1173721142.6436.52.camel@heimdal.trondhjem.org>
Reply-To: blackmagic02881@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Christoph Hellwig <hch@infradead.org>, nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HQoZ6-0003GT-Bw
	for nfs@lists.sourceforge.net; Mon, 12 Mar 2007 10:44:08 -0700
Received: from an-out-0708.google.com ([209.85.132.246])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HQoZ7-0000ab-CT
	for nfs@lists.sourceforge.net; Mon, 12 Mar 2007 10:44:10 -0700
Received: by an-out-0708.google.com with SMTP id d40so2520438and
	for <nfs@lists.sourceforge.net>; Mon, 12 Mar 2007 10:44:08 -0700 (PDT)
In-Reply-To: <1173721142.6436.52.camel@heimdal.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Mon, 2007-03-12 at 13:39 -0400, Trond Myklebust wrote:
> On Mon, 2007-03-12 at 13:24 -0400, Ming Zhang wrote:
> 
> > so it worthy duplicating whole rpc logic in quota-tools instead of a
> > unified interface via vfs and single quotactl system call?
> 
> Yes.
> 
> Until the mess that is rquotad is resolved (somebody from the quota
> group showing infinite wisdom decreed that Linux should serve up a
> "revision" of the rquotad protocol for which there is not even an RFC to
> refer to) I will veto any implementation of a client in the kernel.
> Private protocols belong in userspace, not kernel space.

o, i did not know this.

> 
> Trond
> 


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
