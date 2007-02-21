From: Neil Brown <neilb@suse.de>
Subject: Re: Server not working since 2.6.20-rc
Date: Wed, 21 Feb 2007 11:09:26 +1100
Message-ID: <17883.36278.831305.989168@notabene.brown>
References: <45DB8447.1060903@sysnux.pf>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Jean-Denis Girard <jd.girard@sysnux.pf>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HJf3n-000093-Ve
	for nfs@lists.sourceforge.net; Tue, 20 Feb 2007 16:10:16 -0800
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HJf3p-0008AG-GN
	for nfs@lists.sourceforge.net; Tue, 20 Feb 2007 16:10:18 -0800
In-Reply-To: message from Jean-Denis Girard on Tuesday February 20
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Tuesday February 20, jd.girard@sysnux.pf wrote:
> Hi list,
> 
> I have an LTSP environment, which is working fine with kernels before 
> 2.6.20 series. I think I started to test with 2.6.20-rc3, up to latest 
> 2.6.20.1, but mounting nfs shares from the clients fails with 
> "permission denied". If I reboot server to 2.6.19.x without changing 
> configuration, it works again.
> 
> When I try to mount /home from my laptop (with kernel 2.6.20), I get the 
> well known message:
> 	mount: tiare.sysnux.pf:/home failed, reason given by server: Permission 
> denied
> 
> But, on the server I have:
> [jdg@tiare ~]$ cat /proc/fs/nfs/exports
> # Version 1.1
> # Path Client(Flags) # IPs
> /home 
> 192.168.10.0/255.255.255.0(rw,insecure,root_squash,sync,wdelay,no_subtree_check,insecure_locks)
> 
> Client and server are based on Mandriva 2007. Server is 64 bits SMP. 
> nfs-utils has been updated to 1.0.10. I can provide more details if needed.
> 
> I think I have done all checks recommended in the troubleshooting 
> section of the nfs-howto. Any help would be greatly appreciated.
> 

What messages appear in /var/log/message (or /var/log/syslog or where
ever)?

What does "strace -s1000 -p `pidof mountd`" show when you try the
mount?

Do you have /proc/fs/nfsd mounted?

Is the IP of your notebook in 192.168.10.X :-)

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
