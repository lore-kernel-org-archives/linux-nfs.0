From: David Dougall <davidd@et.byu.edu>
Subject: Re: NFS locking question
Date: Mon, 24 May 2004 12:02:44 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0405241200460.2340@lewis.et.byu.edu>
References: <Pine.LNX.4.44.0405241151020.20070-100000@fattire.ngdc.noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BSJmq-00073Z-2y
	for nfs@lists.sourceforge.net; Mon, 24 May 2004 11:02:56 -0700
Received: from postal1.et.byu.edu ([128.187.122.131])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BSJmp-0000Ir-PM
	for nfs@lists.sourceforge.net; Mon, 24 May 2004 11:02:55 -0700
To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
In-Reply-To: <Pine.LNX.4.44.0405241151020.20070-100000@fattire.ngdc.noaa.gov>
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

OK, I don't think this is what I have done:
fd=open(infilename,O_RDONLY);
flk.l_type=F_RDLCK;
return_code=fcntl(fd,F_SETLK,&flk);

If this is wrong, let me know.
--David Dougall



On Mon, 24 May 2004, Ara.T.Howard wrote:

> On Mon, 24 May 2004, David Dougall wrote:
>
> > On linux clients, I have not been able to get the file to lock at all.  The
> > fcntl returns EBADF which implies I passed a bad file descriptor, but I have
> > verified that it is a valid file descriptor.
>
> is the file open is a mode consistent with the lock request?  eg.  are you
> asking for an exclusive lock when the file is only open for reading?  if so
> you'll get EBADF... you must open a file for writing if you want an exclusive
> lock...
>
> -a
> --
> ===============================================================================
> | EMAIL   :: Ara [dot] T [dot] Howard [at] noaa [dot] gov
> | PHONE   :: 303.497.6469
> | ADDRESS :: E/GC2 325 Broadway, Boulder, CO 80305-3328
> | URL     :: http://www.ngdc.noaa.gov/stp/
> | "640K ought to be enough for anybody." - Bill Gates, 1981
> ===============================================================================
>
>
>
> -------------------------------------------------------
> This SF.Net email is sponsored by: Oracle 10g
> Get certified on the hottest thing ever to hit the market... Oracle 10g.
> Take an Oracle 10g class now, and we'll give you the exam FREE.
> http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>
>


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
