From: Topher <topher@wcsg.org>
Subject: *sigh* Connection refused
Date: Mon, 18 Nov 2002 19:48:59 -0500 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0211181937110.23070-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ip01.wcsg.org ([216.109.193.129] helo=localhost.localdomain)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18DwZa-0006QV-00
	for <nfs@lists.sourceforge.net>; Mon, 18 Nov 2002 16:49:02 -0800
Received: from localhost.localdomain (boktor [127.0.0.1])
	by localhost.localdomain (8.12.5/8.12.5) with ESMTP id gAJ0n092023104
	for <nfs@lists.sourceforge.net>; Mon, 18 Nov 2002 19:49:00 -0500
Received: from localhost (topher@localhost)
	by localhost.localdomain (8.12.5/8.12.5/Submit) with ESMTP id gAJ0mxXB023100
	for <nfs@lists.sourceforge.net>; Mon, 18 Nov 2002 19:48:59 -0500
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

Ok, I've got Zaurus.  I'm able to mount a dir via nfs on my server at 
work, so I know it's working right.  I'm trying to connect at home to my 
laptop, here's the command and the result:

# mount -t nfs -o soft,timeo=2 192.168.0.4:/win/mp3 /mnt/mp3
mount: RPC: Unable to receive; errno = Connection refused
mount: nfsmount failed: Bad file descriptor
mount: Mounting 192.168.0.4:/win/mp3 on /home/system/var/mnt/mp3 failed: 
Invalid argument


on the server, I have nfs, nfslock, and portmap running.  My /etc/exports 
file looks like this:

/win/mp3 192.168.0.2/255.255.255.0(ro,no_root_squash)

My /etc/hosts.allow file looks like this:

portmap:192.168.0.2/255.255.255.0
lockd:192.168.0.2/255.255.255.0
rquotad:192.168.0.2/255.255.255.0
mountd:192.168.0.2/255.255.255.0
statd:192.168.0.2/255.255.255.0

My hosts.deny file is empty.

I have a firewall, but both machines are on the same side of it.

My laptop gets its IP via DHCP, and the hostname is kinda borked, but I'm 
using IP addresses for everything.  Would it still matter?

exportfs says 
/win/mp3        192.168.0.2/255.255.255.0

Anyone have any ideas?

Topher
Manager of Internet Services
Cornerstone Broadcasting
Cornerstone University

------
"Seems to me a man has trouble enough in this world without borrowing more
with careless words."
                        -- Louis L'Amour, Mojave Crossing



-------------------------------------------------------
This sf.net email is sponsored by: To learn the basics of securing 
your web site with SSL, click here to get a FREE TRIAL of a Thawte 
Server Certificate: http://www.gothawte.com/rd524.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
