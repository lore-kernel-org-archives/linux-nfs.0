From: Justin Piszcz <jpiszcz@lucidpixels.com>
Subject: Re: NFS/Kernel Problem: getfh failed: Operation not permitted
Date: Thu, 30 Mar 2006 10:13:38 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0603301011160.18696@p34>
References: <Pine.LNX.4.64.0603300813270.18696@p34>
 <1143728720.8074.41.camel@lade.trondhjem.org>  <Pine.LNX.4.64.0603300929340.18696@p34>
  <1143729766.8074.49.camel@lade.trondhjem.org>  <Pine.LNX.4.64.0603300949000.18696@p34>
 <1143731364.8074.53.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FOyqE-0005IA-QF
	for nfs@lists.sourceforge.net; Thu, 30 Mar 2006 07:13:42 -0800
Received: from lucidpixels.com ([66.45.37.187] ident=postfix)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FOyqD-0001gX-8o
	for nfs@lists.sourceforge.net; Thu, 30 Mar 2006 07:13:42 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1143731364.8074.53.camel@lade.trondhjem.org>
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

On Thu, 30 Mar 2006, Trond Myklebust wrote:

> On Thu, 2006-03-30 at 09:50 -0500, Justin Piszcz wrote:
>> I tried an exportfs -rv and it did not help.  Any other suggestions?
>
> Did the output from 'exportfs -rv' match with the contents
> of /etc/exports? If so, did it also match with the contents
> of /var/lib/nfs/xtab and /proc/fs/nfs/exports?
>
> Cheers,
>  Trond
>

In the /etc/exports file, I have an entry that looks like this:
/path	specific-host-001(ro,root_squash,no_sync)
/path	specific-host-002((ro,root_squash,no_sync)
/path	*(ro,root_squash,no_sync)

So while there are only three entries, there are:

cat /proc/fs/nfs/exports | wc -> 566
cat /var/lib/nfs/xtab | wc -> 564

Entries per file.

Is this more of a kernel or nfsutils issue at this point?



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
