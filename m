From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: Re: [PATCH] SGI 905314 (1/2): make NFSSVC_MAXBLKSIZE dependon  
 PAGE_SIZE
Date: Tue, 02 Dec 2003 11:26:12 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FCBDC24.291BB858@melbourne.sgi.com>
References: <Pine.LNX.4.44.0312011235290.23297-100000@kenzo.iwr.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@cse.unsw.edu.au>,
   Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AR1Aa-0003eo-VI
	for nfs@lists.sourceforge.net; Mon, 01 Dec 2003 19:25:48 -0800
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=rj.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AQyNg-0001fc-Qo
	for nfs@lists.sourceforge.net; Mon, 01 Dec 2003 16:27:08 -0800
To: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Bogdan Costescu wrote:
> 
> On Mon, 1 Dec 2003, Greg Banks wrote:
> 
> > It's not that simple; the ia64 port can be configured for 64K pages,
> > which would result in nfsd reporting 128K for wtmax on UDP.
> 
> But allocating only 32K in this case means half a page... A waste.

The 2.4 code now does a kmalloc(NFSSVC_MAXBLKSIZE+1024), which
ends up allocating nearly twice as many pages as we need, so it's
already that wasteful now.

Besides machines with 64K pages are going to be wasting a lot
more RAM elsewhere.

> Then
> maybe TCP should get its own setting ?

I plan on later submitting a patch against 2.6 to do that.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
