From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: RE: Maximum number of nfsd daemons?
Date: Fri, 2 Aug 2002 10:32:01 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15689.54017.692185.573037@notabene.cse.unsw.edu.au>
References: <FB5B6B9A4BA0104886C8394BB2B7C7B803ACAD5E@TOMBO.legato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17aQLr-00021C-00
	for <nfs@lists.sourceforge.net>; Thu, 01 Aug 2002 17:31:31 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <dbarbar@legato.com>) (for <nfs@lists.sourceforge.net>) By tone
	With Smtp ; Fri, 2 Aug 2002 10:31:22 +1000
To: Daniel Barbar <dbarbar@legato.com>
In-Reply-To: message from Daniel Barbar on Thursday August 1
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

On Thursday August 1, dbarbar@legato.com wrote:
> Neil, Erich:
> 
> 	Thanks for the replies. Here is the content of /proc/net/rpc/nfsd:
> 
> fiona:~# cat /proc/net/rpc/nfsd 
> rc 19 123835 15603248
> fh 10 15227728 0 14 188
> io 3752095213 1826934055
> th 128 0 34.710 2.230 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000

This line says
" You have 128 threads.
  You have never used the last thread.
  You have used between 1 and 12 threads (10%) for a total of 34.7 seconds.
  You have used between 13 and 25 threads for a total of 2.23 seconds.
  You have not noticably used more that 25 threads.
"

So if this load is typical, then you don't need more threads.


> ra 256 8316937 462671 10814 6530 3748 4498 2851 3290 1583 1881 402138
> net 15727611 15727611 0 0
> rpc 15727102 509 509 0 0
> proc2 18 856 35104 6 0 9044 349 329927 0 0 83 0 0 0 0 223 0 1890 569
> proc3 22 144698 1357961 50256 519080 2198920 744533 8887018 60150 5539 710 1
> 0 4486 383 127 0 268983 1005032 88344 6016 4533 2281

Everything else looks normal, but you haven't been running this server
for long.  Maybe you need a longer period of data collection.

> 
> 	Most clients are Solaris (IS&T here is very Solaris centric). I was
> considering installing the patch to enable NFS/TCP, I just wasn't sure
> because of its "experimental" state. Have you guys gotten a feeling for its
> stability? Thanks again,

I don't use it.   It should only improve performance if you loose
packets on your network.  A well switched lan with uniform interface
speeds should not notice.  If you have a saturated lan, or interfaces
of different speeds (e.g. Gigabit client, 100M server) then TCP could
help.

NeilBrown


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
