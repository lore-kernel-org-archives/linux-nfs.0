From: Oliver Korff <oliver.korff@credativ.de>
Subject: kernel-nfs -- Too much mount requests?
Date: Thu, 29 Aug 2002 17:44:16 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020829154418.E1EAFD756B@www.credativ.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from cdt1.tz-juelich.de ([195.37.52.66] helo=www.credativ.de)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17kRVo-0000E6-00
	for <nfs@lists.sourceforge.net>; Thu, 29 Aug 2002 08:47:12 -0700
Received: from there (localhost [127.0.0.1])
	by www.credativ.de (Postfix) with SMTP id E1EAFD756B
	for <nfs@lists.sourceforge.net>; Thu, 29 Aug 2002 17:44:17 +0200 (CEST)
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

Hi,

my NFS server not to be able to handle all its mount requests.

Problem report:
1. Clients loose connection from time to time and show nfs-stale
2. Server foo has only an uptime of about 2 Days then system crash (mostly 
under heavy nfs-load)
3. 250 Clients accessing a 500G Partitition

Are there any limitations for the nfs-kernel server?
How to improve stability?


Input:
Debian Woody 
Kernel 2.4.19
package nfs-kernel-server-1.0-2

######### logfiles output:

Aug 28 14:10:54 foo rpc.statd[213]: Received erroneous SM_UNMON
request from foo for 10.10.10.57
Aug 28 14:10:54 foo rpc.statd[213]: Received erroneous SM_UNMON
request from foo for 10.10.10.105
Aug 28 14:10:54 foo rpc.statd[213]: Received erroneous SM_UNMON
request from foo for 10.10.10..87
Aug 28 14:10:54 foo rpc.statd[213]: Received erroneous SM_UNMON
request from foo for 10.10.10.119

#############

Aug 28 09:55:44 foo rpc.mountd: authenticated mount request from
lxg0220.bar.de:693 for /BARroot (/BARroot) 
Aug 28 09:59:49 foo rpc.mountd: authenticated mount request from
lxg0220.bar.de:790 for /BARroot/Log (/BARroot/Log) 

#############

Aug 27 08:38:05 client kernel: nfs: server foo not responding, still
trying
Aug 27 08:40:12 client kernel: nfs: task 18177 can't get a request slot
Aug 27 08:59:33 client kernel: nfs: task 18178 can't get a request slot
Aug 27 09:03:01 client kernel: nfs: task 18179 can't get a request slot
Aug 27 09:32:01  client kernel: nfs: task 18180 can't get a request slot
Aug 27 10:03:01 client kernel: nfs: task 18181 can't get a request slot
Aug 27 10:32:01 client kernel: nfs: task 18182 can't get a request slot
Aug 27 11:03:01 client kernel: nfs: task 18183 can't get a request slot
Aug 27 11:15:43 client kernel: nfs: server foo OK
Aug 27 11:15:43 client last message repeated 7 times
Aug 27 17:30:11 client kernel: nfs: server foo not responding, still
trying
Aug 27 17:30:32 client kernel: nfs: server foo OK
Aug 28 09:16:29 client kernel: nfs: server foo not responding, still
trying
Aug 28 09:16:34 client kernel: nfs: server foo OK

######## end
-- 
Oliver Korff, credativ GmbH
Karl-Heinz-Beckurts-Str. 13
52428 Jülich, Germany
Tel.:  +49 (2461) 69071-0
Fax:   +49 (2461) 69071-1



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
