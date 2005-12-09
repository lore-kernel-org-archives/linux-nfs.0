From: Vincent Roqueta <vincent.roqueta@ext.bull.net>
Subject: Re: NFS and C Language
Date: Fri, 9 Dec 2005 12:31:26 +0100
Message-ID: <200512091231.26341.vincent.roqueta@ext.bull.net>
References: <ADEFIEOLGCCFDKBLPHKEIEEJCDAA.e_rln@yahoo.co.in>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: "RLN" <e_rln@yahoo.co.in>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EkgQw-0001ON-Q1
	for nfs@lists.sourceforge.net; Fri, 09 Dec 2005 03:29:02 -0800
Received: from ecfrec.frec.bull.fr ([129.183.4.8])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EkgQt-0005DD-RK
	for nfs@lists.sourceforge.net; Fri, 09 Dec 2005 03:29:02 -0800
To: nfs@lists.sourceforge.net
In-Reply-To: <ADEFIEOLGCCFDKBLPHKEIEEJCDAA.e_rln@yahoo.co.in>
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

Le Vendredi 09 D=E9cembre 2005 12:12, RLN a =E9crit=A0:
> Hi!
>
>
> I want to write simple C language program to read and write a file in NFS
> file system.
>
> Please give a link or advice to write a program using C language.
>
> Also help for which calls I have to use.
You access NFS as other file systems...
Generic C howto about files manipulations works for NFS.

Vincent


_______________________
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>


int main(int argc, char **argv){
    char path[]=3D"/path/to/the/testfile";
    char string[]=3D"hello world!";
    int fd;

    fd=3Dopen(path,O_WRONLY|O_CREAT);
    if(fd<0){
        perror("Open");
        return 0;
    }
    write(fd, string,strlen(string));
    return 0;
}



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
