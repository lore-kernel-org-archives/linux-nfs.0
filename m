From: "Bill Rugolsky Jr." <brugolsky@telemetry-investments.com>
Subject: Re: nfsd re-export
Date: Wed, 24 Sep 2003 07:49:47 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030924114947.GA15214@ti19>
References: <3F706D2F.90204@iut.univ-paris8.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A28AA-0006h2-00
	for <nfs@lists.sourceforge.net>; Wed, 24 Sep 2003 04:50:30 -0700
Received: from 209-166-240-202.cust.walrus.com ([209.166.240.202] helo=ti3.telemetry-investments.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A28A9-0002sP-IM
	for nfs@lists.sourceforge.net; Wed, 24 Sep 2003 04:50:29 -0700
Received: from ti19.telemetry-investments.com (ti19 [192.168.8.19])
	by ti3.telemetry-investments.com (8.11.6/8.11.6) with ESMTP id h8OBnqt12572
	for <nfs@lists.sourceforge.net>; Wed, 24 Sep 2003 07:49:52 -0400
To: Yahya AZZOUZ <y.azzouz@iut.univ-paris8.fr>
In-Reply-To: <3F706D2F.90204@iut.univ-paris8.fr>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Tue, Sep 23, 2003 at 05:56:31PM +0200, Yahya AZZOUZ wrote:
> i want to re-export a nfs file system.
> I don't know if it is possible.
> Some idies !

Generally not a good idea, but if you insist, you might
want to try UNFS3, a user-space NFSv3 server implementation
that is actively being developed:

    http://unfs3.sourceforge.net/

When using a user-space NFS server, one should avoid
modifying the exported filesystem(s) on the fileserver
by directly accessing the local mount (especially directory
renames, etc.).  Doing so is likely to confuse the NFS server
and its clients.

Regards,

	Bill Rugolsky


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
