From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Re: NFS problems with Linux-2.4
Date: Wed, 21 May 2003 07:24:00 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C611312750C@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19IUVl-0006EO-00
	for <nfs@lists.sourceforge.net>; Wed, 21 May 2003 07:24:09 -0700
To: "Steve Dickson" <SteveD@RedHat.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

> While its true that this program, p1.c with the rename, does
> not really check cto cache consistency it still should work (IMHO)..

how does it behave on, say, a solaris NFS client?

> After some investigation it turns out that the timestamps that is
> used in handling negative lookups was not being updated
> as precisely as it could be... And since this timestamps is also used
> with other caches (namely the readdir cache), ISTM, that keeping
> in sync (as much as possible) with the server is a good thing...
>=20
> Please try the attached patch....
>=20
> SteveD.
>=20
> Jim Nance wrote:
> > On Tue, May 13, 2003 at 05:19:23PM +0200, Trond Myklebust wrote:
> >=20
> >>Could you please try with a newer kernel. The close-to-open cache
> >>consistency fixes are a relatively recent addition to the Linux NFS
> >>client. I dunno if RedHat's 2.4.18 kernel has them.
> >>
> >>  2.4.7 certainly does not.
> >=20
> >=20
> > I tried again with the 2.4.20 based kernel that Red Hat released
> > yesterday (2.4.20-13.7bigmem).  The problem that I was seeing occurs
> > less frequently there, but it still happens.
> >=20
> > I have attached a program which can reproduce this.  If you run it
> > under 2.4.7 it fails instantly.  If you use 2.4.20 it may take a
> > minute or so but it will also fail.
> >=20
> > Thanks,
> >=20
> > Jim
> >=20
> > PS: Do you know if there is any way to work around this problem from
> >     within my program?
> >=20
> >=20
> >=20
> >=20
> --------------------------------------------------------------
> ----------
> >=20
> > /* This program demonstrates a problem with the close/open=20
> consistency
> >  * of NFS file systems under Linux.  It fails very rapidy=20
> with Red Hats
> >  * 2.4.7-10smp kernel.  This kernel was known to have bugs.=20
>  It also fails
> >  * with Red Hats 2.4.20-13.7bigmem kernel, which was=20
> thought to have this
> >  * bug fixed.  For my testcase both linux machines were talking to a
> >  * network applicance file server and mounted like this:
> >  *
> >  * na1-rtp:/vol/vol0/home/jlnance /home/jlnance nfs=20
> rw,v3,rsize=3D4096,\
> >  * wsize=3D4096,hard,intr,udp,lock,addr=3Dna1-rtp 0 0
> >  *
> >  * This program needs to be run on 2 machines, assume=20
> hostnames A & B.
> >  * A and B need to share an NFS mounted file system.
> >  *
> >  * On machine A:
> >  *   cd /some/nfs/path/common/to/both
> >  *   ./p1 s
> >  *
> >  * On machine B:
> >  *   cd /some/nfs/path/common/to/both
> >  *   ./p1 c A
> >  *
> >  * After a while you may see output similar to:
> >  *   cayman> ./p1 s
> >  *   Failed to find #0 which client wrote
> >  *   Failed on file number 483
> >  */
> >=20
> >=20
> > #include <stdio.h>
> > #include <stdlib.h>
> > #include <sys/types.h>
> > #include <sys/stat.h>
> > #include <sys/socket.h>
> > #include <netinet/in.h>
> > #include <fcntl.h>
> > #include <unistd.h>
> > #include <errno.h>
> > #include <netdb.h>
> >=20
> > #define PORT 12387
> > #define FLEN 16
> >=20
> > void die()
> > {
> >   perror("");
> >   exit(-1);
> > }
> >=20
> > void Write(int fd, char *buff, size_t len)
> > {
> >   for(;;) {
> >     int nsent=3Dwrite(fd, buff, len);
> >     if(nsent=3D=3D0)
> >       exit(0);
> >     if(nsent=3D=3D-1) {
> >       if(errno!=3DEINTR)
> >         die();
> >     } else {
> >       buff +=3D nsent;
> >       len  -=3D nsent;
> >       if(len=3D=3D0) {
> >         return;
> >       }
> >     }
> >   }
> > }
> >=20
> > void Read(int fd, char *buff, size_t len)
> > {
> >   for(;;) {
> >     int nread=3Dread(fd, buff, len);
> >     if(nread=3D=3D0)
> >       exit(0);
> >     if(nread=3D=3D-1) {
> >       if(errno!=3DEINTR)
> >         die();
> >     } else {
> >       buff +=3D nread;
> >       len  -=3D nread;
> >       if(len=3D=3D0) {
> >         return;
> >       }
> >     }
> >   }
> > }
> >=20
> > int server()
> > {
> >   int sock =3D socket(AF_INET, SOCK_STREAM, 0);
> >   if(sock=3D=3D-1) die(); else {
> >     struct sockaddr_in name;
> >     int                on =3D 1;
> >     name.sin_family       =3D AF_INET;
> >     name.sin_addr.s_addr  =3D htonl(INADDR_ANY);
> >     name.sin_port         =3D htons(PORT);
> >=20
> >     setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &on, sizeof on);
> >     if(bind(sock, (struct sockaddr*)&name,=20
> sizeof(name))=3D=3D-1) die(); else {
> >       if(listen(sock, 1)=3D=3D-1) die(); else {
> >         int tsock =3D accept(sock, 0, 0);
> >         if(tsock!=3D-1) {
> >           int cnt;
> >=20
> >           for(cnt=3D0; cnt<100000; cnt++) {
> >             int  fd;
> >             char dummy;
> >             char number[FLEN];
> >             struct stat sbuf;
> >             /*sprintf(number, "#%d", cnt);*/
> >             sprintf(number, "#%d", 0);
> >             Write(tsock, number, sizeof(number));
> >             Read(tsock, &dummy, 1);
> >             if(stat(number, &sbuf)) {
> >               fprintf(stderr, "Failed to find %s which=20
> client wrote\n", number);
> >               fprintf(stderr, "Failed on file number %d\n", cnt);
> >               exit(-2);
> >             }
> >             unlink(number);
> >           }
> >         }
> >       }
> >     }
> >   }
> >=20
> >   return 0;
> > }
> >=20
> > int client(char *server)
> > {
> >   struct hostent *info =3D gethostbyname(server);
> >   if(!info) die(); else {
> >     int rsocket =3D socket(AF_INET, SOCK_STREAM, 0);
> >     if(rsocket=3D=3D-1) die(); else {
> >       struct sockaddr_in name;
> >       name.sin_family =3D AF_INET;
> >       name.sin_port   =3D htons(PORT);
> >       memcpy(&name.sin_addr, info->h_addr_list[0],=20
> sizeof(struct in_addr));
> >       if(connect(rsocket, (struct sockaddr*)&name,=20
> sizeof(name))=3D=3D-1)
> >         die();
> >       else {
> >         for(;;) {
> >           int  fd;
> >           char fname[FLEN];
> >           char tname[FLEN+8];
> >=20
> >           Read(rsocket, fname, sizeof(fname));
> >           strcpy(tname, fname);
> >           strcat(tname, ".tmp");
> >=20
> >           fd =3D open(tname, O_WRONLY|O_CREAT, 0600);
> >           if(fd=3D=3D-1) die();
> >=20
> >           Write(fd, fname, sizeof(fname)); /* Junk data */
> >           close(fd);
> >=20
> >           rename(tname, fname);
> >=20
> >           Write(rsocket, fname, 1); /* Tells the server we=20
> are done */
> >         }
> >       }
> >     }
> >   }
> >=20
> >   return 0;
> > }
> >=20
> > void usage(char *prog)
> > {
> >   fprintf(stderr, "Usage:\n");
> >   fprintf(stderr, " %s s\n", prog);
> >   fprintf(stderr, " %s c servername\n", prog);
> >   fprintf(stderr, " Run 1 of each in the same NFS directory=20
> on 2 different "
> >         "machines\n Two processes total\n");
> >   exit(-1);
> > }
> >=20
> > int main(int ac, char **av)
> > {
> >   if(ac<2) {
> >     usage(av[0]);
> >   } if(av[1][0]=3D=3D's') {
> >     return server();
> >   }else if(ac<3) {
> >     usage(av[0]);
> >   } else if(av[1][0]=3D=3D'c') {
> >     return client(av[2]);
> >   } else {
> >     usage(av[0]);
> >   }
> >=20
> >   return -1;
> > }
>=20


-------------------------------------------------------
This SF.net email is sponsored by: ObjectStore.
If flattening out C++ or Java code to make your application fit in a
relational database is painful, don't do it! Check out ObjectStore.
Now part of Progress Software. http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
