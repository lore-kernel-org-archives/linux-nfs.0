From: Peter Staubach <staubach@redhat.com>
Subject: Re: historical question: nfs_rename()
Date: Mon, 17 Oct 2005 15:18:56 -0400
Message-ID: <4353F920.4070408@redhat.com>
References: <044B81DE141D7443BCE91E8F44B3C1E288E56A@exsvl02.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ERaVs-00039r-Bc
	for nfs@lists.sourceforge.net; Mon, 17 Oct 2005 12:19:12 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1ERaVq-0006K3-V4
	for nfs@lists.sourceforge.net; Mon, 17 Oct 2005 12:19:12 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <044B81DE141D7443BCE91E8F44B3C1E288E56A@exsvl02.hq.netapp.com>
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

Lever, Charles wrote:

>a customer recently pointed out that the rename(2) system call does not
>allow replacing directories, even if they are empty.  RFC1813 at least
>suggests that the server and protocol do allow directory replacement, as
>long as the target is empty.
>
>the culprit appears to be this check in nfs_rename()
>
>        if (S_ISDIR(new_inode->i_mode))
>                goto out;
>
>which causes nfs_rename() to return -EBUSY if the target is a directory.
>
>is there a historical reason why the Linux NFS client does not allow
>directory replacement?  shouldn't the error code be -EISDIR for this
>case?
>

Assuming that the client can handle this situation by ensuring that all
of its caches stay updated, then it seems to me that the client should
just package up the rename and send it off to the server.  It should be
up to the server to decide whether it can handle directory renames of
this type or not.

    Thanx...

       ps


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
