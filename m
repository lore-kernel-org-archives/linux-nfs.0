From: "Bruce Allan" <bruce.allan@us.ibm.com>
Subject: Re: NFS Setup
Date: Wed, 20 Mar 2002 09:08:11 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OFB18462BD.83484318-ON88256B82.005C78D1@boulder.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
Received: from e31.co.us.ibm.com ([32.97.110.129])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16njXT-0005BN-00
	for <nfs@lists.sourceforge.net>; Wed, 20 Mar 2002 09:06:15 -0800
To: jkt <jkt@execpc.com>
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


You are missing the required mount point, filesystem type, and mount
options in your client's /etc/fstab.  See fstab(5) manpage.  For example,
the entry in your client's /etc/fstab might need to look like:
192.168.1.3:/tmp  /mnt/tmp    nfs   rw,hard,intr

Note, the /mnt/tmp mount point is just an example, you can use whatever you
require; and the options are typical but may be different for your needs.

  You may also want to add options to your server's /etc/exports; it's
optional, but you may want to change the defaults.  See exports(5) manpage.

---
Bruce Allan  <bruce.allan@us.ibm.com>
Software Engineer, Linux Technology Center
IBM Corporation, Beaverton OR
503-578-4187   IBM Tie-line 775-4187



                                                                                                                                  
                      jkt <jkt@execpc.com>                                                                                        
                      Sent by:                    To:       "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>               
                      nfs-admin@lists.sour        cc:                                                                             
                      ceforge.net                 Subject:  [NFS] NFS Setup                                                       
                                                                                                                                  
                                                                                                                                  
                      03/19/2002 09:15 PM                                                                                         
                                                                                                                                  
                                                                                                                                  




Hello,

My name is John Tankersley. I am new to NFS and am seeking some help in
how to set up the entries in
the /etc/exports file on the host side and the /etc/fstab file on the
client side.
I have two machines running SuSE Linux 7.3 professional each.  I can
ping and telnet between the two
machines successfully. Machine (1) host machine's ip is 192.168.1.3.
The client machine's ip is
192.168.1.1.  Here is the entry in the host machine /etc/exports  file.
/tmp 192.168.1.1.
The entry at the client machine in /etc/fstab file is 192.168.1.3:/tmp.
I just want to know what I am doing wrong in my entries.  I hope my
explanation is clear.  I am trying to mount the /tmp directory on the
host machine to the client machine.  Could someone please indicate what
is wrong with my entries?

Thank-you,

John Tankersley
jkt@execpc.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs




_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
