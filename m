From: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
Subject: Re: client apps not surviving nfsd restart
Date: Fri, 20 Aug 2004 16:34:01 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <41260BD9.1050003@bio.ifi.lmu.de>
References: <4125EA9F.3040304@bio.ifi.lmu.de> <200408201525.36681.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ByASx-0005Mn-EF
	for nfs@lists.sourceforge.net; Fri, 20 Aug 2004 07:34:03 -0700
Received: from acheron.informatik.uni-muenchen.de ([129.187.214.135])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1ByASw-0007nI-VR
	for nfs@lists.sourceforge.net; Fri, 20 Aug 2004 07:34:03 -0700
To: Bernd Schubert <bernd-schubert@web.de>
In-Reply-To: <200408201525.36681.bernd-schubert@web.de>
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

Hi Bernd,

Bernd Schubert wrote:

> can you confirm this with vanilla client/server kernel version? We have 45 

as Olaf figured out, it was indeed just a little bug in the init script...


> PS: About 1.5 years ago we were forced to use a Suse kernel on our server (due 
> to a closed-sources binary only kernel module) and this kernel caused a lot 
> of nfs related trouble for us. As the module also didn't work properly we 
> finally decided not to buy this software ;)

Hmm, since now (that we need a more recent version of 2.6 than the the
2.6.5 SuSE shipped with 9.1) I've always been using SuSE kernels, and
I really loved them for many reasons. They had always included a lot of
useful stuff which I'm now forced to add all by myself (things like the
bcm5700 driver in 2.4 when the tg3 crashed our server every night :-))

cu,
Frank

-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049
* Rekursion kann man erst verstehen, wenn man Rekursion verstanden hat. *


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
