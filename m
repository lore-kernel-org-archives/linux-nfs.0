From: Steve Dickson <SteveD@redhat.com>
Subject: Re: order of starting nfsd and mountd
Date: Wed, 20 Apr 2005 16:50:02 -0400
Message-ID: <4266C07A.1010403@RedHat.com>
References: <20050420145111.90658.qmail@web51610.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DOM9E-0006ok-9R
	for nfs@lists.sourceforge.net; Wed, 20 Apr 2005 13:50:12 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DOM9C-00084R-RS
	for nfs@lists.sourceforge.net; Wed, 20 Apr 2005 13:50:12 -0700
To: mehta kiran <kiranmehta1981@yahoo.com>
In-Reply-To: <20050420145111.90658.qmail@web51610.mail.yahoo.com>
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



mehta kiran wrote:
>      I tried starting rpc.mountd before nfsd and
>      when nfs restarts , client gets nfs stale handle 
>      error(RHEL4 GA 2.6.9-5.ELsmp).
>      If mountd is started after nfsd , everything
> works
>      find.
>      Why is this dependency or ordering ?
Due to the way rpc.mountd and the kernel (i.e. nfsd)
communicate. rpc.mountd need to open files under
/proc/net/rpc and if nfsd is not running, those
opens will fail.

steved.


-------------------------------------------------------
This SF.Net email is sponsored by: New Crystal Reports XI.
Version 11 adds new functionality designed to reduce time involved in
creating, integrating, and deploying reporting solutions. Free runtime info,
new features, or free trial, at: http://www.businessobjects.com/devxi/728
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
