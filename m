From: Shem Page <shem_page@alliedtelesyn.com>
Subject: NFS UDP firewall reassemble failure
Date: Thu, 21 Mar 2002 13:16:49 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <00300496.C21145@alliedtelesyn.com>
Reply-To: shem_page@alliedtelesyn.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Received: from smtpgwy.alliedtelesyn.com ([12.7.242.92])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16o9vj-0005Pn-00
	for <nfs@lists.sourceforge.net>; Thu, 21 Mar 2002 13:17:04 -0800
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

I have discovered that my firewall will not re-assemble packets to a length 
of more than about 1800 bytes (what fits in a single buffer).

I have been trying to mount a linux machine through the firewall and discover 
that even if the mount is successful, once I start opening files, the mount 
fails because the firewall cannot reassemble the packets to do it's stateful 
inspection, hence it drops the packets so the client never sees the reply 
from the server.

>From the packet traces  it is evident that the NFS is sending  fragments that 
add up to well over 2k - too much for the software on the router  to 
reassemble.
 
I have been told by the maker of the router that this is not something they 
intend to change in the near future, and perhaps I should look for a solution 
within the configuration of the NFS.

 So after quickly scanning some Man Pages, and also searching this archive, I 
couldn't find any hint at how to restrict Mount, or NFSD to a limited packet 
size.

 Can people indicate to me whether this is possible to do, and perhaps where 
I should begin.

Thanks in advance
Shem 

-- 
==========================================================
Shem Page			Tel 408 523-5305 
Systems Engineer		Fax 408 736-0100
Allied Telesyn			Web: http://www.alliedtelesyn.com
960 Stewart Dr. Suite B		email: Shem_Page@alliedtelesyn.com
Sunnyvale, California 94085


Simply connecting the IP world
==========================================================

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
