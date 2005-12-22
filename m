From: khowe@micron.com
Subject: Fcntl F_SETLKW hangs on Linux NFS mount
Date: Thu, 22 Dec 2005 13:57:24 -0700
Message-ID: <AB58C1C45C3FD74A9C262584E8F8C16001F001D1@ntxboimbx16.micron.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C6073A.4EF533E7"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EpXVF-00063v-Jj
	for nfs@lists.sourceforge.net; Thu, 22 Dec 2005 12:57:33 -0800
Received: from masquerade.micron.com ([137.201.242.130])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EpXVF-0005Jc-26
	for nfs@lists.sourceforge.net; Thu, 22 Dec 2005 12:57:33 -0800
Received: from mail-srv2.micron.com (localhost [127.0.0.1])
	by masquerade.micron.com (8.12.9/8.12.2) with ESMTP id jBMKw1qh021170
	for <nfs@lists.sourceforge.net>; Thu, 22 Dec 2005 13:58:01 -0700 (MST)
Received: from ntxboimbx16.micron.com (ntxboimbx16.micron.com [137.201.82.61])
	by mail-srv2.micron.com (8.12.9/8.12.11) with ESMTP id jBMKvx2N021142
	for <nfs@lists.sourceforge.net>; Thu, 22 Dec 2005 13:58:00 -0700 (MST)
To: <nfs@lists.sourceforge.net>
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

This is a multi-part message in MIME format.

------_=_NextPart_001_01C6073A.4EF533E7
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

I'm running into an issue when using fcntl with the F_SETLKW command on
a Linux NFS client. In cases where I have many processes all trying to
get a write lock at once, the call to fcntl never returns, even though
the lock appears to have been granted successfully. It is not a
consistent error, but it is fairly repeatable (about 30% of the time).
I'm running on a RedHat client, though I'm not exactly sure of the
RedHat version. However, the kernel reported by uname is "Linux
prblnx-bo04 2.4.21-32.ELsmp #1 SMP Fri Apr 15 21:17:59 EDT 2005 i686
i686 i386 GNU/Linux", and it appears to be using v1.0.6 of nfs-utils.
The mounts are set via autofs, using automount v4.1.3-130.

My test program creates 16 process that all try to get a write lock on
the same file, and it will frequently fail such that one of the
processes appears to have been granted the lock but does not return from
the fcntl call (and the remaining processes are then also all stuck).
Listing open files and locks using "lsof -N" shows that one of the
processes has been granted the W lock, yet this same process does not
return from the fcntl call. I have toyed with the mounting options on
the client and I am seeing this behavior with NFS v2 and v3, with short
or long timeouts (from timeo=3D7 to timeo=3D600), with intr and with =
nointr,
and with r and wsize's ranging from 1024 to 32768. The only option I
haven't been able to mess with is using TCP instead of UDP, since this
particular RedHat build does not seem to allow the TCP option.

The NFS server for the mount is a vendor provided NAS device, and I'm
not sure what its OS or NFS server is. However, the fact that lsof shows
the lock has been granted seems to indicate the disconnect is somewhere
on the client side after getting the lock but before waking up fcntl. I
also run the exact some program on a Solaris host against the same mount
and have no issues at all, which also seems to rule out a server-side
issue.

The test program I'm using is a c app compiled with gcc v3.3.1. Any
thoughts? Thanks...

#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/time.h>

extern int errno;

double now(void) {
  struct timeval tv;
  struct timezone tz;
 =20
  gettimeofday(&tv, &tz);
 =20
  return((double)tv.tv_sec + (double)tv.tv_usec/1000000);
}

int main(int argc, char **argv) {
  int i, j, id =3D 0;
 =20
  // create test lock file
  int lock_h =3D open(argv[1], O_CREAT | O_TRUNC | O_WRONLY, S_IRWXU);
  if (lock_h =3D=3D -1) {
    printf("failed to create lock file: %s\n", strerror(errno));
    exit(2);
  }
  else {
    close(lock_h);
  }
 =20
  // fork some workers
  pid_t pids[4] =3D { 0, 0, 0, 0 };
  for (i =3D 3; i >=3D 0; i--) {
    pid_t pid =3D fork();
    if (pid =3D=3D -1) {
      printf("failed to fork: %s\n", strerror(errno));
      exit(3);
    }
    if (pid =3D=3D 0) {
      int pow =3D 1;
      for (j =3D 0; j < i; j++) {
        pow *=3D 2;
      }
      id +=3D pow;
    }
    pids[i] =3D pid;
  }
 =20
  pid_t mypid =3D getpid();
 =20
  // open lock file for write and try to lock it
  int status;
  struct flock lock;
  lock.l_type =3D F_WRLCK;
  lock.l_whence =3D 0;
  lock.l_start =3D 0;
  lock.l_len =3D 0;
  lock_h =3D open(argv[1], O_WRONLY);
  if (lock_h =3D=3D -1) {
    printf("failed to open lock file: %s\n", strerror(errno));
    exit(4);
  }
  printf("%15.5f %05d %s\n", now(), mypid, "trying lock");
  status =3D fcntl(lock_h, F_SETLKW, &lock);
  if (status =3D=3D 0) {
    printf("%15.5f %05d %s\n", now(), mypid, "got lock");
    lock.l_type =3D F_UNLCK;
    fcntl(lock_h, F_SETLKW, &lock);
    printf("%15.5f %05d %s\n", now(), mypid, "freed lock");
  }
  else {
    printf("%15.5f %05d %s\n", now(), mypid, "failed lock");
    printf("%15.5f %05d %s\n", now(), mypid, strerror(errno));
  }
  close(lock_h);
 =20
  // cleanup and quit
  for (i =3D 0; i < 4; i++) {
    if (pids[i] !=3D 0) {
      waitpid(pids[i], &status, 0);
    }
  }
  if (id =3D=3D 0) {
    unlink(argv[1]);
  }
 =20
  return(0);
}

------_=_NextPart_001_01C6073A.4EF533E7
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Dus-ascii">
<META NAME=3D"Generator" CONTENT=3D"MS Exchange Server version =
6.5.7226.0">
<TITLE>Fcntl F_SETLKW hangs on Linux NFS mount</TITLE>
</HEAD>
<BODY>
<!-- Converted from text/rtf format -->

<P><FONT SIZE=3D2 FACE=3D"Verdana">I'm running into an issue when using =
fcntl with the F_SETLKW command on a Linux NFS client. In cases where I =
have many processes all trying to get a write lock at once, the call to =
fcntl never returns, even though the lock appears to have been granted =
successfully. It is not a consistent error, but it is fairly repeatable =
(about 30% of the time). I'm running on a RedHat client, though I'm not =
exactly sure of the RedHat version. However, the kernel reported by =
uname is &quot;Linux prblnx-bo04 2.4.21-32.ELsmp #1 SMP Fri Apr 15 =
21:17:59 EDT 2005 i686 i686 i386 GNU/Linux&quot;, and it appears to be =
using v1.0.6 of nfs-utils. The mounts are set via autofs, using =
automount v4.1.3-130.</FONT></P>

<P><FONT SIZE=3D2 FACE=3D"Verdana">My test program creates 16 process =
that all try to get a write lock on the same file, and it will =
frequently fail such that one of the processes appears to have been =
granted the lock but does not return from the fcntl call (and the =
remaining processes are then also all stuck). Listing open files and =
locks using &quot;lsof -N&quot; shows that one of the processes has been =
granted the W lock, yet this same process does not return from the fcntl =
call. I have toyed with the mounting options on the client and I am =
seeing this behavior with NFS v2 and v3, with short or long timeouts =
(from timeo=3D7 to timeo=3D600), with intr and with nointr, and with r =
and wsize's ranging from 1024 to 32768. The only option I haven't been =
able to mess with is using TCP instead of UDP, since this particular =
RedHat build does not seem to allow the TCP option.</FONT></P>

<P><FONT SIZE=3D2 FACE=3D"Verdana">The NFS server for the mount is a =
vendor provided NAS device, and I'm not sure what its OS or NFS server =
is. However, the fact that lsof shows the lock has been granted seems to =
indicate the disconnect is somewhere on the client side after getting =
the lock but before waking up fcntl. I also run the exact some program =
on a Solaris host against the same mount and have no issues at all, =
which also seems to rule out a server-side issue.</FONT></P>

<P><FONT SIZE=3D2 FACE=3D"Verdana">The test program I'm using is a c app =
compiled with gcc v3.3.1. Any thoughts? Thanks&#8230;</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Verdana">#include &lt;errno.h&gt;</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">#include &lt;fcntl.h&gt;</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">#include &lt;stdio.h&gt;</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">#include &lt;string.h&gt;</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">#include &lt;unistd.h&gt;</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">#include &lt;sys/stat.h&gt;</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">#include &lt;sys/time.h&gt;</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Verdana">extern int errno;</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Verdana">double now(void) {</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; struct timeval tv;</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; struct timezone tz;</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; </FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; gettimeofday(&amp;tv, =
&amp;tz);</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; </FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; return((double)tv.tv_sec + =
(double)tv.tv_usec/1000000);</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">}</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Verdana">int main(int argc, char **argv) =
{</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; int i, j, id =3D 0;</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; </FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; // create test lock =
file</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; int lock_h =3D open(argv[1], =
O_CREAT | O_TRUNC | O_WRONLY, S_IRWXU);</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; if (lock_h =3D=3D -1) =
{</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp;&nbsp;&nbsp; =
printf(&quot;failed to create lock file: %s\n&quot;, =
strerror(errno));</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp;&nbsp;&nbsp; exit(2);</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; }</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; else {</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp;&nbsp;&nbsp; =
close(lock_h);</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; }</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; </FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; // fork some workers</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; pid_t pids[4] =3D { 0, 0, 0, =
0 };</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; for (i =3D 3; i &gt;=3D 0; =
i--) {</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp;&nbsp;&nbsp; pid_t pid =3D =
fork();</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp;&nbsp;&nbsp; if (pid =3D=3D =
-1) {</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
printf(&quot;failed to fork: %s\n&quot;, strerror(errno));</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
exit(3);</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp;&nbsp;&nbsp; }</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp;&nbsp;&nbsp; if (pid =3D=3D 0) =
{</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; int =
pow =3D 1;</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; for =
(j =3D 0; j &lt; i; j++) {</FONT>

<BR><FONT SIZE=3D2 =
FACE=3D"Verdana">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; pow *=3D =
2;</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
}</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; id =
+=3D pow;</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp;&nbsp;&nbsp; }</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp;&nbsp;&nbsp; pids[i] =3D =
pid;</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; }</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; </FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; pid_t mypid =3D =
getpid();</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; </FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; // open lock file for write =
and try to lock it</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; int status;</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; struct flock lock;</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; lock.l_type =3D =
F_WRLCK;</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; lock.l_whence =3D 0;</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; lock.l_start =3D 0;</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; lock.l_len =3D 0;</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; lock_h =3D open(argv[1], =
O_WRONLY);</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; if (lock_h =3D=3D -1) =
{</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp;&nbsp;&nbsp; =
printf(&quot;failed to open lock file: %s\n&quot;, =
strerror(errno));</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp;&nbsp;&nbsp; exit(4);</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; }</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; printf(&quot;%15.5f %05d =
%s\n&quot;, now(), mypid, &quot;trying lock&quot;);</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; status =3D fcntl(lock_h, =
F_SETLKW, &amp;lock);</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; if (status =3D=3D 0) {</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp;&nbsp;&nbsp; =
printf(&quot;%15.5f %05d %s\n&quot;, now(), mypid, &quot;got =
lock&quot;);</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp;&nbsp;&nbsp; lock.l_type =3D =
F_UNLCK;</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp;&nbsp;&nbsp; fcntl(lock_h, =
F_SETLKW, &amp;lock);</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp;&nbsp;&nbsp; =
printf(&quot;%15.5f %05d %s\n&quot;, now(), mypid, &quot;freed =
lock&quot;);</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; }</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; else {</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp;&nbsp;&nbsp; =
printf(&quot;%15.5f %05d %s\n&quot;, now(), mypid, &quot;failed =
lock&quot;);</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp;&nbsp;&nbsp; =
printf(&quot;%15.5f %05d %s\n&quot;, now(), mypid, =
strerror(errno));</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; }</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; close(lock_h);</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; </FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; // cleanup and quit</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; for (i =3D 0; i &lt; 4; i++) =
{</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp;&nbsp;&nbsp; if (pids[i] !=3D =
0) {</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
waitpid(pids[i], &amp;status, 0);</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp;&nbsp;&nbsp; }</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; }</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; if (id =3D=3D 0) {</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp;&nbsp;&nbsp; =
unlink(argv[1]);</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; }</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; </FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">&nbsp; return(0);</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Verdana">}</FONT>
</P>

</BODY>
</HTML>
------_=_NextPart_001_01C6073A.4EF533E7--


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
