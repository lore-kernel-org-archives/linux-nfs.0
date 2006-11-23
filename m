From: Kasparek Tomas <kasparek@fit.vutbr.cz>
Subject: Re: NFS corruption in 2.6.18.2?
Date: Thu, 23 Nov 2006 17:17:38 +0100
Message-ID: <20061123161738.GF40079@fit.vutbr.cz>
References: <50e235a50d0f2b4fb34eed1c840565e3@swip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GnHGn-0004T7-IJ
	for nfs@lists.sourceforge.net; Thu, 23 Nov 2006 08:17:49 -0800
Received: from kazi.fit.vutbr.cz ([147.229.8.12])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GnHGm-0006u6-CH
	for nfs@lists.sourceforge.net; Thu, 23 Nov 2006 08:17:50 -0800
Received: from kazi.fit.vutbr.cz (localhost [127.0.0.1])
	by kazi.fit.vutbr.cz (envelope-from kasparek@fit.vutbr.cz)
	(8.13.8/8.13.7) with ESMTP id kANGHcbV083939
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <nfs@lists.sourceforge.net>; Thu, 23 Nov 2006 17:17:38 +0100 (CET)
Received: (from kasparek@localhost)
	by kazi.fit.vutbr.cz (8.13.8/8.13.1/Submit) id kANGHcMP083938
	for nfs@lists.sourceforge.net; Thu, 23 Nov 2006 17:17:38 +0100 (CET)
	(envelope-from kasparek@fit.vutbr.cz)
To: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
In-Reply-To: <50e235a50d0f2b4fb34eed1c840565e3@swip.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


> >have seen this behaviour with kernel 2.6.18 and above up to 19-rc4.
> > Reported this, but no response.
> > 
> > http://lkml.org/lkml/2006/9/28/89
>
> Your test script doesn't use any form of locking. How are you ensuring
> that only one client has the file open at a time?

I use no locking at all, it's just synthetic test, I don't expect data to
be ordered or whatever, but the problem is blocks of zeros inserted.
It behaves right with the last 2.6.16.32, zeros are contained if clients
are 2.6.18.3 and 2.6.19-rc4. 

I'm going to do more testing in next few days, so hoe bring some new info.

As I wrote before, it does not depend on the server (tried with FreeBSD
server and several versions of linux 2.6.16.x and 2.6.18.x).
 
Regards
 
--   

  Tomas Kasparek, PhD student  E-mail: kasparek@fit.vutbr.cz
  CVT FIT VUT Brno, BI/140a    Web:    http://www.fit.vutbr.cz/~kasparek
  Bozetechova 2, 612 66        Fax:    +420 54114-1270
  Brno, Czech Republic         Phone:  +420 54114-1220

  ICQ: 293092805  jabber: tomas.kasparek@jabber.cz
  GPG: 2F1E 1AAF FD3B CFA3 1537  63BD DCBE 18FF A035 53BC


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
