From: Kapeller Rene PSI <rene.kapeller@psi.ch>
Subject: root_squash problem
Date: Fri, 20 Sep 2002 16:42:33 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D8B33D9.9050006@psi.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from psi11.psi.ch ([129.129.190.111])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17sOzR-0005EN-00
	for <nfs@lists.sourceforge.net>; Fri, 20 Sep 2002 07:42:41 -0700
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

We are running RedHat-6.2 on a file server.
The system is now up for more than 200 days and it's main function is to 
provide nfs service to almost 100 clients on two different networks.

The system has been upgraded as follows:
- nfs-utils-0.3.1-0.6.x.1
- kernel-2.4.17

I have a rather large number of exports entries for different directories.
However, a few clients only have write access as 'root' to the nfs path 
as you see below.

[root]# grep no_root_squash /proc/fs/nfs/exports
/export/install 172.19.78.74(rw,no_root_squash,async,wdelay) # 172.19.78.74
/export/cern    pc2376.psi.ch(rw,no_root_squash,async,wdelay) # 
(129.129.70.42)
/export/csa     129.129.72.97(rw,no_root_squash,async,wdelay) # 
129.129.72.97
/export/exchange        129.129.72.97(rw,no_root_squash,async,wdelay) # 
129.129.72.97

Today I was very surprised (and worried), when I have noticed that 
'root' from any other client can also write to the above nfs directories.

Needles to say, that this is a terrible security whole in our environment.

Thanks for any hint/help
Rene



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
