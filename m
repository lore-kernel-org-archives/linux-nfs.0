From: <nfs@septuagint.org>
Subject: frontpage sucks
Date: Wed, 21 Aug 2002 08:52:49 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200208211549.g7LFnSkV023067@iohost.com>
Reply-To: nfs@septuagint.org
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [209.189.124.99] (helo=iohost.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17hXjj-0000b6-00
	for <nfs@lists.sourceforge.net>; Wed, 21 Aug 2002 08:49:35 -0700
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

I have *SEARCHED* and *SEARCHED* the net and can't find anything that touches 
on my problem.

I have a cluster of 2 servers that mount an nfs share from a 3rd.  All 3 
machines are using 2.4.18 kernels and are redhat.  They are also using 
nfs-utils 3.3.  I have mod-frontpage compiled into apache 1.3.26 and 
frontpage works perfectly when the files are locally stored on any of the 2 
servers, but when it is in the nfs share, the frontpg.lck and service.lck 
files cannot be locked by frontpage.  I decompiled shtml.exe (the stupid 
frontpage binary that publishes, etc.) and it seems to use fcntl to lock 
files.

The test lock program that compiles with nfs-utils 3.3 works fine on these 
files, but frontpage cannot lock the files. 

I heard of someone using symlinks on these files to local files on the 
servers like /_vti_bin/frontpg.lck -> /tmp/frontpg.lck, but this doesn't work 
for me, it's like they aren't even there.  I just keep getting a popup box 
when trying to connect to frontpage which is usually what happens when 
service.lck is unavailable.  BUT, if I use a symlink in the nfs share and 
point it to a file in /tmp/test.html I can call it up in a browser just fine 
off of a symlink in a domain's docroot like t.html -> /tmp/test.html

I have nfslock,nfs and portmapper running on all machines, there are no 
errors about file locking except when I turn off nfslock I get this in 
/var/log/messages, this is obviously a frontpage error

Aug 20 20:29:00 w2a kernel: lockd: cannot monitor xx.xx.xx.xx
Aug 20 20:29:00 w2a kernel: lockd: failed to monitor xx.xx.xx.xx
Aug 20 20:29:00 w2a Microsoft FrontPage Server Extensions: 
http://cubes-test-cluster.com - Error #20001 Message: Cannot open file 
"service.c$
Aug 20 20:29:00 w2a Microsoft FrontPage Server Extensions:    (OS Error #37 
Message: No locks available) (userid 500)

How can I get frontpage to lock these files over nfs?

Any information would be GREATLY appreciated.

Thanks
-- 
cube whidden

"Out the ethernet port, through the linux firewall, down the cable modem, 
off the T3,  past the frame-relay...nothing but Net!"


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
