From: Danny Smith <dannys@cinesite.co.uk>
Subject: Re: NFS Performance Between SGI Servers and Linux Clients
Date: Fri, 23 May 2003 13:09:37 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3ECE0F81.1010400@cinesite.co.uk>
References: <765B6B38B4D29D498077F8E644E23B7FED83EC@nlhoe2k02.europe.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Iain Irwin-Powell <iain@cinesite.co.uk>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from scanman.cinesite.co.uk ([193.203.81.129])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19JBNF-0000ZC-00
	for <nfs@lists.sourceforge.net>; Fri, 23 May 2003 05:10:13 -0700
To: "Kiernan, Michael" <mkiernan@netapp.com>
In-Reply-To: <765B6B38B4D29D498077F8E644E23B7FED83EC@nlhoe2k02.europe.netapp.com>
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

People,

We have patch 5067, which appears from the release notes to obsolete 5022.
We've also got the buf_relse_age systune in place, and haven't seen an
appreciable difference.

Not sure if this is relevant here or not, but we also get infrequent
messages like the one below:

May 23 10:50:57 animal16 kernel: nfs_stat_to_errno: bad nfs status 
return value: 11

My research in the list archives seems to indicate this is a pure server 
issue.
Can anyone explain it in more detail? It would help us greatly in 
feeding this problem
back to SGI.

Any help appreciated.

Danny

Kiernan, Michael wrote:

>Iain,
>
>6.5.19 (and 6.5.17/18/20 for that matter) have a number of known
>fundamental problems [we've seen some nasty client side problems,
>though I've obviously not been involved in server side issues]
>
>NFS patch (5021 or 5022 [don't ask me which one is for 6.5.19, 
>I'm not *that* into irix!] contains a number of important fixes.
>What you're describing is possibly, or is closely related to the
>buf_relse_age bug 886112. you might try the workaround online:
>sgi-hd 2# systune buf_relse_age 10
>        buf_relse_age = 0 (0x0)
>        Do you really want to change buf_relse_age to 10 (0xa)? (y/n)  y
>sgi-hd 3# systune buf_relse_age
>        buf_relse_age = 10 (0xa)
>
>- Mike
>
>-----Original Message-----
>From: Iain Irwin-Powell [mailto:iain@cinesite.co.uk]
>Sent: 22 May 2003 18:32
>To: nfs@lists.sourceforge.net
>Subject: [NFS] NFS Performance Between SGI Servers and Linux Clients
>
>
>
>Does anyone have any ideas about this?
>
>We have been experiencing a number of issues regarding NFS serving on
>SGI IRIX (6.5.19) servers which now appear to point back to Linux NFS
>clients.
>
>The server is an Origin 2000, quad processors, 1.5GB memory, serving
>over Gigabit. This can be reproduced on connections whether or not they
>are using jumbo frames. The disks that are served are hardware RAID3
>capable of around 80-90MB/s (tested and optimised not theoretical). 
>
>Under certain circumstances will get a load average of 8 (or how ever
>many nfsd's are running). The server itself is not that busy. Most of
>the nfsd's show as sleeping but they are obviously waiting for
>something.
>
>Further investigation revealed that this situation arises when a Linux
>client opens many files in quick succession (doing
>open-read-close,open-read-close). We tend to use files in the range
>3MB-13MB in size generally.
>
>If we do the same test on an SGI client there is very little impact on
>the load average.
>
>We can recreate this by doing (on the client);
>
>find . -type -f -print -exec grep jsdhgkhjfdk {} \;
>
>The same effect appears to happen on Linux servers as well. A single
>Linux client doing this will make the load average creep up towards 2.5.
>
>Linux Version 2.4.20
>nfs-utils-1.0.1-1
>exports are exported with -32bitclients
>
>Looking a bit deeper in a packet trace when the grep is running, Linux
>seems to issue 16 read requests (16KB) at a time whilst an SGI will only
>issue between 2 and 4. May or may not be relevant.
>
>This information has also been passed back to SGI who are looking at it.
>
>Packet traces and more detail is available if anyone wants them.
>
>Any ideas or suggestions would be welcome.
>
>******************************************************************
>Iain Irwin-Powell (AKA Iain Powell)
>Senior Systems Administrator
>Cinesite Europe Limited
>9 Carlisle Street
>London
>W1D 3BP
> 
>T: +442079734000
>DDI: +442079734053
>*******************************************************************
>It's not broken, it just doesn't work the way you expected.
>*******************************************************************
>
>
>
>
>-------------------------------------------------------
>This SF.net email is sponsored by: ObjectStore.
>If flattening out C++ or Java code to make your application fit in a
>relational database is painful, don't do it! Check out ObjectStore.
>Now part of Progress Software. http://www.objectstore.net/sourceforge
>_______________________________________________
>NFS maillist  -  NFS@lists.sourceforge.net
>https://lists.sourceforge.net/lists/listinfo/nfs
>
>
>-------------------------------------------------------
>This SF.net email is sponsored by: ObjectStore.
>If flattening out C++ or Java code to make your application fit in a
>relational database is painful, don't do it! Check out ObjectStore.
>Now part of Progress Software. http://www.objectstore.net/sourceforge
>_______________________________________________
>NFS maillist  -  NFS@lists.sourceforge.net
>https://lists.sourceforge.net/lists/listinfo/nfs
>
>  
>


-- 
Danny Smith
Senior Systems Administrator, Cinesite (Europe) Ltd
020 7973 4000 - x4055    /    dannys@cinesite.co.uk




-------------------------------------------------------
This SF.net email is sponsored by: ObjectStore.
If flattening out C++ or Java code to make your application fit in a
relational database is painful, don't do it! Check out ObjectStore.
Now part of Progress Software. http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
