From: Matthew Mitchell <matthew@geodev.com>
Subject: Need help with NFSD hang in 2.4.20+NFS_ALL
Date: Tue, 10 Jun 2003 10:55:33 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EE5FF75.5020104@geodev.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from gateway2.geodev.com ([64.45.165.170] ident=[rheMzrCbIyzBiyz8md87QtxuR+dp/bem])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19PlX2-0005vl-00
	for <nfs@lists.sourceforge.net>; Tue, 10 Jun 2003 08:59:32 -0700
Received: from geodev.com (smithers.geodev.com [192.168.201.178])
	by gateway2.geodev.com (8.11.6/8.11.6) with ESMTP id h5AFtRv31044
	for <nfs@lists.sourceforge.net>; Tue, 10 Jun 2003 10:55:27 -0500
To: nfs@lists.sourceforge.net
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

Everyone,

This morning I arrived at the office to find an NFS server hung up and 
users whining at me.

It appeared that an updatedb launched from a cron job had gotten hung 
up.  Perhaps it caused some sort of overload, I'm not really sure. 
System load was over 130, which is about what I expected given that we 
had 128 nfs daemon threads, all of which were presumably waiting.

Since nothing was responding (couldn't touch the affected disk, couldn't 
  successfully sync), I tried to start a "graceful" shutdown, and the 
exportfs -ua step hung.  A strace -p of that process showed it hung up in

	nfsservctl(0x4, <some address>, 0)

on the first mount listed in /var/lib/nfs/xtab.  Nothing I could do 
would make it move, and it wouldn't get any closer to shutdown so I had 
to cycle the power.  Joy.

Now, some background info: the NFS shared partition is a 
loopback-mounted reiserfs partition, the file underlying which rests on 
a big SW-raid volume.  (It's every bit as awful as it sounds.)  I don't 
think NFS is necessarily the culprit here but it did seize up in the 
most painful way.

There were some messages that looked like they were from lockd in the 
ring buffer but (I see now) they never got written to the messages file. 
  Damn.

Does it sound feasible to anyone who might know that the system might 
have just hiccuped under the load of the updatedb process?  That's not 
exactly good, but I can easily prevent it from running again...

More germane to this list: if I find this hung up again, is there 
anything I can do to diagnose the problem?  I don't know now if changing 
the value of /proc/sys/sunrpc/nfsd_debug would have any effect, but if 
someone suggests a good value I will try it.

This is a SMP box.

I'd greatly appreciate any help or suggestions or even questions to try 
to figure out what is going on.

-- 
Matthew Mitchell
Systems Programmer/Administrator            matthew@geodev.com
Geophysical Development Corporation         phone 713 782 1234
1 Riverway Suite 2100, Houston, TX  77056     fax 713 782 1829



-------------------------------------------------------
This SF.net email is sponsored by:  Etnus, makers of TotalView, The best
thread debugger on the planet. Designed with thread debugging features
you've never dreamed of, try TotalView 6 free at www.etnus.com.
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
