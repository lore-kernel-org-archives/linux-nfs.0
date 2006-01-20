From: Rajesh Kalmady <krajesh304@gmail.com>
Subject: nfs mounting problem in a linux cluster
Date: Fri, 20 Jan 2006 18:03:43 +0530
Message-ID: <536c333e0601200433s270e4e47x@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EzvSa-0001hw-Iu
	for nfs@lists.sourceforge.net; Fri, 20 Jan 2006 04:33:44 -0800
Received: from zproxy.gmail.com ([64.233.162.206])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EzvSa-00031h-Dy
	for nfs@lists.sourceforge.net; Fri, 20 Jan 2006 04:33:44 -0800
Received: by zproxy.gmail.com with SMTP id r28so428077nza
        for <nfs@lists.sourceforge.net>; Fri, 20 Jan 2006 04:33:43 -0800 (PST)
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

I have a linux cluster with RHEL 4.1 installed in all nodes and the
NFS servers too. I have a
strange problem of NFS mounting. When I try to mount a file system
from the NFS server  on
to all nodes, I find that the mount hangs in some nodes, but works in
others normally. I go to that node, kill the mount command and run it
again, it works. The set of nodes where it
does not work is also random.

I was doing this using a shell script which uses rsh to issue mount
commands on the nodes,
one by one. I thought that maybe the NFS server cannot handle rapid
requests, so I put a
sleep of 2 seconds between successive mount commands. But there was no
change in
the behavior.

After some diagnosing using tcpdump, I found that the mount client
first contacts the
RPC portmapper, then the NFS port and then the port where mountd is
listening. In those
machines where it does not work, I found that portmapper and nfs are
contacted but after
this, there is no progress.

The linux version is 2.6.9 (the one which comes in RHEL 4.1).

The same behavior happens when I unmount the partition too.

Could some experts help me out please ?

regards

Rajesh


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
