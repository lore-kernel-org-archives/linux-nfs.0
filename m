From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: lockd fails to purge blocked NLM_LOCKs
Date: Thu, 7 Aug 2003 09:55:22 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16177.38250.158802.733185@gargle.gargle.HOWL>
References: <16173.61548.939819.343488@gargle.gargle.HOWL>
	<Pine.LNX.4.33.0308061158190.1062-300000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
    <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19kY7x-0003bN-00
	for <nfs@lists.sourceforge.net>; Wed, 06 Aug 2003 16:55:33 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <markhe@veritas.com>) (for <trond.myklebust@fys.uio.no>)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Thu, 7 Aug 2003 09:55:23 +1000
To: Mark Hemment <markhe@veritas.com>
In-Reply-To: message from Mark Hemment on Wednesday August 6
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

On Wednesday August 6, markhe@veritas.com wrote:
> On Mon, 4 Aug 2003, Neil Brown wrote:
> 
> > On Friday August 1, markhe@veritas.com wrote:
> > >   When stopping server-side NFS, or deleting a client (NFSCTL_DELCLIENT),
> > > lockd fails to purge blocked lockd requests.
> >
> > Thanks Mark.  I'm at least largely convinced.
> >
> > My only question concerns nlmsvc_traverse_blocks.
> > This uses b_host and you have (subtley) changed the meaning of b_host.
> 
>   That is the idea.

Thanks for the extra detail.  I'm convinced now.

I know I must have understood all this code once, because I changed
this stuff for 2.6 and got rid of the per-export-entry 'host's and
just kept per-ip-address hosts.  The actual patch can be found at:

http://www.cse.unsw.edu.au/~neilb/patches/linux-devel/2.5.34/patch-F-LockdSeparate

I hope it's right :-)

I'll submit your patch for 2.4.23.

NeilBrown


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
