From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: debugging hanging locks
Date: Tue, 17 Aug 2004 11:50:49 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.60.0408171146190.12428@harp.ngdc.noaa.gov>
References: <Pine.LNX.4.60.0408161741020.5649@harp.ngdc.noaa.gov>
 <1092702159.11722.77.camel@lade.trondhjem.org>
 <Pine.LNX.4.60.0408161846440.5649@harp.ngdc.noaa.gov>
 <1092757186.4030.11.camel@lade.trondhjem.org>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-1615794798-1092765049=:12428"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bx8EF-00031B-2c
	for nfs@lists.sourceforge.net; Tue, 17 Aug 2004 10:58:35 -0700
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1Bx884-0005hI-Rj
	for nfs@lists.sourceforge.net; Tue, 17 Aug 2004 10:58:34 -0700
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by externalmx-1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1Bx881-0005FH-BP
	for nfs@lists.sourceforge.net; Tue, 17 Aug 2004 10:52:12 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1092757186.4030.11.camel@lade.trondhjem.org>
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

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-1615794798-1092765049=:12428
Content-Type: TEXT/PLAIN; charset=X-UNKNOWN; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Tue, 17 Aug 2004, Trond Myklebust wrote:

> P=E5 m=E5 , 16/08/2004 klokka 20:51, skreiv Ara.T.Howard:
>> the lock/unlock method is wrapped in a try/catch block - eg. only 'kill =
-9'
>> could cause failure to unlock.  if i assume this to be the case - then w=
hat
>> else can be done?  will sending -9 always cause this?  will it ever
>> automatically resolve itself?  i was under the impression that a process=
 would
>> clean up fcntl locks on death anyhow - i am obviously mistaken, but to w=
hat
>> degree?
>
> Normally the kernel should clean up even if your program fails to do so.
> The only reason why that might fail is if there are bookkeeping problems =
in
> the kernel itself.  Whereas there have been such problems in the past, I
> believe Steve has picked up all the patches that fix known problems (perh=
aps
> he might want to comment on that - Steve?). The last patch to fix such a
> problem has been attached. You might want to check if that is included in
> your source tree...

since i'm seeing the problem i'm assuming our kernel

   Linux harp.ngdc.noaa.gov 2.4.21-15.0.4.EL #1 Sat Jul 31 01:33:50 EDT 200=
4 i686 i686 i386 GNU/Linux

is not clean wrt this as i've now seen this happen twice.

i will check though.


any ideas how one might try to exercise the kernel's clean-up beyond simply
sending SIGKILL to processes holding locks?  perhaps calls to _exit and
sendend one's self SIGKILL?

>>> Not much you can do beyond 'cat /proc/locks'. That will tell you whethe=
r or
>>> not a lock is held, and will also give you the pid of the remote proces=
s
>>> that holds the lock (in the 4th column).
>>
>> good enough - thanks for the tip.  btw.  where would i find this info?  =
i
>> pokeda around the docs/man pages and it was not obvious.
>
> /proc/locks' existence is documented in
> Documentation/filesystems/proc.txt. I don't think its format is
> documented anywhere outside the source code itself though.

good enough - thanks alot.

-a
--
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
| EMAIL   :: Ara [dot] T [dot] Howard [at] noaa [dot] gov
| PHONE   :: 303.497.6469
| A flower falls, even though we love it;
| and a weed grows, even though we do not love it.=20
|   --Dogen
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
--8323328-1615794798-1092765049=:12428--


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
