From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] SUNRPC: Fix xdr_decode_string_inplace()
	mixed	sign comparison
Date: Wed, 31 Oct 2007 23:58:09 -0400
Message-ID: <1193889489.7511.17.camel@heimdal.trondhjem.org>
References: <20071031165045.5861.52308.stgit@manray.1015granger.net>
	<EXNANE01v6EybqfAj810000085a@exnane01.hq.netapp.com>
	<1193857219.7454.70.camel@heimdal.trondhjem.org>
	<7D9707A4-3260-4ADA-9235-8DF945EA2EF9@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	"Talpey, Thomas" <Thomas.Talpey@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1InRBJ-0004BU-BB
	for nfs@lists.sourceforge.net; Wed, 31 Oct 2007 20:57:21 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1InRBN-00044s-B9
	for nfs@lists.sourceforge.net; Wed, 31 Oct 2007 20:57:27 -0700
In-Reply-To: <7D9707A4-3260-4ADA-9235-8DF945EA2EF9@oracle.com>
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


On Wed, 2007-10-31 at 21:53 -0400, Chuck Lever wrote:
> On Oct 31, 2007, at 3:00 PM, Trond Myklebust wrote:
> > On Wed, 2007-10-31 at 13:06 -0400, Talpey, Thomas wrote:
> >> This is a serious vunerability! A huge string length will always be
> >> accepted by this code, right? Security/integrity bug, not a minor
> >> sign cleanup IOW.
> >
> > Wrong! The current code is quite correct.
> >
> > It trusts that the caller is setting a reasonable value for maxlen,  
> > and
> > assumes that 'len' is the untrusted value (since it comes from the
> > network).
> >
> > in the comparison
> >
> >   ((len = ntohl(*p++)) < maxlen)
> >
> > then the trusted value maxlen is the one that gets cast to an unsigned
> > value since 'len' and 'maxlen' are both integers of the same rank (see
> > the description of the usual binary conversions in section 6.3.4 in
> > Harbison and Steele).
> 
> Whatever H&S says, the compiler flags this as a mixed sign  
> comparison.  Thus something is not working the way you assume it is.
> 
> [cel@ingres NFS_ALL]$ make net/sunrpc/xdr.o
>    Using /home/cel/src/linux/NFS_ALL as source for kernel
>    GEN     /u/cel/obj/Makefile
>    CHK     include/linux/version.h
>    CHK     include/linux/utsrelease.h
>    UPD     include/linux/utsrelease.h
>    CALL    /home/cel/src/linux/NFS_ALL/scripts/checksyscalls.sh
>    CC      net/sunrpc/xdr.o
> /home/cel/src/linux/NFS_ALL/net/sunrpc/xdr.c: In function  
> xdr_decode_string_inplace:
> /home/cel/src/linux/NFS_ALL/net/sunrpc/xdr.c:100: warning: comparison  
> between signed and unsigned
> [cel@ingres NFS_ALL]$
> 
> Line 100 is precisely:
> 
> 	if ((len = ntohl(*p++)) > maxlen)

Which is still correct according to both the old and new C standards. I
know you've got that book at home...

> My gcc is the latest available for Fedora 7:
> 
> gcc version 4.1.2 20070925 (Red Hat 4.1.2-27)
> 
> I rather prefer spelling this out completely so that neither the  
> compiler nor humans can mistake the intent of this logic.

That's fine, but please do not change the logic. The correct change is
to replace the maxlen parameter with an unsigned int.



-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
