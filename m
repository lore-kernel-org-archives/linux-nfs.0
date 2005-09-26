From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS caching problem
Date: Mon, 26 Sep 2005 16:01:58 -0400
Message-ID: <1127764918.8327.22.camel@lade.trondhjem.org>
References: <43384863.10807@atmos.washington.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EJzB5-00042b-OA
	for nfs@lists.sourceforge.net; Mon, 26 Sep 2005 13:02:19 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EJzB4-0007d5-BD
	for nfs@lists.sourceforge.net; Mon, 26 Sep 2005 13:02:19 -0700
To: David Warren <warren@atmos.washington.edu>
In-Reply-To: <43384863.10807@atmos.washington.edu>
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

m=C3=A5 den 26.09.2005 Klokka 12:13 (-0700) skreiv David Warren:
> I have discovered a wierd problem with NFSv3 on linux.
> I have 3 machines
> machine A and B  both mount a disk D  from machine C
> The options are tcp,rw,hard and intr.
>=20
> Program test runs on machine A writing to D:
> (fortran)
>       program test
>       do i=3D1,10
>          call system("/bin/rm t")
>          open (10, file=3D't', status=3D'new')
>          write(10,*)i
>          write(6,*)i
>          close(10)
>          call sleep(1)
>       enddo
>       end
>=20
> program t2 runs on machine B reading from D:
> (c, but doesn't have to be)
> #include <stdlib.h>
> #include <fcntl.h>
> main(){
>   char in[80];
>   int file;
>   int len;
>=20
>   while(1){
>     file=3Dopen("t", O_RDONLY);
>     len=3Dread(file,in,79);
>     in[len]=3D'\0';
>     printf("%s\n",in);
>     close(file);
>   }
> }
>=20
> while machine A is counting 1 - 10 and placing these numbers into file=20
> t, machine B is continually reading 1 from file t, then after a while it=20
> will switch to another number and read it for a while. In my first=20
> version of this, I was opening and rewriting the same file. In that=20
> version, machine B always read 1's. Now that I am creating new inodes=20
> all the time, it changes every few minutes while I repeatedly rerun test=20
> on machine A.
>=20
> Now for the other interresting facts:
> Reading this file from an unrelated sun during this produces the same=20
> result as machine B.
> The same thing under NFSv4 does not do this. It works exactly as one=20
> would expect it to. As soon as the file is writen, the reader sees the=20
> new data.
>=20
> Any ideas what I could have done wrong in my NFSv3 set up? Is there some=20
> kernel parameter that need tweaking? is there some mount option I should=20
> have???
> Thanks.

When I see that problem on my test-rig, it appears to be due to the
reuse of inode numbers by my server. IOW: the file created by the
fortran program always ends up having the same inode number (check this
using 'ls -i t').

In that case, the client is indeed expected to have problems recognising
that the file has changed w.r.t. the cache.

Cheers,
 Trond



-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
