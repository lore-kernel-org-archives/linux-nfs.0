From: upendra gandhi <upendra.gandhi@oracle.com>
Subject: Re: how to force umount when "Device or resource busy"?
Date: Thu, 28 Oct 2004 16:58:26 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <418187A2.6070702@oracle.com>
References: <AB813470-0682-11D9-9080-000A95C71776@freezone.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CNKAL-0005Rn-U6
	for nfs@lists.sourceforge.net; Thu, 28 Oct 2004 16:58:49 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CNKAK-0000Dv-2e
	for nfs@lists.sourceforge.net; Thu, 28 Oct 2004 16:58:49 -0700
To: ms419@freezone.co.uk
In-Reply-To: <AB813470-0682-11D9-9080-000A95C71776@freezone.co.uk>
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

is there an answer to this we are facing this issue in autofs4

thks

ms419@freezone.co.uk wrote:

> How does one unmount when umount doesn't work?
>
> Somehow, I got an NFS / AutoFS mount that just won't unmount.
>
> I noticed /var/autofs/net was mounted twice, so I stopped AutoFS & 
> tried killing the remaining automount process. "kill 14986" didn't 
> work; I needed "kill -9 14986". The following mounts remain:
>
> wum:~# mount
> [...]
> automount(pid14986) on /var/autofs/net type autofs 
> (rw,fd=5,pgrp=14986,minproto=2,maxproto=4)
> tor:/home on /var/autofs/net/tor/home type nfs 
> (rw,nosuid,nodev,hard,intr,addr=192.168.103.158)
>
> & I can't unmount them:
>
> wum:~# umount /var/autofs/net/tor/home
> umount: /var/autofs/net/tor/home: device is busy
> umount: /var/autofs/net/tor/home: device is busy
> wum:~# umount -f /var/autofs/net/tor/home
> umount2: Device or resource busy
> umount: /var/autofs/net/tor/home: Illegal seek
> umount2: Device or resource busy
> umount: /var/autofs/net/tor/home: device is busy
> wum:~# umount /var/autofs/net
> umount: /var/autofs/net: device is busy
> umount: /var/autofs/net: device is busy
> wum:~# umount -f /var/autofs/net
> umount2: Device or resource busy
> umount: automount(pid14986): not found
> umount: /var/autofs/net: Illegal seek
> umount2: Device or resource busy
> umount: /var/autofs/net: device is busy
>
> I triple checked that no process is using these mounts. How do I 
> unmount them?
>
> Thanks!
>
> Jack
>
>
>
> -------------------------------------------------------
> This SF.Net email is sponsored by: thawte's Crypto Challenge Vl
> Crack the code and win a Sony DCRHC40 MiniDV Digital Handycam
> Camcorder. More prizes in the weekly Lunch Hour Challenge.
> Sign up NOW http://ad.doubleclick.net/clk;10740251;10262165;m
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs




-------------------------------------------------------
This Newsletter Sponsored by: Macrovision 
For reliable Linux application installations, use the industry's leading
setup authoring tool, InstallShield X. Learn more and evaluate 
today. http://clk.atdmt.com/MSI/go/ins0030000001msi/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
