From: Steve Dickson <SteveD@RedHat.com>
Subject: Re: remounting with a different blocksize
Date: Wed, 17 Sep 2003 06:57:25 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F683E15.6010708@RedHat.com>
References: <009401c37ce7$44aa31c0$1301a8c0@CARTMAN>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19za0c-0007L8-00
	for <nfs@lists.sourceforge.net>; Wed, 17 Sep 2003 03:58:06 -0700
Received: from host-64-179-20-100.man.choiceone.net ([64.179.20.100] helo=Odyssey.Home.4Dicksons.Org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 19za0c-0008Nv-1I
	for nfs@lists.sourceforge.net; Wed, 17 Sep 2003 03:58:06 -0700
To: Amir Hermelin <amir@montilio.com>
In-Reply-To: <009401c37ce7$44aa31c0$1301a8c0@CARTMAN>
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


Amir Hermelin wrote:

>I'm using RH Linux 2.4.20 on both machines.  When I first mount one of the
>machines with a 4k read/write blocksize, the READ requests are 4K bytes.
>However, when I umount and then mount again with read/write blocksize of 8K,
>the READ requests are still 4K bytes.
>
>Any ideas on how I can properly change the blocksizes?
>
I just ran a quick experiment on with my 2.4.20 kernel and everything
seem to work as expected... How are you verifying the blocks sizes?

SteveD.




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
