From: Fabrizio Nesti <nesti@medialab.sissa.it>
Subject: Re: 2.4.20 TCP server + solaris client performance
Date: Wed, 19 Feb 2003 12:30:06 +0100 (MET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.GSO.4.40.0302191211380.29315-100000@bodoni>
References: <15955.2664.221481.839408@notabene.cse.unsw.edu.au>
Reply-To: Fabrizio Nesti <nesti@medialab.sissa.it>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from didot.sissa.it ([147.122.2.50])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18lSUR-0008VK-00
	for <nfs@lists.sourceforge.net>; Wed, 19 Feb 2003 03:34:19 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>, Eric Whiting <ewhiting@amis.com>
In-Reply-To: <15955.2664.221481.839408@notabene.cse.unsw.edu.au>
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

> > Now the performance is still low, compared to a solaris server:
> > 	# time gtar xf /var/tmp/cvs-1.11.5.tar
> > 	Writing from Linux_2.4.20> real    0m22.132s
> > 	Writing from Solaris_8>    real    0m7.174s
> >

> > serving with size=32768, but with a maximum size of 8192.
> > - May this be the reason for the poor performance above?
>
> Unlikely.  It could possibly cause a 10% difference, but not a 300%
> difference. What filesystem are you using on Linux?
> ext3 with data=journal and preferably the journal on a separate device
> gives quite good performance with  NFS.
> Also with ext3, I have found that the no_wdelay export option helps.

I supposed the filesystem is ok, since it works very fast locally (<1sec).
In any case, they were ext3 on 4xSCSI320(RAID5+LVM) in udp tests, and an
ext3 on IDE133 for these tcp tests.

Network is a single 100MB/fullduplez switch.

So, if it is not UDP/TCP or r/wsize the cause, what can it be?
Even more, after the email from

> Eric Whiting <ewhiting@amis.com>
> ...
> We are getting good NFS numbers with 2.4.20 UDP NFS servers against solaris
> [89] clients.

So Eric, can you please show your configuration?

Also it is strange that a standard out-of-the-box RH8.0 on that big server
does perform so bad. Knowing this in advance, we wouldn't have chosen
linux for serving... :(

Ok,
thanks and ciao,
Fabrizio



-------------------------------------------------------
This SF.net email is sponsored by: SlickEdit Inc. Develop an edge.
The most comprehensive and flexible code editor you can use.
Code faster. C/C++, C#, Java, HTML, XML, many more. FREE 30-Day Trial.
www.slickedit.com/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
