From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Re: nfsd not working in 2.6.0-test4 on ia64
Date: Fri, 12 Sep 2003 13:09:26 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16225.14566.414747.499286@notabene.cse.unsw.edu.au>
References: <20030903220709.GJ18654@parcelfarce.linux.theplanet.co.uk>
	<16216.2231.419902.317479@gargle.gargle.HOWL>
	<20030905115312.GH18654@parcelfarce.linux.theplanet.co.uk>
	<16219.65533.190871.210282@gargle.gargle.HOWL>
	<shsllszopo8.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matthew Wilcox <willy@debian.org>,
    nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19xeJY-0003Yp-00
	for <nfs@lists.sourceforge.net>; Thu, 11 Sep 2003 20:09:40 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 19xeJX-0000Aj-Tv
	for nfs@lists.sourceforge.net; Thu, 11 Sep 2003 20:09:40 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <trond.myklebust@fys.uio.no>) (for <willy@debian.org>)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Fri, 12 Sep 2003 13:09:31 +1000
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: message from Trond Myklebust on  September 8
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

On  September 8, trond.myklebust@fys.uio.no wrote:
> >>>>> " " == Neil Brown <neilb@cse.unsw.edu.au> writes:
> 
>      > On Friday September 5, willy@debian.org wrote:
>     >> On Fri, Sep 05, 2003 at 01:53:27PM +1000, Neil Brown wrote:
>     >> > Very helpful details.  It looks like a simple case of 32-bit
>     >> > parochialism :-)
>     >> >
>     >> > Does this patch help?
>     >>
>     >> Nope.  Applied patch, rebooted with it, here's the full details
>     >> again (don't think anything changed, but just in case):
> 
>      > Ok, I looked more closely at the .h files etc and I think the
>      > following is correct (instead of the previous patch).
> 
>      > (i.e. sizeof(cm.pki) instead of sizeof(cm)).
> 
> Nope see the code in ip_sockglue.c + the macros in socket.h....
> AFAICS the control messages have wierd alignment requirements.
> 
> Shouldn't it rather be something like the following?

Probably it should, but that felt ugly, and the alignment requirements
are "round up to multiple of size of long", and I believe that just
putting them together in a struct would do that.  But I guess it isn't
100% guaranteed so it is safer to use your code.

Once I get confirmation from Matthew that something actually works for
him, I'll send an appropriate change to Linus.

thanks.
NeilBrown


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
