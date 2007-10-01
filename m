From: "Wim Colgate" <Wim.Colgate@xensource.com>
Subject: Re: simple question about r/wsize
Date: Mon, 1 Oct 2007 16:19:31 -0700
Message-ID: <A9AD3C3BCF83FD4182B7D4D99E37FAD8447557@exchrdm.ad.xensource.com>
References: <A9AD3C3BCF83FD4182B7D4D99E37FAD8447540@exchrdm.ad.xensource.com>
	<1191280261.6611.19.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IcUY4-0004K2-Eb
	for nfs@lists.sourceforge.net; Mon, 01 Oct 2007 16:19:36 -0700
Received: from webmailrdm.xensource.com ([66.228.214.202])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IcUY8-000873-C9
	for nfs@lists.sourceforge.net; Mon, 01 Oct 2007 16:19:41 -0700
In-Reply-To: <1191280261.6611.19.camel@heimdal.trondhjem.org>
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

Thanks Trond,

As usual, you are fast to answer; and right. I was looking through the
code and saw 4K being bantered around. However, cat'ing /proc/mounts
shows 32K for rsize and wsize.

Wim

-----Original Message-----
From: Trond Myklebust [mailto:trond.myklebust@fys.uio.no] 
Sent: Monday, October 01, 2007 4:11 PM
To: Wim Colgate
Cc: nfs@lists.sourceforge.net
Subject: Re: [NFS] simple question about r/wsize

On Mon, 2007-10-01 at 15:04 -0700, Wim Colgate wrote:
> What's the current NFS v3 wsize and rsize? It appears to be 4K - and
> just wanted a confirmation.
> 

It sounds like you are working with an old system. IIRC, older versions
of RedHat used to jimmy the 'mount' command to make 4k the default,
because that worked best with UDP mounts on crummy networks.

For newer clients, the default should depend on what your server
specifies in the FSINFO nfs command. For most servers, when you mount
with a TCP connection, the default will be 32k, but some may have larger
defaults (NetApp servers often specify a 64k default) or smaller (older
Linux servers will support an 8k maximum).

'cat /proc/mounts' should always tell you what the client is actually
using for rsize/wsize.

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
