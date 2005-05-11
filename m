From: Neil Horman <nhorman@redhat.com>
Subject: Re: Memory usage
Date: Wed, 11 May 2005 09:42:07 -0400
Message-ID: <20050511134207.GC6498@hmsendeavour.rdu.redhat.com>
References: <20050506161018.GA3979@infradead.org> <1115410171.1960.26.camel@lade.trondhjem.org> <20050510122745.GA28981@infradead.org> <42816FA8.5000606@unixgrrl.net> <42817444.1040707@catfeeder.net> <42817708.6030607@unixgrrl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sean Dogar <sean@catfeeder.net>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DVrTW-0002T6-Pz
	for nfs@lists.sourceforge.net; Wed, 11 May 2005 06:42:10 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DVrTW-0006y9-7H
	for nfs@lists.sourceforge.net; Wed, 11 May 2005 06:42:10 -0700
To: liz <liz@unixgrrl.net>
In-Reply-To: <42817708.6030607@unixgrrl.net>
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

On Tue, May 10, 2005 at 08:07:52PM -0700, liz wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> NFS server.
> 
> We have a box running as a NFS server and a mysql server. What were
> running into is that we have a large amount of memory being sucked up
> by cache and the box is swapping like crazy. It doesnt seem to be
> release the cache back so im stumped. The only thing using memory is
> mysql.
> 
> All we can think of is the NFS server is using kernel cache for
> caching (a reach i know)
> 
> 
Depending on how frequently your NFS client accesses its file data in cache,
swapping process pages may be the logical thing to do.  But if not, you can, in
the 2.4.21 RHEL kernels use the pagecache sysctl to help reduce pagecache usage more
quickly when under VM pressure.  Note that in 2.4.21, setting pagecache.max does
not place a cieling on how much memory is used for pagecache, it just sets
policy for where memory should be reclaimed from first when needed. Its all in
the paper that Seth Referenced.

Hope that helps
Neil

> |~        total:    used:    free:  shared: buffers:  cached:
> |Mem:  4224462848 4206002176 18460672        0 41304064 2938032128
> |Swap: 2146754560 1073373184 1073381376
> |MemTotal:      4125452 kB
> |MemFree:         18028 kB
> |MemShared:           0 kB
> |Buffers:         40336 kB
> |Cached:        2095616 kB                        <---- 2G disk cache
> |SwapCached:     773556 kB
> |Active:        3186300 kB
> |ActiveAnon:    1707252 kB
> |ActiveCache:   1479048 kB
> |Inact_dirty:    607944 kB
> |Inact_laundry:  117300 kB
> |Inact_clean:     65180 kB
> |Inact_target:   795344 kB
> |HighTotal:     3276224 kB
> |HighFree:         1200 kB
> |LowTotal:       849228 kB
> |LowFree:         16828 kB
> |SwapTotal:     2096440 kB                      <-- 1G swap usage
> |SwapFree:      1048224 kB
> |HugePages_Total:     0
> |HugePages_Free:      0
> |Hugepagesize:     2048 kB
> 
> 
> 
> If it is indeed NFS is there a way to make it not do that :P I looked
> in my o'reilly book, googled and posted to kernel dev (WIth my
> asbestos jacket on and zipped up ;)
> 
> The machine is running 2.4.21 EL-SMP
> 
> Im completely stumped...
> 
> Thanks for looking at it :)
> 
> Liz
> 
> |> How does NFS handle caching? more particularly is there a way to limit
> |> the memory usage for caching?
> |>
> |>
> |> Does it show up as kernel cache or is it displayed in the process
> |> list?
> |>
> | Liz,
> |
> | Are you referring to a nfs server or client?
> |
> | -Sean
> |
> 
> -----BEGIN PGP SIGNATURE-----
> Version: GnuPG v1.4.0 (GNU/Linux)
> 
> iD8DBQFCgXcIlt/irWun80cRAqtaAJ9LaRgz6LN44xh9d0bbvpLizWW2egCePjTD
> QWAHmxtHMeyCOKqw3JcPVwg=
> =wkVW
> -----END PGP SIGNATURE-----
> 
> 
> 
> -------------------------------------------------------
> This SF.Net email is sponsored by Oracle Space Sweepstakes
> Want to be the first software developer in space?
> Enter now for the Oracle Space Sweepstakes!
> http://ads.osdn.com/?ad_id=7393&alloc_id=16281&op=click
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

-- 
/***************************************************
 *Neil Horman
 *Software Engineer
 *Red Hat, Inc.
 *nhorman@redhat.com
 *gpg keyid: 1024D / 0x92A74FA1
 *http://pgp.mit.edu
 ***************************************************/


-------------------------------------------------------
This SF.Net email is sponsored by Oracle Space Sweepstakes
Want to be the first software developer in space?
Enter now for the Oracle Space Sweepstakes!
http://ads.osdn.com/?ad_id=7393&alloc_id=16281&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
