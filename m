From: Steve Dickson <SteveD@RedHat.com>
Subject: Re: NFS problems with Linux-2.4
Date: Wed, 21 May 2003 07:39:28 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3ECB6570.2040303@RedHat.com>
References: <20030513145023.GA10383@ncsu.edu> <16065.3323.449992.207039@charged.uio.no> <mailman.1053012601.1068.linux-kernel2news@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090507020500050101040703"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from host-64-179-20-100.man.choiceone.net ([64.179.20.100] helo=Odyssey.Home.4Dicksons.Org)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19IRs9-0006KH-00
	for <nfs@lists.sourceforge.net>; Wed, 21 May 2003 04:35:05 -0700
Received: from RedHat.com (Grendel.Home.4Dicksons.Org [192.168.62.4])
	by Odyssey.Home.4Dicksons.Org (8.11.6/8.11.0) with ESMTP id h4LBYql23484
	for <nfs@lists.sourceforge.net>; Wed, 21 May 2003 07:34:52 -0400 (EDT)
	(envelope-from SteveD@RedHat.com)
In-Reply-To: <mailman.1053012601.1068.linux-kernel2news@redhat.com>
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

This is a multi-part message in MIME format.
--------------090507020500050101040703
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hello,

While its true that this program, p1.c with the rename, does
not really check cto cache consistency it still should work (IMHO)..

After some investigation it turns out that the timestamps that is
used in handling negative lookups was not being updated
as precisely as it could be... And since this timestamps is also used
with other caches (namely the readdir cache), ISTM, that keeping
in sync (as much as possible) with the server is a good thing...

Please try the attached patch....

SteveD.

Jim Nance wrote:
> On Tue, May 13, 2003 at 05:19:23PM +0200, Trond Myklebust wrote:
> 
>>Could you please try with a newer kernel. The close-to-open cache
>>consistency fixes are a relatively recent addition to the Linux NFS
>>client. I dunno if RedHat's 2.4.18 kernel has them.
>>
>>  2.4.7 certainly does not.
> 
> 
> I tried again with the 2.4.20 based kernel that Red Hat released
> yesterday (2.4.20-13.7bigmem).  The problem that I was seeing occurs
> less frequently there, but it still happens.
> 
> I have attached a program which can reproduce this.  If you run it
> under 2.4.7 it fails instantly.  If you use 2.4.20 it may take a
> minute or so but it will also fail.
> 
> Thanks,
> 
> Jim
> 
> PS: Do you know if there is any way to work around this problem from
>     within my program?
> 
> 
> 
> ------------------------------------------------------------------------
> 
> /* This program demonstrates a problem with the close/open consistency
>  * of NFS file systems under Linux.  It fails very rapidy with Red Hats
>  * 2.4.7-10smp kernel.  This kernel was known to have bugs.  It also fails
>  * with Red Hats 2.4.20-13.7bigmem kernel, which was thought to have this
>  * bug fixed.  For my testcase both linux machines were talking to a
>  * network applicance file server and mounted like this:
>  *
>  * na1-rtp:/vol/vol0/home/jlnance /home/jlnance nfs rw,v3,rsize=4096,\
>  * wsize=4096,hard,intr,udp,lock,addr=na1-rtp 0 0
>  *
>  * This program needs to be run on 2 machines, assume hostnames A & B.
>  * A and B need to share an NFS mounted file system.
>  *
>  * On machine A:
>  *   cd /some/nfs/path/common/to/both
>  *   ./p1 s
>  *
>  * On machine B:
>  *   cd /some/nfs/path/common/to/both
>  *   ./p1 c A
>  *
>  * After a while you may see output similar to:
>  *   cayman> ./p1 s
>  *   Failed to find #0 which client wrote
>  *   Failed on file number 483
>  */
> 
> 
> #include <stdio.h>
> #include <stdlib.h>
> #include <sys/types.h>
> #include <sys/stat.h>
> #include <sys/socket.h>
> #include <netinet/in.h>
> #include <fcntl.h>
> #include <unistd.h>
> #include <errno.h>
> #include <netdb.h>
> 
> #define PORT 12387
> #define FLEN 16
> 
> void die()
> {
>   perror("");
>   exit(-1);
> }
> 
> void Write(int fd, char *buff, size_t len)
> {
>   for(;;) {
>     int nsent=write(fd, buff, len);
>     if(nsent==0)
>       exit(0);
>     if(nsent==-1) {
>       if(errno!=EINTR)
>         die();
>     } else {
>       buff += nsent;
>       len  -= nsent;
>       if(len==0) {
>         return;
>       }
>     }
>   }
> }
> 
> void Read(int fd, char *buff, size_t len)
> {
>   for(;;) {
>     int nread=read(fd, buff, len);
>     if(nread==0)
>       exit(0);
>     if(nread==-1) {
>       if(errno!=EINTR)
>         die();
>     } else {
>       buff += nread;
>       len  -= nread;
>       if(len==0) {
>         return;
>       }
>     }
>   }
> }
> 
> int server()
> {
>   int sock = socket(AF_INET, SOCK_STREAM, 0);
>   if(sock==-1) die(); else {
>     struct sockaddr_in name;
>     int                on = 1;
>     name.sin_family       = AF_INET;
>     name.sin_addr.s_addr  = htonl(INADDR_ANY);
>     name.sin_port         = htons(PORT);
> 
>     setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &on, sizeof on);
>     if(bind(sock, (struct sockaddr*)&name, sizeof(name))==-1) die(); else {
>       if(listen(sock, 1)==-1) die(); else {
>         int tsock = accept(sock, 0, 0);
>         if(tsock!=-1) {
>           int cnt;
> 
>           for(cnt=0; cnt<100000; cnt++) {
>             int  fd;
>             char dummy;
>             char number[FLEN];
>             struct stat sbuf;
>             /*sprintf(number, "#%d", cnt);*/
>             sprintf(number, "#%d", 0);
>             Write(tsock, number, sizeof(number));
>             Read(tsock, &dummy, 1);
>             if(stat(number, &sbuf)) {
>               fprintf(stderr, "Failed to find %s which client wrote\n", number);
>               fprintf(stderr, "Failed on file number %d\n", cnt);
>               exit(-2);
>             }
>             unlink(number);
>           }
>         }
>       }
>     }
>   }
> 
>   return 0;
> }
> 
> int client(char *server)
> {
>   struct hostent *info = gethostbyname(server);
>   if(!info) die(); else {
>     int rsocket = socket(AF_INET, SOCK_STREAM, 0);
>     if(rsocket==-1) die(); else {
>       struct sockaddr_in name;
>       name.sin_family = AF_INET;
>       name.sin_port   = htons(PORT);
>       memcpy(&name.sin_addr, info->h_addr_list[0], sizeof(struct in_addr));
>       if(connect(rsocket, (struct sockaddr*)&name, sizeof(name))==-1)
>         die();
>       else {
>         for(;;) {
>           int  fd;
>           char fname[FLEN];
>           char tname[FLEN+8];
> 
>           Read(rsocket, fname, sizeof(fname));
>           strcpy(tname, fname);
>           strcat(tname, ".tmp");
> 
>           fd = open(tname, O_WRONLY|O_CREAT, 0600);
>           if(fd==-1) die();
> 
>           Write(fd, fname, sizeof(fname)); /* Junk data */
>           close(fd);
> 
>           rename(tname, fname);
> 
>           Write(rsocket, fname, 1); /* Tells the server we are done */
>         }
>       }
>     }
>   }
> 
>   return 0;
> }
> 
> void usage(char *prog)
> {
>   fprintf(stderr, "Usage:\n");
>   fprintf(stderr, " %s s\n", prog);
>   fprintf(stderr, " %s c servername\n", prog);
>   fprintf(stderr, " Run 1 of each in the same NFS directory on 2 different "
>         "machines\n Two processes total\n");
>   exit(-1);
> }
> 
> int main(int ac, char **av)
> {
>   if(ac<2) {
>     usage(av[0]);
>   } if(av[1][0]=='s') {
>     return server();
>   }else if(ac<3) {
>     usage(av[0]);
>   } else if(av[1][0]=='c') {
>     return client(av[2]);
>   } else {
>     usage(av[0]);
>   }
> 
>   return -1;
> }

--------------090507020500050101040703
Content-Type: text/plain;
 name="linux-2.4.20-nfs-mtimeupdate.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.4.20-nfs-mtimeupdate.patch"

--- linux-2.4.20/fs/nfs/inode.c.diff	2003-05-17 18:21:35.000000000 -0400
+++ linux-2.4.20/fs/nfs/inode.c	2003-05-19 11:22:05.000000000 -0400
@@ -1096,6 +1096,12 @@
 	NFS_READTIME(inode) = fattr->timestamp;
 
 	/*
+	 * If need be, update the last time the mtime was changed
+	 */
+	if (time_after(fattr->timestamp, NFS_MTIME_UPDATE(inode)))
+		NFS_MTIME_UPDATE(inode) = fattr->timestamp;
+
+	/*
 	 * Note: NFS_CACHE_ISIZE(inode) reflects the state of the cache.
 	 *       NOT inode->i_size!!!
 	 */
@@ -1142,8 +1148,6 @@
 	inode->i_atime = new_atime;
 
 	if (NFS_CACHE_MTIME(inode) != new_mtime) {
-		if (invalid)
-			NFS_MTIME_UPDATE(inode) = fattr->timestamp;
 		NFS_CACHE_MTIME(inode) = new_mtime;
 		inode->i_mtime = nfs_time_to_secs(new_mtime);
 	}

--------------090507020500050101040703--



-------------------------------------------------------
This SF.net email is sponsored by: ObjectStore.
If flattening out C++ or Java code to make your application fit in a
relational database is painful, don't do it! Check out ObjectStore.
Now part of Progress Software. http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
