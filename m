From: Jeremy Sanders <jss@ast.cam.ac.uk>
Subject: Re: Diskless boot problems
Date: Mon, 14 Nov 2005 15:54:34 +0000 (GMT)
Message-ID: <Pine.LNX.4.64.0511141553380.11652@xpc20.ast.cam.ac.uk>
References: <Pine.LNX.4.64.0511141441390.11652@xpc20.ast.cam.ac.uk>
 <1131982323.8870.22.camel@lade.trondhjem.org>
 <Pine.LNX.4.64.0511141537400.11652@xpc20.ast.cam.ac.uk>
 <1131983320.8870.28.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EbgfK-0004Kg-K5
	for nfs@lists.sourceforge.net; Mon, 14 Nov 2005 07:54:42 -0800
Received: from ppsw-9.csi.cam.ac.uk ([131.111.8.139])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EbgfI-0006QB-8h
	for nfs@lists.sourceforge.net; Mon, 14 Nov 2005 07:54:42 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1131983320.8870.28.camel@lade.trondhjem.org>
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

On Mon, 14 Nov 2005, Trond Myklebust wrote:

> On Mon, 2005-11-14 at 15:40 +0000, Jeremy Sanders wrote:
>
>> I think it dies - but unfortunately I stupidly rebooted the system this
>> time. I may have to wait a week to confirm this.
>>
>> I tried restarting the portmapper, but this didn't solve the problem.
>
> No. Restarting the portmapper isn't sufficient because you will still
> lose all the information that the old session held. If this sort of
> crash happens very often, you could try using pmap_dump to save the
> portmapper information at regular intervals, then use pmap_set to
> restore it after a crash.

Is there any way to debug it next time it crashes? I suppose the problem 
is that unless I monitor all the traffic, I won't be able to work out how 
it crashed.

Jeremy

-- 
Jeremy Sanders <jss@ast.cam.ac.uk>   http://www-xray.ast.cam.ac.uk/~jss/
X-Ray Group, Institute of Astronomy, University of Cambridge, UK.
Public Key Server PGP Key ID: E1AAE053


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. Download
it for free - -and be entered to win a 42" plasma tv or your very own
Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
