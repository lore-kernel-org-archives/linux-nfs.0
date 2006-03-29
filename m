From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: timeo & retrans, smaller max timeout than 60 seconds?
Date: Wed, 29 Mar 2006 16:02:10 -0500
Message-ID: <1143666130.7957.27.camel@lade.trondhjem.org>
References: <Pine.LNX.4.64.0603290921500.2597@maggie.lkpg.cendio.se>
	 <1143641272.7928.13.camel@lade.trondhjem.org>
	 <Pine.LNX.4.64.0603291625370.7796@maggie.lkpg.cendio.se>
	 <1143644879.7928.44.camel@lade.trondhjem.org>
	 <Pine.LNX.4.64.0603292058050.15464@maggie.lkpg.cendio.se>
	 <1143665569.7957.24.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FOhoB-0001xr-CQ
	for nfs@lists.sourceforge.net; Wed, 29 Mar 2006 13:02:27 -0800
Received: from pat.uio.no ([129.240.10.6] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FOho9-0005Jv-SB
	for nfs@lists.sourceforge.net; Wed, 29 Mar 2006 13:02:27 -0800
To: Peter =?ISO-8859-1?Q?=C5strand?= <astrand@cendio.se>
In-Reply-To: <1143665569.7957.24.camel@lade.trondhjem.org>
Sender: nfs-admin@lists.sourceforge.net
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

On Wed, 2006-03-29 at 15:52 -0500, Trond Myklebust wrote:
> It shouldn't mention major timeouts at all. The Solaris manpage
> documents 'intr' as
> 
>            intr | nointr
>                  Allow (do not allow) keyboard interrupts to kill
>                  a  process  that  is  hung  while  waiting for a
>                  response on  a  hard-mounted  file  system.  The
>                  default  is  intr,  which  makes it possible for
>                  clients to interrupt applications  that  may  be
>                  waiting for a remote mount.
> 
> which is pretty much what we aim to do too.

Sorry... The above thing mentions 'hard-mounted' too. As I said, we
don't distinguish between hard and soft mounts when it comes to allowing
clients to interrupt.

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
