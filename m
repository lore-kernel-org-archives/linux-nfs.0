From: Vincent Roqueta <vincent.roqueta@ext.bull.net>
Subject: Re: NFS and C Language
Date: Fri, 9 Dec 2005 15:24:39 +0100
Message-ID: <200512091524.39616.vincent.roqueta@ext.bull.net>
References: <ADEFIEOLGCCFDKBLPHKEIEEJCDAA.e_rln@yahoo.co.in> <200512091231.26341.vincent.roqueta@ext.bull.net> <43999068.3080500@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ekj9z-0007t4-FB
	for nfs@lists.sourceforge.net; Fri, 09 Dec 2005 06:23:43 -0800
Received: from ecfrec.frec.bull.fr ([129.183.4.8])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Ekj9v-0002gl-Pd
	for nfs@lists.sourceforge.net; Fri, 09 Dec 2005 06:23:43 -0800
Received: from localhost (localhost [127.0.0.1])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id 9625019D918
	for <nfs@lists.sourceforge.net>; Fri,  9 Dec 2005 15:22:57 +0100 (CET)
Received: from ecfrec.frec.bull.fr ([127.0.0.1])
 by localhost (ecfrec.frec.bull.fr [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 10422-02 for <nfs@lists.sourceforge.net>;
 Fri,  9 Dec 2005 15:22:55 +0100 (CET)
Received: from ecn002.frec.bull.fr (ecn002.frec.bull.fr [129.183.4.6])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id 7AB4019D907
	for <nfs@lists.sourceforge.net>; Fri,  9 Dec 2005 15:22:55 +0100 (CET)
To: nfs@lists.sourceforge.net
In-Reply-To: <43999068.3080500@redhat.com>
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

Le Vendredi 09 D=E9cembre 2005 15:10, Peter Staubach a =E9crit=A0:
> Vincent Roqueta wrote:
> >Le Vendredi 09 D=E9cembre 2005 12:12, RLN a =E9crit :
> >>Hi!
> >>
> >>
> >>I want to write simple C language program to read and write a file in N=
=46S
> >>file system.
> >>
> >>Please give a link or advice to write a program using C language.
> >>
> >>Also help for which calls I have to use.
> >
> >You access NFS as other file systems...
> >Generic C howto about files manipulations works for NFS.
> >
> >Vincent
> >
> >
> >_______________________
> >#include <stdio.h>
> >#include <string.h>
> >#include <sys/types.h>
> >#include <sys/stat.h>
> >#include <fcntl.h>
> >
> >
> >int main(int argc, char **argv){
> >    char path[]=3D"/path/to/the/testfile";
> >    char string[]=3D"hello world!";
> >    int fd;
> >
> >    fd=3Dopen(path,O_WRONLY|O_CREAT);
> >    if(fd<0){
> >        perror("Open");
> >        return 0;
> >    }
> >    write(fd, string,strlen(string));
> >    return 0;
> >}
>
> Actually, this little program may or may not work on an NFS mounted file
> system.  It contains a bug in that the open(2) system call takes three
> arguments and the third, the mode, is used when O_CREAT is specified and
> the file does not already exist.  If the random bits, which the kernel
> uses because the mode was not actually specified, are wrong, like for
> example require mandatory locking, then the write(2) call may fail.
> Also, the write(2) call returns whether or not it succeeded and how much
> data was written.  The close(2) call, which was not explicitly coded,
> but should have been, is also used to return whether any error occurred
> while trying to write data to the NFS server.
Right...
You can add I return 0 even if the program fails...

I have taken a little less than 3 minutes to write this little example :)
I hope C howto examples will be better :)

Vincent


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
