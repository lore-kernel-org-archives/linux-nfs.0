From: Nicolas Brainez <nb@many.be>
Subject: RE: Performance problem
Date: 15 May 2002 10:46:20 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1021452381.32242.5.camel@nb>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 212.68.239.49.brutele.be ([212.68.239.49] helo=many.be)
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 177uOi-00083g-00
	for <nfs@lists.sourceforge.net>; Wed, 15 May 2002 01:44:36 -0700
Received: from localhost ([127.0.0.1] helo=localhost.localdomain)
	by many.be with esmtp (Exim 3.35 #1)
	id 177uOH-0000dG-00
	for nfs@lists.sourceforge.net; Wed, 15 May 2002 10:44:09 +0200
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

OK, thanks for all your response!

I've tried the following:

- Change the NIC (old was rtl8139, new is AMD pcnet32): no changes
- Mount nfs in local: no problem
- Pinging server with 8192 bytes: high packet loss ! (between 30 & 90%)

It's maybe no more an nfs problem but, in my LAN the mtu are @ 1500 on
every machine, and there's no router between server and workstations,
some tips will be appreciated :-).

--
Nicolas Brainez


_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
