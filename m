From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: client side noac
Date: Sat, 26 Jun 2004 17:19:15 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.60.0406261718090.10096@harp.ngdc.noaa.gov>
References: <Pine.LNX.4.60.0406251148570.3197@harp.ngdc.noaa.gov>
 <1088186851.4333.65.camel@lade.trondhjem.org>  <Pine.LNX.4.60.0406251252570.3683@harp.ngdc.noaa.gov>
  <1088191021.4333.75.camel@lade.trondhjem.org>
 <Pine.LNX.4.60.0406251321030.3853@harp.ngdc.noaa.gov>
 <1088192302.4333.83.camel@lade.trondhjem.org> <Pine.LNX.4.60.0406261654150.10096@harp.ngdc.noaa.gov>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BeMS7-0002vE-F6
	for nfs@lists.sourceforge.net; Sat, 26 Jun 2004 16:19:19 -0700
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1BeMS6-0006nD-TG
	for nfs@lists.sourceforge.net; Sat, 26 Jun 2004 16:19:19 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <Pine.LNX.4.60.0406261654150.10096@harp.ngdc.noaa.gov>
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

On Sat, 26 Jun 2004, Ara.T.Howard wrote:


forgot to attach the strace from running 'ruby open.rb':

...
...
open("foobar", O_RDONLY|O_LARGEFILE)    = 3
open("barfoo", O_WRONLY|O_CREAT|O_TRUNC|O_LARGEFILE, 0666) = 4
fstat64(3, {st_mode=S_IFREG|0664, st_size=0, ...}) = 0
fstat64(3, {st_mode=S_IFREG|0664, st_size=0, ...}) = 0
mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb741a000
_llseek(3, 0, [0], SEEK_CUR)            = 0
read(3, "", 4096)                       = 0
close(4)                                = 0
close(3)                                = 0
munmap(0xb741a000, 4096)                = 0
open("foobar", O_RDONLY|O_LARGEFILE)    = -1 ESTALE (Stale NFS file handle)
...
...

again, seems like this should be impossible...


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
