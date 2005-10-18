From: Peter Staubach <staubach@redhat.com>
Subject: Re: historical question: nfs_rename()
Date: Tue, 18 Oct 2005 14:03:01 -0400
Message-ID: <435538D5.7080202@redhat.com>
References: <044B81DE141D7443BCE91E8F44B3C1E288E579@exsvl02.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ERvns-0006kg-Lx
	for nfs@lists.sourceforge.net; Tue, 18 Oct 2005 11:03:12 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1ERvnp-00037I-VS
	for nfs@lists.sourceforge.net; Tue, 18 Oct 2005 11:03:12 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <044B81DE141D7443BCE91E8F44B3C1E288E579@exsvl02.hq.netapp.com>
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

>>Actually, this case should fail with EISDIR, as it does.  Mixing
>>directory and files in a rename(2) will fail with EISDIR or ENOTDIR.
>>
>>However, renaming one directory to another directory, when the target
>>directory is "empty", should not fail.
>>    
>>
>
>the specific case i'm whining about today is renaming a directory to an
>empty directory.  the desired semantic is that the empty directory will
>be replaced.  the existing semantic on the Linux NFS client is that
>rename(2) returns -EBUSY.
>
>as far as we can tell, the Solaris client works as desired.  the issue
>is a portability problem that arises because Linux's rename(2) doesn't
>work precisely the same way as Solaris'.
>  
>
I think that this is actually a POSIX/SUS3 thing...

    Thanx...

       ps


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
