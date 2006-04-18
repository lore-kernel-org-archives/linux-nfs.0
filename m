From: "LLLActive@GMX.Net" <LLLActive@GMX.Net>
Subject: Re: can't umount nfs4 share
Date: Tue, 18 Apr 2006 17:37:25 +0200
Message-ID: <1145374646.25073.45.camel@L10-WS-AWS1.AWS>
References: <1145373792.25073.39.camel@L10-WS-AWS1.AWS>
Reply-To: LLLActive@GMX.Net
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FVsGl-0001W7-Pk
	for nfs@lists.sourceforge.net; Tue, 18 Apr 2006 08:37:35 -0700
Received: from mail.gmx.net ([213.165.64.20])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1FVsGk-0006mf-Aq
	for nfs@lists.sourceforge.net; Tue, 18 Apr 2006 08:37:35 -0700
To: nfs@lists.sourceforge.net
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


> Strangely, when the NFS Server returns, I can remount it with 
> mount -t nfs4 192.168.1.2:/ /nfs4share/ //
> -orsize=32768,wsize=32768,timeo=14,intr
> 
> and write to it again, but not unmount it.
> 

On a second attempt, it did not work again with remounting it as NFS4.
It now says it is already mounted. With YAST I can mount it as NFS3 to
the old directory and read but not write. When removing it with YAST,
the stale file handles return with the old state of affairs.

:-/
Al



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
