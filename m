From: Skottie Miller <skottie@anim.dreamworks.com>
Subject: Re: Re: nfsd tuning - please help me! (Alan Powell)
Date: Fri, 14 Feb 2003 13:28:38 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E4D5F86.90703@anim.dreamworks.com>
References: <5CA6F03EF05E0046AC5594562398B916A3281B@POEXMB3.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net, lakerfaniam2@yahoo.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from garm.dreamworks.com ([64.173.252.34] helo=postal.anim.dreamworks.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18jnO2-0006Y5-00
	for <nfs@lists.sourceforge.net>; Fri, 14 Feb 2003 13:28:46 -0800
To: "Heflin, Roger A." <Roger.A.Heflin@conocophillips.com>
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


This is slightly OT, but worth noting.

Heflin, Roger A. wrote:
 
> 	I have been able to get closer to 10-20MBytes per second with
> 	linux nfs.  The netapps will do around 4-5 times that though at
> 	a higher cost.  And you can get it out of linux, by putting more
> 	cheap smaller servers to obtain the same rate.

15 - 20 times that; my netapp 960's sustain 280 - 330 Mbytes/sec of read traffic
when feeding the renderfarm.  That's one of the many reasons we're using NetApp
and not Linux NFS servers, in an otherwise all-linux shop.

  -skottie


-- 

Scott Miller                 | Animation Technology
work: skottie@dreamworks.com | Dreamworks Feature Animation
life: skottie@pobox.com



-------------------------------------------------------
This SF.NET email is sponsored by: FREE  SSL Guide from Thawte
are you planning your Web Server Security? Click here to get a FREE
Thawte SSL guide and find the answers to all your  SSL security issues.
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0026en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
