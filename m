From: Peter Staubach <staubach@redhat.com>
Subject: Re: NFS and C Language
Date: Fri, 09 Dec 2005 09:10:48 -0500
Message-ID: <43999068.3080500@redhat.com>
References: <ADEFIEOLGCCFDKBLPHKEIEEJCDAA.e_rln@yahoo.co.in> <200512091231.26341.vincent.roqueta@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net, RLN <e_rln@yahoo.co.in>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ekixg-0006tP-6O
	for nfs@lists.sourceforge.net; Fri, 09 Dec 2005 06:11:00 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Ekixd-0006RB-OM
	for nfs@lists.sourceforge.net; Fri, 09 Dec 2005 06:11:00 -0800
To: Vincent Roqueta <vincent.roqueta@ext.bull.net>
In-Reply-To: <200512091231.26341.vincent.roqueta@ext.bull.net>
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

Vincent Roqueta wrote:

>Le Vendredi 09 D=E9cembre 2005 12:12, RLN a =E9crit :
> =20
>
>>Hi!
>>
>>
>>I want to write simple C language program to read and write a file in N=
FS
>>file system.
>>
>>Please give a link or advice to write a program using C language.
>>
>>Also help for which calls I have to use.
>>   =20
>>
>You access NFS as other file systems...
>Generic C howto about files manipulations works for NFS.
>
>Vincent
>
>
>_______________________
>#include <stdio.h>
>#include <string.h>
>#include <sys/types.h>
>#include <sys/stat.h>
>#include <fcntl.h>
>
>
>int main(int argc, char **argv){
>    char path[]=3D"/path/to/the/testfile";
>    char string[]=3D"hello world!";
>    int fd;
>
>    fd=3Dopen(path,O_WRONLY|O_CREAT);
>    if(fd<0){
>        perror("Open");
>        return 0;
>    }
>    write(fd, string,strlen(string));
>    return 0;
>}
>

Actually, this little program may or may not work on an NFS mounted file
system.  It contains a bug in that the open(2) system call takes three
arguments and the third, the mode, is used when O_CREAT is specified and
the file does not already exist.  If the random bits, which the kernel
uses because the mode was not actually specified, are wrong, like for
example require mandatory locking, then the write(2) call may fail.
Also, the write(2) call returns whether or not it succeeded and how much
data was written.  The close(2) call, which was not explicitly coded,
but should have been, is also used to return whether any error occurred
while trying to write data to the NFS server.

    Thanx...

       ps


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
