From: David Warren <warren@atmos.washington.edu>
Subject: NFS caching problem
Date: Mon, 26 Sep 2005 12:13:39 -0700
Message-ID: <43384863.10807@atmos.washington.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EJyQE-0001sB-14
	for nfs@lists.sourceforge.net; Mon, 26 Sep 2005 12:13:54 -0700
Received: from dew1.atmos.washington.edu ([128.95.89.41])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EJyQD-00071T-6q
	for nfs@lists.sourceforge.net; Mon, 26 Sep 2005 12:13:53 -0700
Received: from [128.95.175.151] (warren@dee.atmos.washington.edu [128.95.175.151])
	(authenticated bits=0)
	by dew1.atmos.washington.edu (8.13.4/8.13.4/Debian-3) with ESMTP id j8QJDdOO003071
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <nfs@lists.sourceforge.net>; Mon, 26 Sep 2005 12:13:40 -0700
To: nfs@lists.sourceforge.net
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

I have discovered a wierd problem with NFSv3 on linux.
I have 3 machines
machine A and B  both mount a disk D  from machine C
The options are tcp,rw,hard and intr.

Program test runs on machine A writing to D:
(fortran)
      program test
      do i=1,10
         call system("/bin/rm t")
         open (10, file='t', status='new')
         write(10,*)i
         write(6,*)i
         close(10)
         call sleep(1)
      enddo
      end

program t2 runs on machine B reading from D:
(c, but doesn't have to be)
#include <stdlib.h>
#include <fcntl.h>
main(){
  char in[80];
  int file;
  int len;

  while(1){
    file=open("t", O_RDONLY);
    len=read(file,in,79);
    in[len]='\0';
    printf("%s\n",in);
    close(file);
  }
}

while machine A is counting 1 - 10 and placing these numbers into file 
t, machine B is continually reading 1 from file t, then after a while it 
will switch to another number and read it for a while. In my first 
version of this, I was opening and rewriting the same file. In that 
version, machine B always read 1's. Now that I am creating new inodes 
all the time, it changes every few minutes while I repeatedly rerun test 
on machine A.

Now for the other interresting facts:
Reading this file from an unrelated sun during this produces the same 
result as machine B.
The same thing under NFSv4 does not do this. It works exactly as one 
would expect it to. As soon as the file is writen, the reader sees the 
new data.

Any ideas what I could have done wrong in my NFSv3 set up? Is there some 
kernel parameter that need tweaking? is there some mount option I should 
have???
Thanks.

-- 
David Warren 		INTERNET: warren@atmos.washington.edu
(206) 543-0945		Fax: (206) 543-0308
University of Washington
Dept of Atmospheric Sciences, Box 351640
Seattle, WA 98195-1640




-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
