From: "webmaster" <webmaster@dglewis.com>
Subject: Linux -> Sun NFS doesn't mount
Date: Tue, 25 Jun 2002 20:30:20 GMT
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020625203020.13900.qmail@mail.hostasaurus.com>
References: <20020624223641.GA16108@backlot.linas.org>
            <shsptygs21r.fsf@charged.uio.no>
            <3D17B3F7.1010301@actusa.net>
            <20020625004215.GB16309@backlot.linas.org>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.hostasaurus.com ([64.157.8.4])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17MwxB-0001dN-00
	for <nfs@lists.sourceforge.net>; Tue, 25 Jun 2002 13:30:21 -0700
In-Reply-To: <20020625004215.GB16309@backlot.linas.org> 
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

After a recent upgrade from solaris 2.6 to 2.8, my linux nfs client can no 
longer nfs mount to the sun machine.  I can mount to two other 2.8 boxes 
w/out problems(they were installed fresh as 2.8 and since only patched up).  
I get permission denied, however dmesg reveals: 

call_verify: server requires stronger authentication 

While googling I came across many references to linux nfs not being capable 
of kerberos authentication, but haven't found a resolution or work around.  
I hope this is the appropriate forum.  In trolling here for the past week it 
seems to be. 

Can anyone give me more insight or progress of a fix?  Thank you very much 
in advance for your attention. 

Dan 



-------------------------------------------------------
This sf.net email is sponsored by: Jabber Inc.
Don't miss the IM event of the season | Special offer for OSDN members! 
JabConf 2002, Aug. 20-22, Keystone, CO http://www.jabberconf.com/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
