From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: knsfd - files don't sync to disk
Date: Sat, 18 May 2002 06:56:04 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15589.28260.525044.670651@notabene.cse.unsw.edu.au>
References: <3CE40BF7.1090605@chello.se>
	<15588.61537.552697.595814@notabene.cse.unsw.edu.au>
	<3CE53B56.8040303@chello.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 178omB-00064X-00
	for <nfs@lists.sourceforge.net>; Fri, 17 May 2002 13:56:36 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <publius@chello.se>) (for <nfs@lists.sourceforge.net>) By tone
	With Smtp ; Sat, 18 May 2002 06:56:25 +1000
To: =?ISO-8859-1?Q?J=F6rgen_Karlsson?= <publius@chello.se>
In-Reply-To: message from =?ISO-8859-1?Q?J=F6rgen_Karlsson?= on Friday May 17
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

On Friday May 17, publius@chello.se wrote:
> We are using NFSv2.
> 
> We have found a temporary workaround by reducing the number of nfs threads
> to 1. 
> 
> We have a 30 processor cluster that gave zero size files everytime we made
> a backup. By reducing the number of threads from 8 to 1 we were able to make
> 25 backups without any problem. Switching back to 8 threads we immediately
> got the corrupted files back.
> 
> Maybe some down() and up() are missing.......
> 
> If you think the the patch may fix it for v2 as well as v3 we can try the
> patch next week.

The patch would not affect NFSv2 with the no_wdelay export option, so
if that combination still have problems, don't bother with the patch.

> 
> Can running with only one thread cause any performance problems (with
> sync the bottleneck probably is disk io....)?

The more threads, the more concurrent IO you can be waiting on, so I
would definately expect a reduction in performance.

The whole scenario is very odd..
You have confirmed that nfsd does actually write data to the file, but
if you look afterwards, the file is empty.
This suggests that one of:
  It wrote to the wrong file by mistake
  A subsequent "truncate" request was received
  The filesystem lied when it said that it had written data.

Can you get a complete  tcpdump trace of NFS activity on the server
and let me have a look at it?
Something like

   tcpdump -w /var/tmp/file -s 1500 port 2049
   bzip2 /var/tmp/file

on the server, and let me know where to pick it up??

NeilBrown

_______________________________________________________________

Hundreds of nodes, one monster rendering program.
Now that’s a super model! Visit http://clustering.foundries.sf.net/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
