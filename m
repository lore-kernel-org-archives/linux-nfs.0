From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: client side noac
Date: Sat, 26 Jun 2004 17:11:24 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.60.0406261654150.10096@harp.ngdc.noaa.gov>
References: <Pine.LNX.4.60.0406251148570.3197@harp.ngdc.noaa.gov>
 <1088186851.4333.65.camel@lade.trondhjem.org>  <Pine.LNX.4.60.0406251252570.3683@harp.ngdc.noaa.gov>
  <1088191021.4333.75.camel@lade.trondhjem.org>
 <Pine.LNX.4.60.0406251321030.3853@harp.ngdc.noaa.gov>
 <1088192302.4333.83.camel@lade.trondhjem.org>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BeMKW-0000En-01
	for nfs@lists.sourceforge.net; Sat, 26 Jun 2004 16:11:28 -0700
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1BeMKV-00027M-KO
	for nfs@lists.sourceforge.net; Sat, 26 Jun 2004 16:11:27 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1088192302.4333.83.camel@lade.trondhjem.org>
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

On Fri, 25 Jun 2004, Trond Myklebust wrote:

> open() should not cause cache flushes unless it detects that the file
> has been modified.
>
> As for whether or not lookups are cached: We check the mtime of the
> parent directory in order to find out whether or not it has changed. If
> it has, then we do a new lookup of the file.
>
> Cheers,
>  Trond

here are two small ruby scripts which will demonstrate the problem:

this script simply loops removing the file 'foobar', ignoring failure if it did
not exist

   ================
   file: rm.rb
   ================
   loop do
     begin
       File::unlink 'foobar'
     rescue Errno::ENOENT
     end
   end
   ================

this script loops opening up the file 'foobar' and copying it to 'barfoo'.  if
'foobar' is found not to exist it is created by making a tmp file and mv'ing it
on top of 'foobar'.  if you are unfamiliar with ruby note that open, when
called with a block, automatically closes the open file handle and the end of
the block.  if you doubt this do

   ~/shared > touch foobar && strace ruby -e 'open("foobar"){}' 2>&1 | egrep 'open|close' | tail -2
   open("foobar", O_RDONLY|O_LARGEFILE)    = 3
   close(3)                                = 0

   ================
   file: open.rb
   ================
   loop do
     begin
       open('foobar','r') do |fb|
         open('barfoo','w') do |bf|
           bf.write fb.read
         end
       end
     rescue Errno::ENOENT
       open('foobar.tmp', 'w'){|f| f.puts 42}
       File::rename 'foobar.tmp', 'foobar'
     end
   end
   ================


here is a demo run:


on one client run the rm.rb script:

   ~/shared > uname -n
   carp.ngdc.noaa.gov

   ~/shared > ruby rm.rb

on another run the open.rb script:

   ~/shared > uname -n
   jib.ngdc.noaa.gov

   ~/shared > ruby open.rb
   open.rb:3:in `initialize': Stale NFS file handle - foobar (Errno::ESTALE)
           from open.rb:3:in `open'
           from open.rb:3
           from open.rb:1:in `loop'
           from open.rb:12


this makes no sense to me.  i understand that the open call should throw
Errno::ENOENT - since the rm.rb is constantly removing it.  but why should it
throw Errno::ESTALE?  it seems like this could only be caused by a buggy client
sending an invalid file handle across the wire?  shouldn't clients handle this
case - knowing that it makes little sense for open to return ESTALE (what would
be 'stale' afterall)??  my code simply retries (once) if it raises ESTALE on an
open - and this always works - shouldn't the nfs client code also do this?

cheers.

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
