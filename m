From: gb <bakerg3@yahoo.com>
Subject: Linux / tcp-nfs / NetApp problems (summary)
Date: Wed, 11 Jun 2003 10:27:47 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030611172747.69056.qmail@web41303.mail.yahoo.com>
Reply-To: greg@bakers.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from web41303.mail.yahoo.com ([66.218.93.52])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Q9O4-00040s-00
	for <nfs@lists.sourceforge.net>; Wed, 11 Jun 2003 10:27:53 -0700
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


I'd like to thank Charles Lever and Trond for not only
helping narrow down where the problem was occuring,
but for providing a fix (patches) for our linux
clients that enable them to once again play nicely
with NetApps using tcp-nfs when under heavy network
load.  

All of this was done out of the kindness of their
hearts, and the linux NFS community (especially me) is
in their debt.

* Environment:

A large (sample size 30) base of linux clients
(2.4.18) using tcp-nfs (iozone generated) to a NetApp
760 filer running 6.2.2D21. 

server/directory/mount options:

vger:/vol/vol2/admin-test2 /u/admin-test2 nfs
rw,v3,rsize=32768,wsize=32768,hard,intr,tcp,lock,addr=vger
0 0 

admin-test2 (vger:vol2) has 13 disks + 1 parity

Problem Summary:

When the linux clients (2.4.18) begin accessing the
same partition on the filer (reads/writes), the linux
clients process performing the access "hangs".  Syslog
 output contains these messages:

 can't get request slot
 nfs server not responding

The process itself (and other requests to the mount
point) hang in a "disk sleep" status.

[root@valk101 log]# cat /proc/2123/status
Name: bash
State: D (disk sleep) 
 
After looking at multiple tcpdump and rpc debug logs,
Charles hit the nail on the head with this suggestion:

"the filer closes the TCP window on sockets that
are creating a heavy load. this is meant as a
form of back pressure on clients to cause them
to slow down... it looks like the Linux clients are
not recognizing this subtle hint, and continue to
generate more requests even though the TCP window is
small or zero."

Trond jumped on this, and produced a series of patches
over time and testing that fixed the linux client-side
issues using tcp-nfs.  For what they do, I suggest
looking here:

http://www.fys.uio.no/%7Etrondmy/src/2.4.21-rc6/

linux-2.4.21-14-xprt_fixes.dif
linux-2.4.21-15-fix_tcprace.dif
linux-2.4.21-16-fix_tcprace2.dif
linux-2.4.21-17-fix_tcprace3.dif

Using the base 2.4.21-rc7 kernel + above patches, we
get the expected (linux client) behavior...

1. linux clients generate huge load on filer
2. filer advertises window 0
3. linux clients probe filer, wating for window size
to increase

...time passes... <count to 300 slowly>

4. filer closes tcp connection
5. linux clients re-open connection and continue
merrily along their way

I'm working with NetApp to answer the question, "Why
is the filer advertising a receive window of 0 and
eventually closing a tcp connection, instead of
re-opening it's receive window as resources become
available?"

But, for the meantime, linux 2.4.21-rc7 + Trond
patches, make our linux + NetApp environment happy!

Thanks everyone,

--Greg

__________________________________
Do you Yahoo!?
Yahoo! Calendar - Free online calendar with sync to Outlook(TM).
http://calendar.yahoo.com


-------------------------------------------------------
This SF.NET email is sponsored by: eBay
Great deals on office technology -- on eBay now! Click here:
http://adfarm.mediaplex.com/ad/ck/711-11697-6916-5
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
