From: =?iso-8859-1?Q?Brasseur_Val=E9ry?= <Valery.Brasseur@atosorigin.com>
Subject: 2.4.19 hang (was unlink perf pb !)
Date: Tue, 13 Aug 2002 18:59:12 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <8D7D56C6ED3DD411998D009027DC685E0874E227@srv-grp-s1.segin.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from hermes7.atos-group.com ([160.92.18.56] helo=hermes7.axime.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17ef0d-0005Uh-00
	for <nfs@lists.sourceforge.net>; Tue, 13 Aug 2002 09:59:07 -0700
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

after some more investigation on my D state hang here is some observations :

* I couldn't get a clear trace of state : sysrq-t was not dump on a file !
don't know why !
  so I hand wrote extract of what I see and let ksymsoops try !
 
   got this : processes was in kmap or in flush_tbl !

* now after a clean boot, lauchn my prog : after a few second the LA grow,
blocked processes grow too ! (in my vmstat all the processes are in block
queue !) and only 1 waiting process !

  when in this state, I can't do  many things as all what I can do seems to
hang too !

=> I was not having this probleme in 2.4.18 !

note : when this arrive I've got something like 10 to 20 Mbs to nfs server.


valery



-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
