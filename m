From: Vladimir Vuksan <croatia@firstlinux.net>
Subject: RPC: TCP connect error 104!
Date: Thu, 2 May 2002 17:39:22 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020503003922.A403936F9@sitemail.everyone.net>
Reply-To: croatia@firstlinux.net
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sitemail3.everyone.net ([216.200.145.37] helo=omta01.mta.everyone.net)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 173R6Z-0000Sy-00
	for <nfs@lists.sourceforge.net>; Thu, 02 May 2002 17:39:23 -0700
Received: from sitemail.everyone.net (dsnat [216.200.145.62])
	by omta01.mta.everyone.net (Postfix) with ESMTP id B56251C47DB
	for <nfs@lists.sourceforge.net>; Thu,  2 May 2002 17:39:22 -0700 (PDT)
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

I am experiencing a problem on a number of different clients mounting NFS mounts over TCP. The error message showing up is

RPC: TCP connect error 104!

I searched through Google Groups and found following message

=========================================

http://www.geocrawler.com/mail/msg.php3?msg_id=8215374&list=789

You may need more threads to service the clients?  See Neil's notes
that accompanied the patches (in the archives) w.r.t the number of threads and the number of RPC receive buffers.

==========================================

I was wondering what is the easiest way to increase the number of threads. Most clients run RedHat's 2.4.9-31 kernel installed from an RPM. I also have a Rawhide kernel 2.4.18-0.12 that seems to exhibit same kind of behavior.
 
Thanks,
Vladimir

_____________________________________________________________
Want a new web-based email account ? ---> http://www.firstlinux.net

_____________________________________________________________
Promote your group and strengthen ties to your members with email@yourgroup.org by Everyone.net  http://www.everyone.net/?btn=tag

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
