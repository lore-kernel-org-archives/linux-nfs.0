From: Paul Heinlein <heinlein@cse.ogi.edu>
Subject: Re: RedHat/Mandrake NFS - not playing nice
Date: Mon, 17 Feb 2003 14:28:55 -0800 (PST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0302171425550.928-100000@glenfiddich.cse.ogi.edu>
References: <3E515C6E.6040609@mleads.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from franklin.cse.ogi.edu ([129.95.40.7])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18ktl0-0008E6-00
	for <nfs@lists.sourceforge.net>; Mon, 17 Feb 2003 14:29:02 -0800
To: Santiago <santi@mleads.com>
In-Reply-To: <3E515C6E.6040609@mleads.com>
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

On Mon, 17 Feb 2003, Santiago wrote:

> However, I still am receiving the same error as before:
> [root@backup linux]# mount 10.0.0.48:/var/www/html /r/amanda/nitro-html 
> -t nfs
> mount: 10.0.0.48:/var/www/html failed, reason given by server: 
> Permission denied

I hate to ask the obvious questions, but

* Is there anything in /etc/host.deny that would keep your client from
  getting to the server?

* Is there any sort of ipchains/iptables packet filtering that would 
  keep your client from getting to the server?

* Do the logs on the server offer any clues as to why it doesn't like 
  your client's mount requests?

--Paul Heinlein <heinlein@cse.ogi.edu>



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
