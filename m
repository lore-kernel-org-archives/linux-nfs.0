From: Santiago <santi@mleads.com>
Subject: Re: RedHat/Mandrake NFS - not playing nice
Date: Tue, 18 Feb 2003 07:30:21 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E52437D.6000003@mleads.com>
References: <Pine.LNX.4.44.0302171425550.928-100000@glenfiddich.cse.ogi.edu>
Reply-To: santi@mleads.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [64.92.112.32] (helo=mail.hosting-advantage.com)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18l8kK-0002pu-00
	for <nfs@lists.sourceforge.net>; Tue, 18 Feb 2003 06:29:20 -0800
To: Paul Heinlein <heinlein@cse.ogi.edu>,  nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

In my first post (you might not have seen it) I indicated that I had 
checked the hosts.deny/hosts.allow and turned off ipchains and iptables. 
It is usually an obvious thing. The obvious thing I forgot to do was to 
check the log files. Here is what appears to be the issue:
Feb 17 16:19:15 chance rpc.mountd: refused mount request from 10.0.0.10 
(private-10.swlink.net) for
  /var/www/html (/var/www/html): no DNS forward lookup
Feb 17 16:22:07 chance rpc.mountd: authenticated mount request from 
10.0.0.57:958 for /var/www/html
  (/var/www/html)
Feb 17 16:22:16 chance rpc.mountd: refused mount request from 10.0.0.10 
(private-10.swlink.net) for
  /var/www/html (/var/www/html): no DNS forward lookup

RedHat is trying to look up the host that it is exporting to? I don't 
have this issue though when mounting on a debian box. There is nothing 
in the /etc/host file. So this is still somewhat mysterious. I am going 
to put an entry in /etc/hosts for the mandrake box and see what happens.

Thanks reminding me. It is usually the obvious things.

It worked. Any ideas as to why the nfs server would differentiate 
between the mandrake clients and the non-mandrake clients (RH and Debian)?

Thanks,
Santiago



Paul Heinlein wrote:
> On Mon, 17 Feb 2003, Santiago wrote:
> 
> 
>>However, I still am receiving the same error as before:
>>[root@backup linux]# mount 10.0.0.48:/var/www/html /r/amanda/nitro-html 
>>-t nfs
>>mount: 10.0.0.48:/var/www/html failed, reason given by server: 
>>Permission denied
> 
> 
> I hate to ask the obvious questions, but
> 
> * Is there anything in /etc/host.deny that would keep your client from
>   getting to the server?
> 
> * Is there any sort of ipchains/iptables packet filtering that would 
>   keep your client from getting to the server?
> 
> * Do the logs on the server offer any clues as to why it doesn't like 
>   your client's mount requests?
> 
> --Paul Heinlein <heinlein@cse.ogi.edu>
> 
> 
> 
> -------------------------------------------------------
> This sf.net email is sponsored by:ThinkGeek
> Welcome to geek heaven.
> http://thinkgeek.com/sf
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 
> 




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
