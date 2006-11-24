From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: several oopses of nfsd in 2.6.16.29 where
	/proc/fs/nfsd	mounted
Date: Fri, 24 Nov 2006 14:45:29 -0500
Message-ID: <1164397529.5702.58.camel@lade.trondhjem.org>
References: <28552016.1164354672990.JavaMail.ngmail@webmail11>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gngzf-0006R4-Sf
	for nfs@lists.sourceforge.net; Fri, 24 Nov 2006 11:45:52 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1+BV45HFCVEDlsvtlX//N3UFAag5oWUXUs=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gngze-0004kc-Sh
	for nfs@lists.sourceforge.net; Fri, 24 Nov 2006 11:45:53 -0800
To: linuxkernel@arcor.de
In-Reply-To: <28552016.1164354672990.JavaMail.ngmail@webmail11>
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

On Fri, 2006-11-24 at 08:51 +0100, linuxkernel@arcor.de wrote:
> Hello list!
> 
> I just reported bug #7572 just before i read in bug #6172 that "The NFS server
> maintainer doesn't use bugzilla."  which is very clever, very clever...

Developers are fully entitled to use whatever debugging tools they want.

> Anyways we use kernel 2.6.16.x series because it was promised that this would
> be a "long -living kernel series".  So I hope that whatever will be the fix for these oopses
> it will make it to the 2.6.16.x kernel.  Please have a look at the report:
> 
> http://bugzilla.kernel.org/show_bug.cgi?id=7572
> 
> Best thanks,
> 
>       Peter

You've reported this bug for 2.6.16, but it is unclear if you have tried
a more recent kernel.

Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
