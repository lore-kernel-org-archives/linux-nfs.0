From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: can't umount nfs4 share
Date: Tue, 18 Apr 2006 12:29:12 -0400
Message-ID: <1145377753.8115.20.camel@lade.trondhjem.org>
References: <1145373792.25073.39.camel@L10-WS-AWS1.AWS>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FVt54-0007Do-1O
	for nfs@lists.sourceforge.net; Tue, 18 Apr 2006 09:29:34 -0700
Received: from pat.uio.no ([129.240.10.6] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FVt52-00020T-MA
	for nfs@lists.sourceforge.net; Tue, 18 Apr 2006 09:29:34 -0700
To: LLLActive@GMX.Net
In-Reply-To: <1145373792.25073.39.camel@L10-WS-AWS1.AWS>
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

On Tue, 2006-04-18 at 17:23 +0200, LLLActive@GMX.Net wrote:
> Hi,
> 
> I have a problem that on a production system I can not umount a nfs4
> share. The NFS4 Server is not available anymore. When I try
> umount /nfs4share the response is:
> 
> # umount: /nfs4share: device is busy
> 
> there is nothing accessing the share. 
> 
> with a ls -l /nfs4share the response is:
> 
> # /bin/ls: /nfs4share: Stale NFS file handle
> 
> with umount -f the response is:
> 
> # umount2: Device or resource busy
> # umount: /nfs4share: device is busy
> # umount2: Device or resource busy
> # umount: /nfs4share: device is busy
> 
> When I look with 'mc' (midnight commander), there is a file or directory
> called ~nfs4share with 0 size and dated Jan 1 1970. It can't be deleted.
> 
> How do I get rid of it or get the share unmounted without shutting down
> the system?
> 
> Strangely, when the NFS Server returns, I can remount it with 
> mount -t nfs4 192.168.1.2:/ /nfs4share/ //
> -orsize=32768,wsize=32768,timeo=14,intr
> 
> and write to it again, but not unmount it.

Try

lsof +D /nfs4share

in order to identify the processes that are using that mountpoint, then
kill them off before retrying 'umount -f /nfs4share' a couple more
times.

If all else fails, you can hide the mount using 'umount -l /nfs4share'.

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
