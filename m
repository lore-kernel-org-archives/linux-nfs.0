From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: x86_64: 32bit emulation problems
Date: Tue, 1 Mar 2005 23:30:41 +0100
Message-ID: <200503012330.42154.bernd-schubert@web.de>
References: <200502282154.08009.bernd.schubert@pci.uni-heidelberg.de> <200503012207.02915.bernd-schubert@web.de> <20050301214832.GA44624@muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	nfs@lists.sourceforge.net
To: Andi Kleen <ak@muc.de>
In-Reply-To: <20050301214832.GA44624@muc.de>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

> strace didn't say so, and normally it doesn't lie about things like t=
his.

Well, I show you the updated source code and strace output and if you s=
till=20
don't believe me, ask me for a login to our system ;)


#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>


int main(int argc, char **argv)
{
        char *dir;
        struct stat *buf;
        int err;

        dir =3D argv[1];

        buf =3D malloc(sizeof(struct stat));

        errno =3D 0;

        err =3D stat(dir, buf);
        if ( err ) {
                fprintf(stderr, "err =3D %i\n", err);
                fprintf(stderr, "stat for %s failed \n", dir);
                fprintf(stderr, "ernno: %i (%s)\n", errno, strerror(err=
no));
        } else
                fprintf(stderr, "stat() works fine.\n");

        return (0);
}


>
> > > bernd@hitchcock tests>./test_stat32 /mnt/test/yp
> > > stat for /mnt/test/yp failed
> > > ernno: 75 (Value too large for defined data type)
>
> errno is undefined unless a system call returned -1 before or
> you set it to 0 before.

See above.

>
> > > But why does stat64() on a 64-bit kernel tries to fill in larger =
data
> > > than
>
> A 64bit kernel has no stat64(). All stats are 64bit.

bernd@hitchcock tests>strace32 ./test_stat32 /mnt/test/yp
execve("./test_stat32", ["./test_stat32", "/mnt/test/yp"], [/* 43 vars =
*/]) =3D=20
0
uname({sys=3D"Linux", node=3D"hitchcock", ...}) =3D 0
brk(0)                                  =3D 0x80ad000
brk(0x80ce000)                          =3D 0x80ce000
stat64("/mnt/test/yp", {st_mode=3DS_IFDIR|0755, st_size=3D2704, ...}) =3D=
 0
write(2, "err =3D -1\n", 9err =3D -1
)               =3D 9
write(2, "stat for /mnt/test/yp failed \n", 30stat for /mnt/test/yp fai=
led
) =3D 30
write(2, "ernno: 75 (Value too large for d"..., 50ernno: 75 (Value too =
large=20
for defined data type)
) =3D 50
exit_group(0)                           =3D ?

You certainly know much better than me, but I think strace shows that i=
ts=20
calling stat64.

>
> > > on a 32-bit kernel and larger data also only for nfs-mount points=
? Hmm,
> > > I will tomorrow compare the tcp-packges sent by the server.
> >
> > So I still think thats a kernel bug.
>
> Your data so far doesn't support this assertion.

I have to admit that knfsd-mount moints are not affected, but on the ot=
her=20
hand, I really cant't see anything in the ethereal captures. If someone=
=20
should be interested, I have uploaded them:

http://www.pci.uni-heidelberg.de/tc/usr/bernd/downloads/nfs-stat/


Cheers,
 Bernd


--=20
Bernd Schubert
Physikalisch Chemisches Institut / Theoretische Chemie
Universit=E4t Heidelberg
INF 229
69120 Heidelberg
e-mail: bernd.schubert@pci.uni-heidelberg.de
