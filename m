From: Steve Dickson <SteveD@redhat.com>
Subject: Re: acl_extended_file() and NFS file systems
Date: Wed, 23 Jun 2004 14:10:30 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40D9C796.6000904@RedHat.com>
References: <40D9ABC9.1070007@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BdCCk-0007Xz-LX
	for nfs@lists.sourceforge.net; Wed, 23 Jun 2004 11:10:38 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BdCCk-0003U8-8c
	for nfs@lists.sourceforge.net; Wed, 23 Jun 2004 11:10:38 -0700
To: James Pearson <james-p@moving-picture.com>
In-Reply-To: <40D9ABC9.1070007@moving-picture.com>
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

James Pearson wrote:

> We've just come across a problem with running 'ls -l' on NFS mounted 
> files from a client running Fedora Core 1 with the latest coreutils 
> RPM (5.0-34.1)
>
> Running ls -l on a file exported by a RedHat 7.2 system gives
>
> % ls -l /some/remote/file
> ls: /some/remote/file: Input/output error
> -rw-rw-r--  1 james user 17373 Jun  1 20:02 /some/remote/file

hmm... it sound like 7.2 is returning garbage but to which
over-the-wire operation? Since FC1 does not have ACL support so
the getxattr() (that is done by your test program) should
be returned EOPNOTSUPP (as it does in my testing) but instead
it sounds like the FC1 is actually trying to send something otw..
Would it be possible to get a strace and ethereal trace of this
phenomenon?

SteveD.


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
