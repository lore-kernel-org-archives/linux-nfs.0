From: "Jake Hammer" <hammer@clarkisland.com>
Subject: RE: NFS read ok, write ok, simultaneous R+W=TERRIBLE
Date: Thu, 5 Dec 2002 10:35:14 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <CFEAJJEGMGECBCJFLGDBGEIHCJAA.hammer@clarkisland.com>
References: <200212051728.gB5HS1jH005843@pookie.nersc.gov>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from cynaptic.com ([128.121.116.181])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18K0qN-0005Ql-00
	for <nfs@lists.sourceforge.net>; Thu, 05 Dec 2002 10:35:27 -0800
To: <canon@pookie.nersc.gov>, "NFS" <nfs@lists.sourceforge.net>
In-Reply-To: <200212051728.gB5HS1jH005843@pookie.nersc.gov>
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

Hi Shane,

> I'm not convinced that the local performance is ruled
> out.  How are you testing the local performance?  Are
> you running multiple streams?  Are you certain you
> are busting cache?

We're launching 20 occurences of DD each producing a 10GB zero filled file
from /dev/zero. Since the cache is only 2GB, we have to be breaking it with
just one file, nevermind all of them. Then we launch 20 occurences of DD
again and read all the files back into /dev/null. Then the the local test
that makes me believe that NFS is broken: 20 occurences of DD reading and 20
occurences of DD writing simultaneously is just as fast as the other tests.
So, local disk performance sustains excellent throughput numbers on all of
these *local* operations.

Now try the same testing with 20 NFS mounted clients each DD'ing a 10GB
file. Great read, great write, horrible read/write.

> Also, are the NFSd's in disk wait?

Could you tell me how to check this? I'll be pleased to report once I know
how.

> If they are not, then
> this would be a clearer indications that the nfs subsystem
> may be to blame.  We usually see all the daemons in
> disk wait when we are really pounding one of the these
> boxes.

Yes, I'd love to be able to check. Please let me know how. This sounds
interesting.

> One other note.  We were running software raid (on a 2.2.19
> kernel).

2.2.19 or 2.4.19?

> After 3ware made some improvements to their
> raid 5 implementation, we moved away from it.  It appeared
> that we were actually CPU bound with SW raid.

Also interesting.

Have you changed your bdflush settings at all? If so, can we compare
settings? Playing with bdflush makes huge impacts to our local disk
performance.

Thanks,

Jake




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
