From: Daniel Barbar <dbarbar@legato.com>
Subject: RE: Maximum number of nfsd daemons?
Date: Thu, 1 Aug 2002 08:30:40 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <FB5B6B9A4BA0104886C8394BB2B7C7B803ACAD5E@TOMBO.legato.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from smtp1.legato.com ([137.69.200.1])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17aHvg-0005c4-00
	for <nfs@lists.sourceforge.net>; Thu, 01 Aug 2002 08:31:56 -0700
To: "'Neil Brown'" <neilb@cse.unsw.edu.au>
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

Neil, Erich:

	Thanks for the replies. Here is the content of /proc/net/rpc/nfsd:

fiona:~# cat /proc/net/rpc/nfsd 
rc 19 123835 15603248
fh 10 15227728 0 14 188
io 3752095213 1826934055
th 128 0 34.710 2.230 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000
ra 256 8316937 462671 10814 6530 3748 4498 2851 3290 1583 1881 402138
net 15727611 15727611 0 0
rpc 15727102 509 509 0 0
proc2 18 856 35104 6 0 9044 349 329927 0 0 83 0 0 0 0 223 0 1890 569
proc3 22 144698 1357961 50256 519080 2198920 744533 8887018 60150 5539 710 1
0 4486 383 127 0 268983 1005032 88344 6016 4533 2281

	Most clients are Solaris (IS&T here is very Solaris centric). I was
considering installing the patch to enable NFS/TCP, I just wasn't sure
because of its "experimental" state. Have you guys gotten a feeling for its
stability? Thanks again,

---
Daniel Barbar



-----Original Message-----
From: Neil Brown [mailto:neilb@cse.unsw.edu.au]
Sent: Wednesday, July 31, 2002 9:27 PM
To: Daniel Barbar
Cc: 'nfs@lists.sourceforge.net'
Subject: Re: [NFS] Maximum number of nfsd daemons?


On Wednesday July 31, dbarbar@legato.com wrote:
> Hi,
> 
>   We recently moved one of our NFS servers from a Sun machine running
> Solaris 7 to an Intel box running SuSE Linux 8.0 (kernel 2.4.18). We are
> experiencing some (rather heavy) performance problems, more so for clients
> accesing the service over our WAN link.
>   I'm starting to go through the excerise of tuning the NFS system, and
> started first by trying to increase the number of nfsd process. It seems
> that there is a hard coded limit of 128 processes, is that correct? If
true,
> is it because one shouldn't expect any substantial performance increase by
> setting the number of nfsd threads to a number larger than 128?

This is correct in 2.4.18.  
2.4.18 will have a substantially larger limit.
Just change the #define in fs/nfsd/nfssvc.c and recompile for a larger
limit.

I guess when the number was chosen, computers were smaller.
It could be that more than 128 threads will help you, but it would be
worth checking 
   /proc/net/rpc/nfsd 
to see how many threads are really being used.  Send me the content of
that file and I will interpret bits for you.

NeilBrown


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
