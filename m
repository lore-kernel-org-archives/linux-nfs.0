From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: Re: more on silly names
Date: Sat, 4 Sep 2004 19:49:47 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.60.0409041924010.17016@harp.ngdc.noaa.gov>
References: <Pine.LNX.4.60.0409041610230.17016@harp.ngdc.noaa.gov>
 <1094338737.13791.15.camel@lade.trondhjem.org>
 <Pine.LNX.4.60.0409041813340.17016@harp.ngdc.noaa.gov>
 <1094344893.13791.68.camel@lade.trondhjem.org>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-1960210736-1094348987=:17016"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C3mAB-0006uR-Po
	for nfs@lists.sourceforge.net; Sat, 04 Sep 2004 18:49:51 -0700
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1C3mAA-0000U7-WD
	for nfs@lists.sourceforge.net; Sat, 04 Sep 2004 18:49:51 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1094344893.13791.68.camel@lade.trondhjem.org>
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

--8323328-1960210736-1094348987=:17016
Content-Type: TEXT/PLAIN; charset=X-UNKNOWN; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Sat, 4 Sep 2004, Trond Myklebust wrote:

> P=E5 lau , 04/09/2004 klokka 20:15, skreiv Ara.T.Howard:
>> it's sqlite - not berkeley db - so there is no mmap'ing at all going on
>> (confirmed by strace).
>
> In that case, all writes should automatically be committed to stable
> storage before close() returns.

   yes - i ommitted that from the strace.  a more complete bit at the botto=
m.

>> i've been able to reproduce the problem with a single client using the
>> database - eg. the client causes a sillyname on one of it's own files vi=
a the
>> sequence i outlined before.
>
> So note that sillyrename decisions are not based on whether or not
> someone has the file open. They are based on whether or not someone holds=
 a
> reference to the dentry.  IOW: it suffices that some process happens to
> stat() the file while the unlink() is going on.

   hmmm.  how about having the directory the file lives in open?  the way t=
he
   code is written guarantees only one process will ever be accessing the f=
ile,
   so any sillynames are caused by the client itself.

> Just out of curiosity, though: if you create a completely new file using
>
>   "touch blah; rm blah"
>
> does that result in a sillyrename? I'm wondering if someone has been
> messing  with the VFS in the kernel you are running.

   it does not seem to.  i ran this

     while true;do touch silly && rm silly;done

   in a dir while checking it from a remote host - no sillys appeared...


> Which kernel is it BTW?

   Linux 2.4.21-15.0.4.EL i686

   Red Hat Enterprise Linux WS release 3 (Taroon Update 2)

   though we are about to upgrade to the latest (or maybe we already did).


o.k.  here is the complete strace from the relevant bit (not very long i
promise) with some annotations by me.  executing this code from ONE client
will cause a silly file to be created - though it eventuall dissapears (the
next time this code runs i think).  here is the strace:


     stat64("/home/ahoward/q", {st_mode=3DS_IFDIR|0775, st_size=3D4096, ...=
}) =3D 0
     open("/home/ahoward/q", O_RDONLY|O_NONBLOCK|O_LARGEFILE|O_DIRECTORY) =
=3D 6

- the 'queue' is a directory - here it is opened


     fstat64(6, {st_mode=3DS_IFDIR|0775, st_size=3D4096, ...}) =3D 0
     fcntl64(6, F_SETFD, FD_CLOEXEC)         =3D 0
     getdents64(6, /* 6 entries */, 4096)    =3D 184
     getdents64(6, /* 0 entries */, 4096)    =3D 0
     close(6)                                =3D 0
     stat64("/home/ahoward/q/db.schema", {st_mode=3DS_IFREG|0664, st_size=
=3D1023, ...}) =3D 0
     open("/home/ahoward/q/db", O_RDWR|O_CREAT|O_LARGEFILE, 0644) =3D 6

- the actual queue database is opened here


     fstat64(6, {st_mode=3DS_IFREG|0644, st_size=3D20480, ...}) =3D 0
     getpid()                                =3D 21303
     fcntl64(6, F_SETLK64, {type=3DF_RDLCK, whence=3DSEEK_SET, start=3D0, l=
en=3D0}, 0xbffe5ec0) =3D 0

- a read lock is aquired on the database

     access("/home/ahoward/q/db-journal", F_OK) =3D -1 ENOENT (No such file=
 or directory)
     fstat64(6, {st_mode=3DS_IFREG|0644, st_size=3D20480, ...}) =3D 0
     _llseek(6, 0, [0], SEEK_SET)            =3D 0
     read(6, "** This file contains an SQLite "..., 1024) =3D 1024
     _llseek(6, 1024, [1024], SEEK_SET)      =3D 0
     read(6, "\16\0\0\0\10\0p\0\r\0\0\0\4\0\0\0\0\0W\0\200\0\0\t\6\f"..., 1=
024) =3D 1024
     _llseek(6, 12288, [12288], SEEK_SET)    =3D 0
     read(6, "\0\0\0\0\10\0\324\3\0\0\0\0\4\0\4\1\0\0:\1\200\0\0\1\f"..., 1=
024) =3D 1024
     _llseek(6, 3072, [3072], SEEK_SET)      =3D 0
     read(6, "\0\0\0\0        runner,\n          pi"..., 1024) =3D 1024
     _llseek(6, 13312, [13312], SEEK_SET)    =3D 0
     read(6, "\0\0\0\0\10\0h\2\0\0\0\0\4\0l\0\0\0T\0\200\0\0\n\6\f\35"..., =
1024) =3D 1024
     fcntl64(6, F_SETLK64, {type=3DF_UNLCK, whence=3DSEEK_SET, start=3D0, l=
en=3D0}, 0xbffe5ed0) =3D 0
     stat64("/var/tmp", {st_mode=3DS_IFDIR|S_ISVTX|0777, st_size=3D4096, ..=
=2E}) =3D 0
     access("/var/tmp", R_OK|W_OK|X_OK)      =3D 0
     time([1094347578])                      =3D 1094347578
     getpid()                                =3D 21303
     access("/var/tmp/sqlite_PmrqlF8Wu0NhxEj", F_OK) =3D -1 ENOENT (No such=
 file or directory)
     access("/var/tmp/sqlite_PmrqlF8Wu0NhxEj", F_OK) =3D -1 ENOENT (No such=
 file or directory)
     open("/var/tmp/sqlite_PmrqlF8Wu0NhxEj", O_RDWR|O_CREAT|O_EXCL|O_LARGEF=
ILE, 0600) =3D 7
     fstat64(7, {st_mode=3DS_IFREG|0600, st_size=3D0, ...}) =3D 0
     getpid()                                =3D 21303
     unlink("/var/tmp/sqlite_PmrqlF8Wu0NhxEj") =3D 0
     fcntl64(7, F_SETLK64, {type=3DF_RDLCK, whence=3DSEEK_SET, start=3D0, l=
en=3D0}, 0xbffe5ec0) =3D 0
     access("/var/tmp/sqlite_PmrqlF8Wu0NhxEj-journal", F_OK) =3D -1 ENOENT =
(No such file or directory)
     fstat64(7, {st_mode=3DS_IFREG|0600, st_size=3D0, ...}) =3D 0
     fcntl64(7, F_SETLK64, {type=3DF_UNLCK, whence=3DSEEK_SET, start=3D0, l=
en=3D0}, 0xbffe5ed0) =3D 0
     fcntl64(6, F_SETLK64, {type=3DF_RDLCK, whence=3DSEEK_SET, start=3D0, l=
en=3D0}, 0xbffe32e0) =3D 0
     access("/home/ahoward/q/db-journal", F_OK) =3D -1 ENOENT (No such file=
 or directory)
     fstat64(6, {st_mode=3DS_IFREG|0644, st_size=3D20480, ...}) =3D 0
     _llseek(6, 0, [0], SEEK_SET)            =3D 0
     read(6, "** This file contains an SQLite "..., 1024) =3D 1024

- i don't undertand all this stuff about /var/tmp - but safe to say it's no=
t
   causing sillynames ;-)


     fcntl64(6, F_SETLK64, {type=3DF_WRLCK, whence=3DSEEK_SET, start=3D0, l=
en=3D0}, 0xbffe3340) =3D 0

- here the database lock is 'upgraded to a write lock

     access("/home/ahoward/q/db-journal", F_OK) =3D -1 ENOENT (No such file=
 or directory)
     open("/home/ahoward/q/db-journal", O_RDWR|O_CREAT|O_EXCL|O_LARGEFILE, =
0600) =3D 8

- next the db-journal is opened

     fstat64(8, {st_mode=3DS_IFREG|0600, st_size=3D0, ...}) =3D 0
     getpid()                                =3D 21303
     open("/home/ahoward/q", O_RDONLY|O_LARGEFILE) =3D 9

- note here that the directory itself is opened

     write(8, "\331\325\5\371 \241c\326", 8) =3D 8
     write(8, "\0\0\0\0", 4)                 =3D 4
     write(8, "\330\224\361\16", 4)          =3D 4
     write(8, "\0\0\0\24", 4)                =3D 4
     fcntl64(7, F_SETLK64, {type=3DF_RDLCK, whence=3DSEEK_SET, start=3D0, l=
en=3D0}, 0xbffe32e0) =3D 0
     access("/var/tmp/sqlite_PmrqlF8Wu0NhxEj-journal", F_OK) =3D -1 ENOENT =
(No such file or directory)
     fstat64(7, {st_mode=3DS_IFREG|0600, st_size=3D0, ...}) =3D 0
     fcntl64(7, F_SETLK64, {type=3DF_WRLCK, whence=3DSEEK_SET, start=3D0, l=
en=3D0}, 0xbffe3340) =3D 0
     access("/var/tmp/sqlite_PmrqlF8Wu0NhxEj-journal", F_OK) =3D -1 ENOENT =
(No such file or directory)
     open("/var/tmp/sqlite_PmrqlF8Wu0NhxEj-journal", O_RDWR|O_CREAT|O_EXCL|=
O_LARGEFILE, 0600) =3D 10
     fstat64(10, {st_mode=3DS_IFREG|0600, st_size=3D0, ...}) =3D 0
     getpid()                                =3D 21303
     unlink("/var/tmp/sqlite_PmrqlF8Wu0NhxEj-journal") =3D 0
     open("/var/tmp", O_RDONLY|O_LARGEFILE)  =3D 11
     write(10, "\331\325\5\371 \241c\326", 8) =3D 8
     write(10, "\377\377\377\377", 4)        =3D 4
     write(10, "\261\241\220\36", 4)         =3D 4
     write(10, "\0\0\0\0", 4)                =3D 4
     _llseek(6, 2048, [2048], SEEK_SET)      =3D 0
     read(6, "\0\0\0\0\10\0`\0\0\0\0\0\4\0\0\0\0\0G\0\200\0\0\1\r\r\17"...,=
 1024) =3D 1024
     _llseek(6, 16384, [16384], SEEK_SET)    =3D 0
     read(6, "\0\0\0\0\10\0\34\0\0\0\0\0\6\0\0\0\0\0\0\0a\0\200\0\0\1"..., =
1024) =3D 1024

- the transaction takes place

     close(9)                                =3D 0

- the directory is closed

     close(8)                                =3D 0

- the db-journal file is closed (but not sync'd ?!)

     unlink("/home/ahoward/q/db-journal")    =3D 0

- the db-journal file is removed (sillyname created)

     fcntl64(6, F_SETLK64, {type=3DF_RDLCK, whence=3DSEEK_SET, start=3D0, l=
en=3D0}, 0xbffe3310) =3D 0

- the database lock is downgraded to a read lock

     fcntl64(6, F_SETLK64, {type=3DF_UNLCK, whence=3DSEEK_SET, start=3D0, l=
en=3D0}, 0xbffe32e0) =3D 0

- the database is unlocked



the sillyname appears with the same size as a previous db-journal and remov=
ing
the 'begin/end' sql, which causes this file to be created/removed fixes the
sillynames.  my code doesn't use the 'db-journal' code at all for any reaso=
n.
so, any ideas?  the code seems like it should work without creating silly
files, but...

btw.  i would like to be able to contribute to the nfs code base - but it's
simply way out of my league.  all the help this list gives is most apprecia=
ted
though!

kind regards.

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
--8323328-1960210736-1094348987=:17016--


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
