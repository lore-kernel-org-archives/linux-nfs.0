From: Andrew Ryan <andrewr@nam-shub.com>
Subject: RE: 3 bugs with UDP mounts
Date: Tue, 23 Apr 2002 00:37:15 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5.0.2.1.0.20020422235308.02a960b0@pop.sfrn.dnai.com>
References: <6440EA1A6AA1D5118C6900902745938E50CEBE@black.eng.netapp.co
 m>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from barney.sfrn.dnai.com ([208.59.199.24])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16zurC-0003WK-00
	for <nfs@lists.sourceforge.net>; Tue, 23 Apr 2002 00:36:58 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <6440EA1A6AA1D5118C6900902745938E50CEBE@black.eng.netapp.co
 m>
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

At 06:23 PM 4/22/02 -0700, Lever, Charles wrote:
>for the whole list:  when reporting issues against NetApp filers,
>please mention the OnTap version and filer hardware if you can...
>that would help us a lot!  thanks!

Sorry: F820, 6.1.2R3.


> > network: 100baseTx-FD on client, gigE-FD on server
> >
> > 1. UDP read performance (v2 and v3) on large files is really
> > poor. [....]
> > I can get excellent read performance, as long as the files
> > are relatively small.
>
>you are probably hitting the network speed step down between
>the GbE filer and the 100Mb client.  the first packet loss
>will cause your read throughput to drop.  i'll bet your
>small file knee occurs right about at the size of your switch's
>memory buffer.

I'm not seeing any packet loss on client or server acc. to interface 
statistics. How would I find this out? I am seeing a 2 second delay between 
reads when I turn on NFS debugging. A thread ("2.4.18: NFS_ALL patch 
greatly hurting UDP speed") mentioned this same delay, so I'm probably 
running into the same problem.

BTW, I did more performance tests. If I set rsize and wsize to 1024 or 
2048, I can get acceptable performance with NFS+UDP. If I go to 4096 or 
higher, performance drops immediately to an unacceptable level.


>have you tried this test with TCP?

Yeah, TCP performance is fine. It's the hangs under 2.4.17+NFS-ALL 
(described in an earlier mail) that are killing me. The hangs seem to have 
gone away in 2.4.19pre7+NFS-ALL, but I need more time to test all of 
2.4.19pre7 in my environment to make sure it holds up OK.



>Solaris may have workarounds (like a loose interpretation of
>Van Jacobsen) or bugs that allow this to work well.  just a guess.

Would it be possible -- via a kernel option or mount option -- to control 
the behavior in the Linux client as well so that high performance can be 
achieved on a Linux NFS client with high block sizes and UDP? Mixed 
100/1000 networks are becoming more of a reality and NFS/TCP, while having 
gotten tremendously better in the last year or so, is still a work in 
progress, and it's nice to have another acceptable option for mounting.

Solaris has clearly solved this problem somehow -- it would be nice if 
linux could as well.


>we have filers mounted with UDP and r/wsize=32K from a R7.2 system
>running 2.4.19pre.  NFS over UDP allows r/wsize up to 32K.

Right, my bad. I was confused by a day of too many mounts and umounts and 
too little stuff working properly. 32k should have been fine.


>the mismatch between the requested size and the reported mount
>options i have never seen before, and looks like a bug to me.
>your version of mount may not allow more than 8k r/wsize because
>of old limitations on the Linux server?

I'm using mount 2.11g, as supplied with RH 7.2. Is there a newer mount 
program I should be using? Can others duplicate this bug?


thanks,
andrew


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
