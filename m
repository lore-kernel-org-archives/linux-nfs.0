From: Tom McNeal <trmcneal@attbi.com>
Subject: Re: Maximum number of nfsd daemons?
Date: Fri, 02 Aug 2002 10:52:29 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D4AC6DD.14E2484@attbi.com>
References: <FB5B6B9A4BA0104886C8394BB2B7C7B803ACAD5E@TOMBO.legato.com> <15689.54017.692185.573037@notabene.cse.unsw.edu.au> <3D4A9141.9050104@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sccrmhc02.attbi.com ([204.127.202.62])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17agXa-00089l-00
	for <nfs@lists.sourceforge.net>; Fri, 02 Aug 2002 10:48:42 -0700
To: Andreas Behnert <abehn@gmx.net>
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

Andreas Behnert wrote:
> 
> Neil Brown wrote:
> >>fiona:~# cat /proc/net/rpc/nfsd
> >>rc 19 123835 15603248
> >>fh 10 15227728 0 14 188
> >>io 3752095213 1826934055
> >>th 128 0 34.710 2.230 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000>
>  >>
> > This line says
> [...]
> >
> >>ra 256 8316937 462671 10814 6530 3748 4498 2851 3290 1583 1881 402138
> >>net 15727611 15727611 0 0
> >>rpc 15727102 509 509 0 0
> >>proc2 18 856 35104 6 0 9044 349 329927 0 0 83 0 0 0 0 223 0 1890 569
> >>proc3 22 144698 1357961 50256 519080 2198920 744533 8887018 60150 5539 710 1
> >>0 4486 383 127 0 268983 1005032 88344 6016 4533 2281
> >
> > Everything else looks normal, but you haven't been running this server
> > for long.  Maybe you need a longer period of data collection.
> [...]
> 
> It would be great if an explanation of /proc/net/rpc/nfsd could go
> into the HOWTO ...   :)

I'll look into it; there is already some discussion in the performance
section about some of the proc files, and the thread counts in
/proc/net/rpc/nfsd

Tom

--
------------------------------------------------------------
Tom McNeal       trmcneal@attbi.com     (650)906-0761 (cell) 
------------------------------------------------------------


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
