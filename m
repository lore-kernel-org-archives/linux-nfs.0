From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: client side noac
Date: Mon, 28 Jun 2004 08:09:58 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.60.0406280754520.31370@harp.ngdc.noaa.gov>
References: <Pine.LNX.4.60.0406251148570.3197@harp.ngdc.noaa.gov>
 <1088186851.4333.65.camel@lade.trondhjem.org>  <Pine.LNX.4.60.0406251252570.3683@harp.ngdc.noaa.gov>
  <1088191021.4333.75.camel@lade.trondhjem.org>
 <Pine.LNX.4.60.0406251321030.3853@harp.ngdc.noaa.gov>
 <1088192302.4333.83.camel@lade.trondhjem.org>  <Pine.LNX.4.60.0406261615060.10096@harp.ngdc.noaa.gov>
  <1088364509.4295.14.camel@lade.trondhjem.org>
 <Pine.LNX.4.60.0406272148170.31370@harp.ngdc.noaa.gov>
 <1088397445.4295.51.camel@lade.trondhjem.org>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bewpf-0000cF-RG
	for nfs@lists.sourceforge.net; Mon, 28 Jun 2004 07:10:03 -0700
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1Bewpf-00008m-5k
	for nfs@lists.sourceforge.net; Mon, 28 Jun 2004 07:10:03 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1088397445.4295.51.camel@lade.trondhjem.org>
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

On Mon, 28 Jun 2004, Trond Myklebust wrote:

> In 2.6.x kernels, we don't do strict revalidation of the parent directories
> in the path: only the target file itself, so if someone deletes the current
> directory, you may end up with a stale filehandle.
> Please also note that renaming directories (and files) into other
> directories is also prone to this sort of ESTALE errors if your Linux server
> isn't exporting using the "no_subtree_check".
>
> Otherwise, the file itself should always be strictly checked (unless
> you've also got the "nocto" mount flag set). I won't exclude that the
> lookup may be using stale data if there turns out to be some race with
> readdirplus on NFSv3 that we've overlooked. You could check by comparing
> with a NFSv2 mount.
>
> Cheers,
>  Trond

we are using

   ~ > uname -srm && cat /etc/redhat-release; mount | grep nfs
   Linux 2.4.21-15.0.2.ELsmp i686
   Red Hat Enterprise Linux WS release 3 (Taroon Update 2)
   moby.b:/raid/array0/part1/export on /dmsp/moby-0-1 type nfs (rw,bg,hard,intr,rsize=8192,wsize=8192,addr=10.1.186.54)
   moby.b:/raid/array1/part1/export on /dmsp/moby-1-1 type nfs (rw,bg,hard,intr,rsize=8192,wsize=8192,addr=10.1.186.54)
   moby.b:/raid/array1/part2/export on /dmsp/moby-1-2 type nfs (rw,bg,hard,intr,rsize=8192,wsize=8192,addr=10.1.186.54)
   moby.b:/raid/array1/part3/export on /dmsp/moby-1-3 type nfs (rw,bg,hard,intr,rsize=8192,wsize=8192,addr=10.1.186.54)
   moby.b:/raid/array1/part4/export on /dmsp/moby-1-4 type nfs (rw,bg,hard,intr,rsize=8192,wsize=8192,addr=10.1.186.54)
   moby.b:/raid/array1/part5/export on /dmsp/moby-1-5 type nfs (rw,bg,hard,intr,rsize=8192,wsize=8192,addr=10.1.186.54)
   moby.b:/raid/array1/part6/export on /dmsp/moby-1-6 type nfs (rw,bg,hard,intr,rsize=8192,wsize=8192,addr=10.1.186.54)

so i guess that first bit does not apply.  the code IS renaming files but only
into the same directory, the directory is never removed and we are not using
the 'nocto' mount option.  i am 99.9% positive that we are using nfsv3 - how
can i determine this from the client side?  am i reading you correctly in
saying that this setup/usage pattern (demo scripts) should result in strict
chcking of files and that ESTALE should not be returned to client from open()?
or have i mis-understood?

sorry this is dragging on....  in summary i am wanting to know:

0)
     if you think this is a possible bug which i should explore further

1)  the behaviour i am seeing (demonstrated by scripts sent earlier) is
     consistent with our software configuration and, if so, if the 'correct'
     thing for user code to do in this case is simply to retry one time if open
     returns ESTALE, or if user code should attempt to force cache
     invalidation, etc.?

cheers (again!).

-a
--
===============================================================================
| EMAIL   :: Ara [dot] T [dot] Howard [at] noaa [dot] gov
| PHONE   :: 303.497.6469
| A flower falls, even though we love it;
| and a weed grows, even though we do not love it. 
|   --Dogen
===============================================================================


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
