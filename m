From: Ming Zhang <blackmagic02881@gmail.com>
Subject: Re: about quota implementation
Date: Mon, 12 Mar 2007 13:40:58 -0400
Message-ID: <1173721258.3889.48.camel@dhcp-107.ibrix.com>
References: <1173715909.3889.23.camel@dhcp-107.ibrix.com>
	<20070312163517.GA8690@infradead.org>
	<1173719485.6436.35.camel@heimdal.trondhjem.org>
	<1173720257.3889.35.camel@dhcp-107.ibrix.com>
	<20070312172714.GA23383@infradead.org>
Reply-To: blackmagic02881@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HQocU-0003cQ-3w
	for nfs@lists.sourceforge.net; Mon, 12 Mar 2007 10:47:38 -0700
Received: from an-out-0708.google.com ([209.85.132.242])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HQocV-0000Iq-Jx
	for nfs@lists.sourceforge.net; Mon, 12 Mar 2007 10:47:39 -0700
Received: by an-out-0708.google.com with SMTP id d40so2523979and
	for <nfs@lists.sourceforge.net>; Mon, 12 Mar 2007 10:47:36 -0700 (PDT)
In-Reply-To: <20070312172714.GA23383@infradead.org>
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

On Mon, 2007-03-12 at 17:27 +0000, Christoph Hellwig wrote:
> On Mon, Mar 12, 2007 at 01:24:17PM -0400, Ming Zhang wrote:
> > so it worthy duplicating whole rpc logic in quota-tools instead of a
> 
> There's a lot more rpc logic in userspace than the few kernel bits
> we have for nfs :)

can not agree more. :P

> 
> > unified interface via vfs and single quotactl system call?
> 
> I'd like that also.  Then again we don't really have an all that
> unified quta syscall API either, as XFS has a much more advanced
> quota subsystem which also needs a different userspace API.

i saw you are shifting here. ;)

maybe u are right, "a semi unified interface" (since we can not unify
the xfs here) possibly is not worthy the effort of adding extra code in
kernel.

thanks a lot for all of your explanation.

Ming



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
