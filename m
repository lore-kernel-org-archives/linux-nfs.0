From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: open O_EXCL works?
Date: Mon, 21 Mar 2005 21:13:49 -0700 (MST)
Message-ID: <Pine.LNX.4.60.0503212101550.12483@harp.ngdc.noaa.gov>
References: <20050314080517.BD8F.BRANDEN@terra.com.br>
 <1110813864.30085.47.camel@lade.trondhjem.org> <20050321181858.BE73.BRANDEN@terra.com.br>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDamI-0002v4-1p
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 20:14:02 -0800
Received: from harp.ngdc.noaa.gov ([140.172.178.33])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DDamG-00064o-9e
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 20:14:01 -0800
To: Filipe Brandenburger <branden@terra.com.br>
In-Reply-To: <20050321181858.BE73.BRANDEN@terra.com.br>
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

On Mon, 21 Mar 2005, Filipe Brandenburger wrote:

> Hi, there.
>
> I'm trying to make my program work correctly over NFS, but apparently I
> still have a race condition, because I'm getting inconsistencies. I
> still can't find out exactly what is happening. This is what I'm doing:
>
>
>  f = open("myfile", O_CREAT|O_WRONLY|O_APPEND)
>
>  [repeat the loop below for the data]
>    hardlink("myfile", "myfile.lock")
>    -> if it fails, invalidate information
>    write(f, "mydata", sizeof(mydata))
>    unlink("myfile.lock")
>  [end loop]
>
>  close(f)
>
>
> I would expect to get consistent data, as "hardlink" should be an atomic
> operation over NFS (according to the previous posts on this thread). But I'm
> still having problems.
>
> What I think is happening is that one process in one host is silently
> overwriting data just written by another process on another host (this
> overwriting happens on the same second interval), instead of appending to
> the end of the file, just after that other process record...
>
> I mean, I found out that append writes are not atomic in Linux 2.4, but if I
> have a hardlink operation just before the write, it should fix the issue,
> shouldn't it?
>
> Or somehow isn't the hardlink operation atomic? Or is the information of the
> file size (for the append) being held in some cache, and not being looked up
> just before each write (and just after we assure the file is ours with the
> lockfile hardlink)? Could you explain what is happening?  Could you suggest
> a way to fix this and reliably append data to the file?
>
> I can provide more information upon request. By the way, the NFS client
> platform is Linux RedHat 7.3, with kernel from RHAS 2.1, uname returns
> 2.4.9-e.49enterprise, NFS servers are a mix of EMC Celerra, EMC NS-700
> (Clariion) and Netapp FAS940.
>
> Thanks a lot,
> Filipe

hi filipe-

i won't even pretend to be an expert on this list, but i have successfully
implemented a locking scheme using link(2) on nfs and can tell you what i did.

from the readme, here is a snippet:

...
...
...

   BASIC ALGORITHIM

     * create a globally uniq filename in the same filesystem as the desired
       lockfile - this can be nfs mounted

     * link(2) this file to the desired lockfile, ignore all errors

     * stat the uniq filename and desired lockfile to determine is they are the
       same, use only stat.rdev and stat.ino - ignore stat.nlink as NFS can cause
       this report incorrect values

     * iff same, you have lock.  either return or run optional code block with
       optional refresher thread keeping lockfile fresh during execution of code
       block, ensuring that the lockfile is removed..

     * iff not same try again a few times in rapid succession (poll), then, iff
       this fails, sleep using incremental backoff time.  optionally remove lockfile
       if it is older than a certain time (stale), timeout if more than a certain
       amount of time has passed attempting to lock file.

...
...
...

you can download the package, which includes both a ruby library and
commandline tool for safely performing nfs link based locks at

   http://www.codeforpeople.com/lib/ruby/lockfile/

you can read the code for the latest version here

   http://www.codeforpeople.com/lib/ruby/lockfile/lockfile-1.3.0/lib/lockfile.rb

the commandline tool lets you lock a file and run another program while
running it, eg

   rlock foo.lock -- myprog.exe --option-for-myprog

this runs the the code while holding the lock.

in any case, i suspect your issue is assuming the return code for link(2) is
correct - you have to do the stats and check fields...

at least, that is what people on this list helped me to do and it works under
quite heavy testing.

kind regards.

-a
-- 
===============================================================================
| EMAIL   :: Ara [dot] T [dot] Howard [at] noaa [dot] gov
| PHONE   :: 303.497.6469
| When you do something, you should burn yourself completely, like a good
| bonfire, leaving no trace of yourself.  --Shunryu Suzuki
===============================================================================


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
