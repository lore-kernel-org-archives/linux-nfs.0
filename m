From: "jamie garton" <jamie_garton@msn.com>
Subject: accessing server mounted file systems
Date: Wed, 23 Apr 2003 22:33:36 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <BAY4-F224S8Uq5nlhRy00012a5b@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from bay4-f22.bay4.hotmail.com ([65.54.171.22] helo=hotmail.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 198JRy-0002He-00
	for <nfs@lists.sourceforge.net>; Wed, 23 Apr 2003 05:34:10 -0700
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

Hi,

I have networked 2 machines using 100Mb ethernet cards and I have set up NFS 
to copy files back and forth.

My problems is that I can only see files that are not mounted locally by the 
server.
i.e I can see all files accept the ones under the /mnt directory like 
/mnt/hda5.

I have tried viewing it by root and a user with no luck. This is my 
/etc/exports file on the server:
/ 192.168.0.1(rw,no_root_squash) 10.0.0.1(rw,no_root_squash)

and this is my auto mount file on the client:
server  -fstype=nfs,rw    10.0.0.2:/

I can only assume it is a security thing that I can not see contents of the 
file system.


I have also noticed that I can write the server's /mnt/hda5 directory from 
the client and the file is not visible from the server.

I hope someone can help.

Regards
Jamie Garton






_________________________________________________________________
Hotmail now available on Australian mobile phones. Go to  
http://ninemsn.com.au/mobilecentral/hotmail_mobile.asp



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
