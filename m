From: Peter Niessen <niessen@ifh.de>
Subject: Re: NFS/NAT(MASQUERADING) trouble
Date: Mon, 23 Sep 2002 09:34:46 +0200 (METDST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.HPX.4.33.0209230931430.8452-100000@hpbai1.ifh.de>
References: <20020922021108.GD30397@perlsupport.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <nfs@lists.sourceforge.net>, Steven Lowette <lowette@hep.iihe.ac.be>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from znsun1.ifh.de ([141.34.1.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17tNkE-0003TD-00
	for <nfs@lists.sourceforge.net>; Mon, 23 Sep 2002 00:35:02 -0700
To: Chip Salzenberg <chip@pobox.com>
In-Reply-To: <20020922021108.GD30397@perlsupport.com>
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

On Sat, 21 Sep 2002, Chip Salzenberg wrote:

Hi Chip,

thanks for your mail.

> According to Peter Niessen:
> > the master machine, and only this one, gets into trouble.
 ....
>
> What do you mean by the 'master' machine "losing" the disks?

It means that the NFS link breaks and I get messages like

nfs server my_nfs_server not responing

and

nfs server my_nfs_server: task 12345 can't get a request slot.

Some more information:

If I run df -h every 120 s on the master, NFS stays stable.

Cheers, Peter.

> --
> Chip Salzenberg         - a.k.a.  -        <chip@pobox.com>
>          "It furthers one to have somewhere to go."
>



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
