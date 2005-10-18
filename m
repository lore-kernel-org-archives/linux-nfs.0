From: Peter Staubach <staubach@redhat.com>
Subject: Re: historical question: nfs_rename()
Date: Tue, 18 Oct 2005 12:57:18 -0400
Message-ID: <4355296E.4020606@redhat.com>
References: <044B81DE141D7443BCE91E8F44B3C1E288E56A@exsvl02.hq.netapp.com> <1129651829.8989.17.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "Lever, Charles" <Charles.Lever@netapp.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ERumP-0003OI-KT
	for nfs@lists.sourceforge.net; Tue, 18 Oct 2005 09:57:37 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1ERumP-0001F9-GU
	for nfs@lists.sourceforge.net; Tue, 18 Oct 2005 09:57:37 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1129651829.8989.17.camel@lade.trondhjem.org>
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

Trond Myklebust wrote:

>m=E5 den 17.10.2005 klokka 12:12 (-0700) skreiv Lever, Charles:
> =20
>
>>a customer recently pointed out that the rename(2) system call does not
>>allow replacing directories, even if they are empty.  RFC1813 at least
>>suggests that the server and protocol do allow directory replacement, a=
s
>>long as the target is empty.
>>
>>the culprit appears to be this check in nfs_rename()
>>
>>        if (S_ISDIR(new_inode->i_mode))
>>                goto out;
>>
>>which causes nfs_rename() to return -EBUSY if the target is a directory.
>>
>>is there a historical reason why the Linux NFS client does not allow
>>directory replacement?  shouldn't the error code be -EISDIR for this
>>case?
>>   =20
>>
>
>Yes, the error should be EISDIR. I'm not sure that I agree with your
>assertion that rename failing is an NFS-only issue, though. The attached
>testcase fails on both XFS and ext3 too with the error "Rename failed:
>Is a directory".
>
>Cheers,
>  Trond
>
> =20
>
>------------------------------------------------------------------------
>
>#include <sys/types.h>
>#include <sys/stat.h>
>#include <fcntl.h>
>#include <stdio.h>
>#include <stdlib.h>
>
>#define FILENAME "gnurr"
>#define DIRNAME "gnarg"
>
>void die(char *errmsg)
>{
>	perror(errmsg);
>	exit(1);
>}
>
>int main()
>{
>	int fd;
>	int err;
>
>	fd =3D open(FILENAME, O_CREAT|O_EXCL|O_RDWR, 0644);
>	if (fd < 0)
>		die("File creation failed");
>	close(fd);
>	err =3D mkdir(DIRNAME, 0700);
>	if (err !=3D 0)
>		die("Directory creation failed");
>	err =3D rename("gnurr", "gnarg");
>	if (err !=3D 0)
>		die("Rename failed");
>}
> =20
>

Actually, this case should fail with EISDIR, as it does.  Mixing
directory and files in a rename(2) will fail with EISDIR or ENOTDIR.

However, renaming one directory to another directory, when the target
directory is "empty", should not fail.

       ps


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
