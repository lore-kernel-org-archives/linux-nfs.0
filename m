From: Yusuf Goolamabbas <yusufg@outblaze.com>
Subject: Re: redhat 2.4.18-5 client huge slowdown
Date: Wed, 10 Jul 2002 18:54:42 +0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020710105442.GA21856@outblaze.com>
References: <E17S0Jk-0006ZT-00@usw-sf-list2.sourceforge.net> <3D2B373E.2030602@genomes.rockefeller.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 202-77-223-51.outblaze.com ([202.77.223.51] helo=corpmail.outblaze.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17SF7S-0001X0-00
	for <nfs@lists.sourceforge.net>; Wed, 10 Jul 2002 03:54:51 -0700
Received: from yusufg.portal2.com (202-77-223-2.outblaze.com [202.77.223.2])
	by corpmail.outblaze.com (8.12.3/8.12.3) with SMTP id g6AAsg28007160
	for <nfs@lists.sourceforge.net>; Wed, 10 Jul 2002 10:54:42 GMT
To: Raphael Clifford <clifford@genomes.rockefeller.edu>
In-Reply-To: <3D2B373E.2030602@genomes.rockefeller.edu>
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

Can you see if reducing rsize,wsize to 8192 seems to help

This bugzilla entry is referenced by the 2.4.18-5 kernel release note

http://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=64984

Add your observations to it if it makes a difference

> I was wondering if everyone else is experiencing huge nfs write 
> slowdowns using redhat kernel 2.4.18-5 (as opposed to 2.4.18-4).  I am 
> using a Sun Solaris machine as the server and following mount options.
> 
> rw,rsize=32768,wsize=32768,nfsvers=3,proto=tcp
> 
> I understand that both 2.4.18-4 and 2.4.18-5 default to 'sync' but as 
> the slow down is between those versions so that shouldn't make any 
> difference.  I also understand that there were a lot of nfs client 
> "fixes" in 2.4.18-5 so I assume they have caused this problem.
> 
> The linux machine is a dual 500 MHz if that makes any difference.
> 
> Cheers,
> Raphael


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Two, two, TWO treats in one.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
