From: =?iso-8859-1?q?Victor=20Zamora?= <victor77422@yahoo.com.ar>
Subject: Export problem ...
Date: Sun, 6 Oct 2002 20:13:43 -0300 (ART)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021006231343.664.qmail@web14302.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
To: NFS@lists.sourceforge.net
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

Hi,

 I'm writing to you to because while trying to
configure the NFS server I had a problem. After
running nfsd, mountd,portmapd and configuring the
exports, host.allow and host.deny files, I ran 
exportfs -ra to make the kernell know about the
exports I wished to make. But the problem is that when
I look at xtab, the path I have exported doesn't
appear. 
  When I call a mount from the client, I get a
permison denyal from de server. I guess that the path
is not well exported but I can't get a solution to
this problem.
  Do anybody know what can I be doing wrong? Can this
problem be related to some security matter?

  If anybody has any idea of what the problem could
be, please write me soon.

  Thanks for listening to my problems
 

  

Ahora podés usar Yahoo! Messenger desde tu celular. Aprendé cómo hacerlo en Yahoo! Móvil: http://ar.mobile.yahoo.com/sms.html


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
