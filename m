From: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
Subject: Re: nfsd stales when restarting too fast
Date: Wed, 18 Aug 2004 09:16:54 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <41230266.7010002@bio.ifi.lmu.de>
References: <4118900F.9090602@bio.ifi.lmu.de> <16674.52210.884853.119652@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BxKgx-0006NG-5v
	for nfs@lists.sourceforge.net; Wed, 18 Aug 2004 00:17:03 -0700
Received: from acheron.informatik.uni-muenchen.de ([129.187.214.135])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1BxKgv-00080v-Kc
	for nfs@lists.sourceforge.net; Wed, 18 Aug 2004 00:17:03 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16674.52210.884853.119652@cse.unsw.edu.au>
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

Neil Brown wrote:
> 
> Probably the best solution is to "not do that" - why do you want to
> stop and then restart the server anyway?  Why not just leave it
> running.

Aeh, well, yes. Of course I should not restart but just reload when
sth. has changed... That's because I'm not used to the reload
option since it didn't exist in the early SuSE versions I was using, so
I'm always using restart. With reload (which just issues exportfs -r
in the SuSE init script) no problem occurs. I definitely should have
thought of that *feeling stupid* :-((

> 
> However there is a race the, and "sleep 1" would fix it.
> Another fix would be to use "-1" instead of "-9" to kill nfsd.  This
> causes it to exit without clearing the export table.
> Another fix would be to apply to following patch to your 2.6 kernel.

Just in case I forget the reload again next time I will include your
patch in my kernel rpm, too. Just to be sure :-)

Thanks for your help!
cu,
Frank

-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049



-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
