From: Paul Heinlein <heinlein@cse.ogi.edu>
Subject: Re: limitations at 5,8 GB?
Date: Wed, 31 Dec 2003 08:54:38 -0800 (PST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0312310849460.6614@pecos.madboa.com>
References: <200312251945.42382.nuway@gmx.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AbjcN-0004xD-6K
	for nfs@lists.sourceforge.net; Wed, 31 Dec 2003 08:54:47 -0800
Received: from franklin.cse.ogi.edu ([129.95.40.9])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1AbjcM-0004pO-Qu
	for nfs@lists.sourceforge.net; Wed, 31 Dec 2003 08:54:46 -0800
To: Stefan Ewert <nuway@gmx.net>
In-Reply-To: <200312251945.42382.nuway@gmx.net>
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

On Thu, 25 Dec 2003, Stefan Ewert wrote:

> im new to nfs and i googeld about this problem but i didnt find a
> solution for the following problem:
>
> I got a 100 GIG harddisk on my server and i mounted it on my client
> without any warnings or problems. the only thing is that i now have
> 5.8 GB instead of 100. Are there any restrictions in nfs protocol,
> or do u know a possible solution for this prob?

There's certainly no problem with a 100GB export. I'm using a Linux
server to export a 1.7-terabyte filesystem without difficulty.

I assume that you see the full 100 GB on your server, right? If so,

* Do you have any quota limitations on client or server?

* Is the 100GB disk divided into smallish partitions, or is it one
  huge partition? It could be that you've mounted just one of the
  partitions instead of all of them.

-- Paul Heinlein <heinlein@cse.ogi.edu>


-------------------------------------------------------
This SF.net email is sponsored by: IBM Linux Tutorials.
Become an expert in LINUX or just sharpen your skills.  Sign up for IBM's
Free Linux Tutorials.  Learn everything from the bash shell to sys admin.
Click now! http://ads.osdn.com/?ad_id=1278&alloc_id=3371&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
