From: Brashers_Per@emc.com
Subject: RE: Client tuning
Date: Wed, 11 Dec 2002 16:10:14 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <B02F581F0BBDD4119B0D00D0B7A82DB001C468DA@casf1fp1.corp.emc.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from maho3msx2.isus.emc.com ([128.221.11.32] helo=maho3msx2.corp.emc.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18ME7m-0007UA-00
	for <nfs@lists.sourceforge.net>; Wed, 11 Dec 2002 13:10:34 -0800
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

Much information is available about the Celerra from:
http://www.emc.com/products/networking/celerra.jsp?openfolder=storage_networ
king

to quote the website:

The Celerra Clustered Network Server (CNS) is the world's fastest and most
scalable NAS gateway, delivering up to 200,000 operations per second and
supporting up to 224 direct network connections. 
<snip>
EMC Celerra solutions all share the powerful DART operating environment and
tool set, providing a smooth path for growth as your performance and
capacity requirements expand.

Or in real speak:   it is a modular box with a GNU friendly OS that works
with NFS and CIFS (if anyone cares) and can be modified in similar ways to
what you already do (if your a Linux geek).

In general using UDP requires a near perfect network (read -private
segment-) to gain much of its advantages, and V3 has many improvements over
V2.  So your network will determine UDP/TCP and I have never seen a time to
need V2 over V3.

Much of the tuning listed on nfs.sorceforge.net is great.  If you have not
checked it out yet, do so.


Just my $.02

Per

-------------------------------

Date: Wed, 11 Dec 2002 13:11:45 +0000
From: Jose Celestino <japc@co.sapo.pt>
To: nfs@lists.sourceforge.net
Subject: [NFS] Client tuning

Hello,

I need some help fine tuning some NFS clients.

The server is a blackbox (an EMC Celerra which we don't administer, we
can't touch it, we can only give some hints and pray) the clients are
Linux boxes with kernel >= 2.4.18.

This system will be used, exclusivelly, as a webmail system with maildir
format "mailboxes". That means lots (ithousands to millions) of small
iles (<=30Kb) and tons of accesses to that same files. Access will be
made via an IMAP server, a POP server and a SMTP server.

I have the option of choosing between NFSv2/v3 and TCP/UDP and the
freedom to fully configure/reconfigure the client boxes. Any thoughs on
what I might tweak and look for? Any experiences on this?

TIA.

-- 
Jose Celestino | http://xpto.org/~japc/files/japc-pgpkey.asc
----------------------------------------------------------------
"Don't summarize. Don't abbreviate. Don't interpret." -- djb




-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
