From: Tom McNeal <trmcneal@attbi.com>
Subject: Re: redhat 2.4.18-5 client huge slowdown
Date: Tue, 09 Jul 2002 15:19:10 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D2B615E.5090801@attbi.com>
References: <E17S0Jk-0006ZT-00@usw-sf-list2.sourceforge.net> <3D2B373E.2030602@genomes.rockefeller.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sccrmhc01.attbi.com ([204.127.202.61])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17S3Gz-0005h6-00
	for <nfs@lists.sourceforge.net>; Tue, 09 Jul 2002 15:15:53 -0700
To: Raphael Clifford <clifford@genomes.rockefeller.edu>
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



Raphael Clifford wrote:

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
> 


The sync/async default is determined at the server, not the client,
and Solaris defaults to sync, as does almost everyone else.

Also, the default is determined in the utilities, not in the kernel,
which is why Linux servers currently default to async.  They will
default to sync when using the latest, unreleased export utilites;
They will be released "very soon" as version 1.0.1.

Regards -

Tom
--
----------------------------------------------------------------------
Tom McNeal           trmcneal@attbi.com           (650)906-0761 (cell)
----------------------------------------------------------------------



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Stuff, things, and much much more.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
