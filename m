From: Brent Clements <bclem@rice.edu>
Subject: input/output error
Date: 07 Mar 2003 10:37:27 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1047055047.30015.18.camel@batman.ece.rice.edu>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
To: NFS@lists.sourceforge.net
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

I am getting the following error when I do this.

time dd if=/dev/zero of=/users/testfile bs=16k count=65536

dd: writing `/users/testf2': Input/output error
41986+0 records in
41985+0 records out

real    0m11.301s
user    0m0.040s
sys     0m1.779s

I'm only getting partial writes of the file. IE..it never completes
writing the file. 

I am using an hp/ux fileserver as my nfs server and it is version 3

The following is the output from /proc/mounts on my linux-2.4.20 ia64 
client.

rtcfiler:/users/users /users nfs
rw,v3,rsize=32768,wsize=32768,soft,udp,lock,addr=rtcfiler 0 0


Does anyone have any idea how I can debug why its doing this? Or has
anyone seen this before?

Thanks,
Brent Clements
Rice University




-------------------------------------------------------
This SF.net email is sponsored by: Etnus, makers of TotalView, The debugger 
for complex code. Debugging C/C++ programs can leave you feeling lost and 
disoriented. TotalView can help you find your way. Available on major UNIX 
and Linux platforms. Try it free. www.etnus.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
