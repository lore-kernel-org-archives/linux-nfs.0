From: shri krishnan <shri_krishnan@yahoo.com>
Subject: rsh sometimes hangs with nfsroot
Date: Mon, 7 Oct 2002 18:28:08 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021008012808.36632.qmail@web13803.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="0-779833622-1034040488=:36299"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from web13803.mail.yahoo.com ([216.136.175.13])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17yjAP-0002w8-00
	for <nfs@lists.sourceforge.net>; Mon, 07 Oct 2002 18:28:09 -0700
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

--0-779833622-1034040488=:36299
Content-Type: text/plain; charset=us-ascii


Hello,

I've been banging my head against the wall for the last couple of weeks trying to figure out why my diskless sparc-linux clients intermittently fail to properly execute programs spawned via rsh. My nfs server is Solaris 2.8, and the client is running 2.4.18, booted with v3 and nolock options, (but the problem occurs as well with v2 with locking). All clients are mounting a single special root filesystem readonly, kind of like a CDROM, with the kernel and writeable parts of the filesystem areas running running in ramdisk

Basically, once the system is booted up, I execute a series of rsh commands from the Solaris server to the linux client. Sometimes, about once every 24 hours or so, one of the rsh commands will simply hang, even a command as simple as rsh "hostname". If I do a ps on the client machine, I see that rshd has spawned a shell process to execute the command, but the actual program never gets spawned. It's not always the same command that hangs. Sometimes the very first rsh hangs, sometimes, later on. Furthermore, if I execute the same rsh commands from my server from the command line, one the machine is in its hung state, they execute perfectly. Only the initial invocation seems to hang.

Now here's where it gets weird. I can sometimes "kick" this hanging process into continuing by issuing additional rsh commands to the client. For example, if I repeatedly do rsh "hostname" in a loop from the server, I can get the hanging process to resume, but not always. Sometimes, just logging into the client will cause the hang to stop. Or logging in and running mount -a. Sometimes, nothing I do will help and I have to reboot the machine.

This problem has only started when moving to  a Solaris nfs server. I have not seen it on a Linux nfs server. I'm able to get some network traces showing the nfs activity but am at a loss as to what to look for to begin debugging this.  

Is there some subtle incompatibility between solaris and linux nfs implementations which could cause this? Has anyone ever this kind of behavior before?

Thanks very much

--shri

 



---------------------------------
Do you Yahoo!?
Faith Hill - Exclusive Performances, Videos, & more
faith.yahoo.com
--0-779833622-1034040488=:36299
Content-Type: text/html; charset=us-ascii

<P>Hello,</P>
<P>I've been banging my head against the wall for the last couple of weeks trying to figure out why my diskless sparc-linux clients intermittently fail to properly execute programs spawned via rsh. My nfs server is Solaris 2.8, and the client is running 2.4.18, booted with v3 and nolock options, (but the problem occurs as well with v2 with locking). All clients are mounting a single special root filesystem readonly, kind of like a CDROM, with the kernel and writeable parts of the filesystem areas running running in ramdisk</P>
<P>Basically, once the system is booted up, I execute a series of rsh commands from the Solaris server to the linux client. Sometimes, about once every 24 hours or so, one of the rsh commands will simply hang, even a command as simple as rsh "hostname". If I do a ps on the client machine, I see that rshd has spawned a shell process to execute the command, but the actual program never gets spawned. It's not always the same command that hangs. Sometimes the very first rsh hangs, sometimes, later on. Furthermore, if I execute the same rsh commands from my server from the command line, one the machine is in its hung state, they execute perfectly. Only the initial invocation seems to hang.</P>
<P>Now here's where it gets weird. I can sometimes "kick" this hanging process into continuing by issuing additional rsh commands to the client. For example, if I repeatedly do rsh "hostname" in a loop from the server, I can get the hanging process to resume, but not always. Sometimes, just logging into the client will cause the hang to stop. Or logging in and&nbsp;running mount -a. Sometimes, nothing I do will help and I have to reboot the machine.</P>
<P>This problem has only started when moving to&nbsp; a Solaris nfs server. I have not seen it on a Linux nfs server. I'm able to get some network traces showing the nfs activity but am at a loss as to what to look for to begin debugging this.&nbsp; </P>
<P>Is there some subtle incompatibility between solaris and linux nfs implementations which could cause this? Has anyone ever this kind of behavior before?</P>
<P>Thanks very much</P>
<P>--shri</P>
<P>&nbsp;</P><p><br><hr size=1>Do you Yahoo!?<br>
<a href="http://faith.yahoo.com">Faith Hill</a> - Exclusive Performances, Videos, & more<br>
<a href="http://faith.yahoo.com">faith.yahoo.com</a>
--0-779833622-1034040488=:36299--


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
