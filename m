From: <trond.myklebust@fys.uio.no>
Subject: Re: RE: [autofs] running out of mount points
Date: Tue, 20 Jan 2004 17:00:30 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <35307.68.42.103.198.1074614430.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: <gregb@rhythm.com>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AiyJ6-0001JN-GH
	for nfs@lists.sourceforge.net; Tue, 20 Jan 2004 08:00:48 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AiyJ5-00059v-Vy
	for nfs@lists.sourceforge.net; Tue, 20 Jan 2004 08:00:48 -0800
To: <raven@themaw.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

På ty , 20/01/2004 klokka 10:11, skreiv Ian Kent:
> I have worked on Tronds' patch for that. I posted my first attempt on
> the nfs list to see if Trond could sanity check it but he was clearly
> to  busy. So I went ahead and did the best I could. This resulted in a
> port  for 2.6 and 2.4 vanila kernel only. It is entirely untested and
> I expect  will have problems as the depth of my understanding of the
> NFS subsystem  is poor at best. I found trying to make it apply to a
> RedHat 2.4 kernel  was something of a nightmare and have left it there
> for now.

Note: the NFSv4 client in the latest 2.6.1-mm patches already does share
its RPC client between all mountpoints.

I haven't implemented the same type of sharing for NFSv2/v3 yet, since
there some concern has been voiced that it may impact performance on
high end systems that rely on mounting the same filesystem several times
in order to increase the number of available RPC slots. Chuck is working
on a patch that will remedy this.

Cheers,
  Trond





-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
