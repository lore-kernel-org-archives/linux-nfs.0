From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: file system read locks
Date: Fri, 20 Aug 2004 13:09:31 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.60.0408201303120.7569@harp.ngdc.noaa.gov>
References: <Pine.LNX.4.60.0408200907020.6148@harp.ngdc.noaa.gov>
 <20040820153921.GB6861@suse.de>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ByEla-0006ZE-H3
	for nfs@lists.sourceforge.net; Fri, 20 Aug 2004 12:09:34 -0700
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1ByElZ-0003WW-3U
	for nfs@lists.sourceforge.net; Fri, 20 Aug 2004 12:09:34 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040820153921.GB6861@suse.de>
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

On Fri, 20 Aug 2004, Olaf Kirch wrote:

> On Fri, Aug 20, 2004 at 09:08:15AM -0600, Ara.T.Howard wrote:
>> i have a perfectly functioning filesystem based write lock algorithim
>> (link(2)).
>
> Except that these FS based approaches don't support blocking; you
> always have to poll.
>
>> has anyone out there come up with an algorithim to make __read__
>> locks using file system primitives?
>
> Take a directory X. If the directory exists and is empty, the lock is not
> taken by anyone. To take a read lock, create a file in that directory.
> To take a write lock, remove the directory.
>
> (This scheme has the drawback that it's highly unfair to writers, but you
> can probably make it favor writers if you start to move it around rather
> than rmdir it)


seems to work well - the problem is when/how to create the directory in case
of an aborted writer... the dir will not exist - how to know when it's o.k to
create it...

i thinking that initially one could create two dirs

   dir
   .dir

while holding the lock it will be the responsibility of the lock holder to
keep .dir fresh via touching it.  if the .dir directory is ever found to be
stale we can guess that a process holding the lock has died without recreating
the lock directory dir.  at that point the process can lock the .dir (rmdir)
and recreate dir.  obviously only one process could succeed at this.  of
course, if this process died between removing .dir and creating dir this would
be bad.  however it seems this would be very, very rare since it would require
first one client dying w/o cleaning up, followed closely by another.

toughts?

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
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
