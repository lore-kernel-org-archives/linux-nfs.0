From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: binaries becoming corrupt on nfs
Date: Mon, 14 Mar 2005 23:05:05 +0100
Message-ID: <200503142305.05916.bernd-schubert@web.de>
References: <Pine.LNX.4.60.0503141414590.4702@harp.ngdc.noaa.gov> <Pine.LNX.4.60.0503141434390.4702@harp.ngdc.noaa.gov> <1110836857.24466.4.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DAxgO-0003aJ-Fl
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 14:05:04 -0800
Received: from smtp07.web.de ([217.72.192.225])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1DAxgN-00065q-VC
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 14:05:04 -0800
Received: from [84.171.139.200] (helo=[192.168.6.2])
	by smtp07.web.de with asmtp (TLSv1:RC4-MD5:128)
	(WEB.DE 4.104 #268)
	id 1DAxgE-0006WF-00
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 23:04:55 +0100
To: nfs@lists.sourceforge.net
In-Reply-To: <1110836857.24466.4.camel@lade.trondhjem.org>
Sender: nfs-admin@lists.sourceforge.net
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

On Monday 14 March 2005 22:47, Trond Myklebust wrote:
> m=E5 den 14.03.2005 Klokka 14:40 (-0700) skreiv Ara.T.Howard:
> > > Do you perhaps have some cronjob or something that is updating the
> > > binaries on the server?
> >
> > absolutely nothing.  bear in mind we are not seeing stale file handles -
> > the binaries are truely corrupt.  very, very weird things will happen:
>
> That was why I asked. If you update the binaries by copying into them
> (not renaming + creating new file), then strange things will happen: you
> will not see ESTALE, but you will usually see cache corruption.

Shouldn't this be prevented by inode generation numbers?

>
> The obvious and easy way to detect if this is the case, is to look at
> the ctime on the file in question.
>
> >    * maybe the binaries core dump on startup
> >    * maybe it runs, but errors in strange ways
> >    * maybe it runs, but core dumps
> >    * sometimes it can be loaded into a debugger - sometimes not

Does it happen on many machines or only on one of them? We also had this on=
ce=20
and at the end it was bad memory (though we were using ecc memory). I would=
=20
suggest to run memtest86.


Cheers,
	Bernd


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
