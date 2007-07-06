From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 'noacl' NFS parameter seems ineffective (Fedora Core 7)
Date: Fri, 06 Jul 2007 10:27:46 -0400
Message-ID: <1183732066.6463.44.camel@heimdal.trondhjem.org>
References: <a90f74cc0707051401p38167340s955be299a807710d@mail.gmail.com>
	<468D6064.3080307@redhat.com>
	<1183728245.6463.17.camel@heimdal.trondhjem.org>
	<468E4659.8090209@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Peter Staubach <staubach@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I6omj-0003Cl-33
	for nfs@lists.sourceforge.net; Fri, 06 Jul 2007 07:27:49 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX19dXEz4fbRW4txE9an8eJvLVLhGIOt5igc=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I6omm-0006Kw-5k
	for nfs@lists.sourceforge.net; Fri, 06 Jul 2007 07:27:52 -0700
In-Reply-To: <468E4659.8090209@redhat.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Fri, 2007-07-06 at 09:40 -0400, Peter Staubach wrote:
> It was misguided on someone's part to think that no ACLs meant that
> checking the mode bits for permissions was sufficient.

Yup. The correct way to deal with the problem of too many ACCESS calls
was rather to improve the caching. There should be a vast difference
between a 2.6.19 kernel or higher and earlier versions when it comes to
the ability to cache credentials from multiple users and I hope that
addresses the problems that people were seeing.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
