From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: determining if a file is nfs mounted
Date: Mon, 21 Jun 2004 19:09:16 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.60.0406211908290.6387@harp.ngdc.noaa.gov>
References: <Pine.LNX.4.60.0406211242120.1344@harp.ngdc.noaa.gov>
 <40D74D18.2050509@moving-picture.com>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BcZmn-0005mp-PY
	for nfs@lists.sourceforge.net; Mon, 21 Jun 2004 18:09:17 -0700
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BcZmn-0008Cf-Dk
	for nfs@lists.sourceforge.net; Mon, 21 Jun 2004 18:09:17 -0700
To: James Pearson <james-p@moving-picture.com>
In-Reply-To: <40D74D18.2050509@moving-picture.com>
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

On Mon, 21 Jun 2004, James Pearson wrote:

> Doesn't statfs() do this? - from the man page:
>
> 	struct statfs {
> 	  long    f_type;     /* type of filesystem (see below) */
> 	  ...
>
> File system types:
>
> 	...
> 	linux/nfs_fs.h:
> 	  NFS_SUPER_MAGIC       0x6969
> 	...
>
> James Pearson

i guess it does!  ;-)

the man page isn't exactly inspiring though - sounds pretty platform
specific... but it is what i'm after.

cheers.

-a
--
===============================================================================
| EMAIL   :: Ara [dot] T [dot] Howard [at] noaa [dot] gov
| PHONE   :: 303.497.6469
| A flower falls, even though we love it; and a weed grows, even though we do
| not love it. --Dogen
===============================================================================


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
