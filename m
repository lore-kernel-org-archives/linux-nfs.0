From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Maximum number of nfsd daemons?
Date: Thu, 8 Aug 2002 06:18:29 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15697.32917.218601.482586@notabene.cse.unsw.edu.au>
References: <FB5B6B9A4BA0104886C8394BB2B7C7B803ACAD5A@TOMBO.legato.com>
	<15688.47255.83237.874274@notabene.cse.unsw.edu.au>
	<20020801194339.76fbfb11.philippe.gramoulle@mmania.com>
	<15696.65206.947132.844146@notabene.cse.unsw.edu.au>
	<20020807150721.1736ec6f.philippe.gramoulle@mmania.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17cXFr-0003m9-00
	for <nfs@lists.sourceforge.net>; Wed, 07 Aug 2002 13:18:03 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <philippe.gramoulle@mmania.com>)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Thu, 8 Aug 2002 06:17:53 +1000
To: Philippe =?ISO-8859-1?B?R3JhbW91bGzp?= <philippe.gramoulle@mmania.com>
In-Reply-To: message from Philippe Gramoullé on Wednesday August 7
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

On Wednesday August 7, philippe.gramoulle@mmania.com wrote:
> 
>  
>   |  
>   |  "NFS server not responding" can be due to the receive queue filling up
>   |  on the NFS server.
>   |   while true; do netstat -nta | grep :2049 ; sleep 1; done
> 
> i'm not using TCP right now :o) but will do very soon as i've just build a kernel with all
> your patches.
> 

I was actually thinking UDP.  The 't' flag was a mistake.
If you have working TCP support, then this is all taken care of by the
kernel and you don't have to worry about it.

NeilBrown


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
