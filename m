From: Derek Simkowiak <dereks@realloc.net>
Subject: NFS + ssh (NFS HOWTO Question)
Date: Thu, 25 Sep 2003 17:08:34 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F738382.1040907@realloc.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A2gA4-000232-00
	for <nfs@lists.sourceforge.net>; Thu, 25 Sep 2003 17:08:40 -0700
Received: from [63.251.164.134] (helo=intranet.realloc.net)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 1A2gA3-0006Do-GW
	for nfs@lists.sourceforge.net; Thu, 25 Sep 2003 17:08:39 -0700
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


      Hello,
	I have a quick question about the NFS Howto.  There is something in it 
that I do not understand.  I'm working on an ssh tunnel for NFS.


 From http://nfs.sourceforge.net/nfs-howto/security.html
--------------------------------------------------
For example, to have statd broadcast of port 32765 and listen on port 
32766, and mountd listen on port 32767, you would type:

# statd -p 32765 -o 32766
# mountd -p 32767

[...]

lockd is started by the kernel when it is needed. Therefore you need to 
pass module options (if you have it built as a module) or kernel options 
to force lockd to listen and respond only on certain ports.

If you are using loadable modules and you would like to specify these 
options in your /etc/modules.conf file add a line like this to the file:

options lockd nlm_udpport=32768 nlm_tcpport=32768
--------------------------------------------------

	In the above section it says how to force both lockd and statd onto 
certain ports.  But then a little further down on that same page, where 
it talks about NFS over ssh, it has this seemingly contradicting 
information:

--------------------------------------------------
It is not possible to ask statd or the locking manager to make requests 
to a particular port for a particular mount; therefore, any locking 
requests will cause statd to connect to statd on localhost, i.e., 
itself, and it will fail with an error. Any attempt to correct this 
would require a major rewrite of NFS.
--------------------------------------------------

	I do not understand what this means.  First I'm looking at the 
command-line (and module) options to set particular ports, and then 
further on the same page, it says "It is not possible to ask statd or 
the locking manager to make requests to a particular port for a 
particular mount".

	Could somebody elaborate for me?  What am I missing?  (Or is the 
section on ssh outdated?)

	Any help is greatly appreciated.

Thanks,
Derek Simkowiak



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
