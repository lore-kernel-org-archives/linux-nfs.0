From: Filipe Brandenburger <branden@terra.com.br>
Subject: Re: open O_EXCL works?
Date: Tue, 22 Mar 2005 07:13:25 -0300
Message-ID: <20050322070816.BE7B.BRANDEN@terra.com.br>
References: <20050321181858.BE73.BRANDEN@terra.com.br> <Pine.LNX.4.60.0503212101550.12483@harp.ngdc.noaa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDgN3-00022k-Fn
	for nfs@lists.sourceforge.net; Tue, 22 Mar 2005 02:12:21 -0800
Received: from loncoche.terra.com.br ([200.154.55.229])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DDgN1-00007x-MB
	for nfs@lists.sourceforge.net; Tue, 22 Mar 2005 02:12:21 -0800
To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
In-Reply-To: <Pine.LNX.4.60.0503212101550.12483@harp.ngdc.noaa.gov>
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


Hi, there.

Are the stat's really necessary? I mean, in another post in this same
thread, Trond told that for hardlink, symlink and mkdir, both of them
are "atomic" in NFS meaning that they will succeed only for one client
and fail for all others if called at the same time. For me at least,
that means the stat's would not be needed... Isn't that so?

On another quite old post, I have read that even on NFS 2 hardlink works
in an atomic way, so that it could be used to implement a lock. I mean,
stat's certainly are safe, but this seems too expensive for me! Is this
extra safety really needed?

Thanks,
Filipe



* Mon, 21 Mar 2005 21:13:49 -0700 (MST), "Ara.T.Howard" <Ara.T.Howard@noaa.gov>:
> On Mon, 21 Mar 2005, Filipe Brandenburger wrote:
>    BASIC ALGORITHIM
> 
>      * create a globally uniq filename in the same filesystem as the desired
>        lockfile - this can be nfs mounted
> 
>      * link(2) this file to the desired lockfile, ignore all errors
> 
>      * stat the uniq filename and desired lockfile to determine is they are the
>        same, use only stat.rdev and stat.ino - ignore stat.nlink as NFS can cause
>        this report incorrect values
> 
>      * iff same, you have lock.  either return or run optional code block with
>        optional refresher thread keeping lockfile fresh during execution of code
>        block, ensuring that the lockfile is removed..
> 
>      * iff not same try again a few times in rapid succession (poll), then, iff
>        this fails, sleep using incremental backoff time.  optionally remove lockfile
>        if it is older than a certain time (stale), timeout if more than a certain
>        amount of time has passed attempting to lock file.




-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
