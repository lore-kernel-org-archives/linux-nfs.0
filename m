From: Hans-Peter Jansen <hpj@urpla.net>
Subject: Re: client apps not surviving nfsd restart
Date: Fri, 20 Aug 2004 20:28:23 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200408202028.23616.hpj@urpla.net>
References: <4125EA9F.3040304@bio.ifi.lmu.de> <41260BD9.1050003@bio.ifi.lmu.de> <20040820144652.GF12371@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ByE86-0007FR-VF
	for nfs@lists.sourceforge.net; Fri, 20 Aug 2004 11:28:46 -0700
Received: from moutng.kundenserver.de ([212.227.126.188])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1ByE82-0005En-Aq
	for nfs@lists.sourceforge.net; Fri, 20 Aug 2004 11:28:46 -0700
Received: from [212.227.126.205] (helo=mrelayng.kundenserver.de)
	by moutng.kundenserver.de with esmtp (Exim 3.35 #1)
	id 1ByE7q-0002Aq-00
	for nfs@lists.sourceforge.net; Fri, 20 Aug 2004 20:28:30 +0200
Received: from [217.231.171.238] (helo=mail)
	by mrelayng.kundenserver.de with asmtp (Exim 3.35 #1)
	id 1ByE7q-0002Zs-00
	for nfs@lists.sourceforge.net; Fri, 20 Aug 2004 20:28:30 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <20040820144652.GF12371@suse.de>
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

On Friday 20 August 2004 16:46, Olaf Kirch wrote:
> > Hmm, since now (that we need a more recent version of 2.6 than
> > the the 2.6.5 SuSE shipped with 9.1) I've always been using SuSE
> > kernels, and I really loved them for many reasons. They had
> > always included a lot of useful stuff which I'm now forced to add
> > all by myself (things like the bcm5700 driver in 2.4 when the tg3
> > crashed our server every night :-))

The SuSE kernel is much better then its fame, because a few people 
took a cursorily look into patches.{common,i386}. I imagine, this 
scared the bones out of their bodies, since a single human won't get 
a grip on it in a timely fashion. Others, who watched them, propagate 
this FUD since then.. OTOH, the changelog could be more specific.

I used to roll my owns for diskless usage for a long time, but I'm 
very happy to have learned to use the official ones out of the box 
without hassles. 

> There is the "kernel of the day" at
> ftp://ftp.suse.com/pub/people/mantel/kotd

The preferred path is ftp://ftp.suse.com/pub/projects/kernel/kotd
or better yet, because rsyncable:
ftp://ftp.gwdg.de/pub/linux/suse/ftp.suse.com/projects/kernel/kotd

> This is purely for testing, but people who, for some reason, need
> bleeding edge kernels, seem to find it useful.

It saved my life at least once ;-)

> Olaf



-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
