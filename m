From: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
Subject: Re: client apps not surviving nfsd restart
Date: Fri, 20 Aug 2004 16:26:42 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <41260A22.3080107@bio.ifi.lmu.de>
References: <4125EA9F.3040304@bio.ifi.lmu.de> <20040820132143.GC12371@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ByALt-0003lZ-5F
	for nfs@lists.sourceforge.net; Fri, 20 Aug 2004 07:26:45 -0700
Received: from acheron.informatik.uni-muenchen.de ([129.187.214.135])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1ByALs-0006Ue-82
	for nfs@lists.sourceforge.net; Fri, 20 Aug 2004 07:26:44 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040820132143.GC12371@suse.de>
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

Olaf Kirch wrote:

> I reproduced this. Someone "improved" the init script to do this:
> 
> 	/usr/sbin/exportfs -au
> 	killproc -n -KILL nfsd
> 
> so we first zap the exports tables, then stop all nfsds. Any NFS
> requests received in the meanwhile will see ESTALE.
> 
> Try removing the exportfs call.

Yes, that makes the difference! The "find" now again just hangs and
after the server returns, continues without any problems. Same with
"cp". "rsync" now also doesn't complain at the end anymore!

I feel stupid about this: When reporting the race problem with restarting
the server on the lkml, Neil already told me that the "exportfs -au"
should not be called before killing the nfsd and so I changed the order.
But because this had no effect for the race bug, I forgot it and didn't
change the init script for all our hosts.

So I guess that all the stales and problems we had since 9.0 were just
caused by the bug in the script... And I was already so disappointed
by nfs-over-tcp because I blamed it for the stales :-)

Thanks for your help! I will bugfix our scripts and then give 2.6 a
try with nfs-over-tcp :-)

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
