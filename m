From: Neil Brown <neilb@suse.de>
Subject: Re: NFS Server Installation -- Urgent
Date: Tue, 7 Mar 2006 15:32:46 +1100
Message-ID: <17421.3310.55982.578236@cse.unsw.edu.au>
References: <20060307041248.94423.qmail@web8506.mail.in.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FGTtY-0002Fz-GP
	for nfs@lists.sourceforge.net; Mon, 06 Mar 2006 20:34:00 -0800
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FGTtX-0001R2-7g
	for nfs@lists.sourceforge.net; Mon, 06 Mar 2006 20:34:00 -0800
To: Banu Gandhi <banugandhi80@yahoo.co.in>
In-Reply-To: message from Banu Gandhi on Tuesday March 7
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

On Tuesday March 7, banugandhi80@yahoo.co.in wrote:
> Hi there,
>    
>   I have try to install NFS Server on linux server in which we are using Fedora core 2 and the kernel version is 2.6.
>    
>   I have followed all the steps for Server as well as Client Installation.
>   After that NFS Server is running successfully. But when I try to mount the file systems from the server, It saying that the server is down.
>    
>   But when I try to ping to the same server, can connect.

Sounds like a firewall problem.
On the client can you:

  - rpcinfo -p SERVER
  - showmount -e SERVER

If so, report the output.
If not, and 'portmap' and 'mountd' are running on the server, then
check your firewall.

NeilBrown


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
