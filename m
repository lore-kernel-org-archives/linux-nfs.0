From: Jan Bruvoll <jan@bruvoll.com>
Subject: Re: async vs. sync
Date: Mon, 26 Jul 2004 20:47:49 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <41055FE5.3030206@bruvoll.com>
References: <482A3FA0050D21419C269D13989C61130435E51E@lavender-fe.eng.netapp.com> <200407261905.40248.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BpBSB-0001Om-1W
	for nfs@lists.sourceforge.net; Mon, 26 Jul 2004 12:48:07 -0700
Received: from homer.brvl.com ([213.61.99.172])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1BpBSA-00084g-Cm
	for nfs@lists.sourceforge.net; Mon, 26 Jul 2004 12:48:06 -0700
To: Bernd Schubert <bernd-schubert@web.de>
In-Reply-To: <200407261905.40248.bernd-schubert@web.de>
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

Bernd Schubert wrote:

> Exactly, therefore I would like to enable the sync-export option again.
>
>However, reducing the speed to about 1/5 of async speed for large files and 
>to about 1/20 for smaller files is not an option. The people already 
>complained that compiling their projects takes ages now... 
>
>D'oh, sorry, I forgot to write that we use the tcp-mounts and nfs3. So  those 
>numbers really shouldn't happen, should they?
>  
>

Hi Bernd,

are you doing anything "interesting" underneath NFS, ie. what are you 
storing your files on?

My set-up has about the same performance data, however my big problem is 
that the server dies when I hook all my clients up... Raw throughput 
seemed ok, but when you started complaining about the speed, I started 
thinking that my figures weren't all that great anymore.

The set-up is a dual 3Ghz Xeon, 2Gb RAM, and a DRBD-mirrored partition 
sitting on a 3Ware Escalade 7500 to 7200rpm disks. Kernel 
2.4.26-gentoo-r5, everything else newest version. The annoying thing is 
that the server this new set-up is replacing is an old P3/650 that 
easily copes with the load... :-\

Best regards
Jan



-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
