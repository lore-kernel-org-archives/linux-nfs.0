From: "Steve Salazar" <eagsalazar@hotmail.com>
Subject: (no subject)
Date: Sun, 09 Mar 2003 19:58:22 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <F73Wd7KKQpQq5pneeFU00010ce9@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from f73.law10.hotmail.com ([64.4.15.73] helo=hotmail.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18s6wG-00050Z-00
	for <nfs@lists.sourceforge.net>; Sun, 09 Mar 2003 11:58:28 -0800
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

I have been reading the nfs documentation and mailing lists and it is not 
clear to me whether the current nfs implementation supports kerberos 
authentication or not.  There is nothing about that in the howto but in the 
mailing list I see repeated references to "NFS using RPCSEC_GSS".  However, 
I haven't found any documentation on this either.

This issue mentioned in the howto:

"But the root user on the client can still use su to become any other user 
and access and change that users files!" say you. To which the answer is: 
Yes, and that's the way it is, and has to be with Unix and NFS. This has one 
important implication: All important binaries and files should be owned by 
root, and not bin or other non-root account, since the only account the 
clients root user cannot access is the servers root account.

will not work for for our setup.  We have kerberos in place for logins on 
our linux/solaris/windows network and a kerberized samba but so far we have 
no good solution for nfs since we will definitely need to allow local root 
on the linux workstations on our network.

Could anyone point me at some good documentation on how to deploy nfs using 
kerberos?  Thanks in advance for any info.



_________________________________________________________________
The new MSN 8: advanced junk mail protection and 2 months FREE*  
http://join.msn.com/?page=features/junkmail



-------------------------------------------------------
This SF.net email is sponsored by: Etnus, makers of TotalView, The debugger 
for complex code. Debugging C/C++ programs can leave you feeling lost and 
disoriented. TotalView can help you find your way. Available on major UNIX 
and Linux platforms. Try it free. www.etnus.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
