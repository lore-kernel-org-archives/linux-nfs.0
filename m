From: "Nguyen Thanh Bien" <bien@thnt.com.vn>
Subject: locking problem from HP-UX to Linux NFS Server
Date: Fri, 26 Jul 2002 09:23:22 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4273.203.162.18.14.1027689802.squirrel@thnt.com.vn>
References: <20020719101950.A15819@suse.de>
        <Pine.LNX.3.96.1020725084130.11202B-100000@gatekeeper.tmr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from thnt.com.vn ([203.162.17.78])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17XtdB-0004dU-00
	for <nfs@lists.sourceforge.net>; Thu, 25 Jul 2002 18:10:57 -0700
To: <nfs@lists.sourceforge.net>
In-Reply-To: <Pine.LNX.3.96.1020725084130.11202B-100000@gatekeeper.tmr.com>
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

Hi nfs experts !
i'm using a Linux NFS server to store mailboxs from external HP-UX (ver
11.0), mail server soft ware on HP-UX is CommunigatePro (it runs as
root.mail user).

and i got a problem when start Communigate Pro:
- cannot lock files

my exports file is:
/data/data_mail  hp-ux-box(rw,no_root_squash,insecure,insecure_locks)

anyone can help me to fix this ?

-- 
Nguyen Thanh Bien
Vietnamese Linux Users Group <http://vietlug.sourceforge.net>





-------------------------------------------------------
This sf.net email is sponsored by: Jabber - The world's fastest growing 
real-time communications platform! Don't just IM. Build it in! 
http://www.jabber.com/osdn/xim
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
