From: John Frisk <john_a_frisk@yahoo.com>
Subject: NFS hang in 2.6.21.1
Date: Mon, 21 May 2007 07:18:04 -0700 (PDT)
Message-ID: <767985.78880.qm@web54407.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hq8i7-0003dV-TL
	for nfs@lists.sourceforge.net; Mon, 21 May 2007 07:18:08 -0700
Received: from web54407.mail.yahoo.com ([206.190.49.137])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1Hq8iA-0003oL-Hh
	for nfs@lists.sourceforge.net; Mon, 21 May 2007 07:18:10 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Team,
I have been attempting to put together a linux HA NFS
server for my home environment.  I am currently
running two Debian etch 4.0 machines both running
vanilla 2.6.21.1 kernels that I compiled (exception
being the nvidia driver for video).  When I attempt to
do some performance benchmarks, a test of bonnie++
makes the NFS client stuck in a non-responsive
non-killable state.  The NFS server at this point is
not busy doing anything so I believe there may be some
condition leading to a deadlock in the client. 

jfrisk@evil:~$ df -k .
Filesystem           1K-blocks      Used Available
Use% Mounted on
imezru-ha1:/hafs/nethome/jfrisk
                      76791424    409856  75601408  
1% /nethome/jfrisk
jfrisk@evil:~$ mount

imezru-ha1:/hafs/nethome/jfrisk on /nethome/jfrisk
type nfs (rw,hard,intr,bg,addr=192.168.69.7)

jfrisk@evil:~$ /usr/sbin/bonnie++ -f -s 100 -n 1 -r 0
Writing intelligently...done
Rewriting...                   

This is where the bonnie program hangs.
  frisk@evil:~$ ps aux | grep bonnie
jfrisk    6882  0.7  0.0   2708  1012 pts/3    D+  
09:11   0:00 /usr/sbin/bonnie++ -f -s 100 -n 1 -r 0

Top shows the user load at 1.00 (before starting is
0.10) but nothing else  of importance is running on
the system. 

I can reproduce this bug pretty consistently. I have
these machines for use by anyone on the team so I
would appreciate being guided on what to do next to
help debug this issue.  Thanks in advance!            
     


 
____________________________________________________________________________________
Now that's room service!  Choose from over 150,000 hotels
in 45,000 destinations on Yahoo! Travel to find your fit.
http://farechase.yahoo.com/promo-generic-14795097

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
