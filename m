From: Bill Johnstone <beejstone3@yahoo.com>
Subject: Re: Configuration for NFSv3 only?
Date: Mon, 25 Jul 2005 15:35:30 -0700 (PDT)
Message-ID: <20050725223530.80613.qmail@web33915.mail.mud.yahoo.com>
References: <42E55DF9.50609@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DxBXw-0006Lz-Cz
	for nfs@lists.sourceforge.net; Mon, 25 Jul 2005 15:35:40 -0700
Received: from web33915.mail.mud.yahoo.com ([66.163.178.79])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1DxBXw-0006oh-3T
	for nfs@lists.sourceforge.net; Mon, 25 Jul 2005 15:35:40 -0700
To: Peter Staubach <staubach@redhat.com>
In-Reply-To: <42E55DF9.50609@redhat.com>
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

--- Peter Staubach <staubach@redhat.com> wrote:

> The answer to this question is that the portmapper protocol is
> completely
> separate from the NFS and related protocols such as nlockmgr and
> mountd.
>=20
> There are newer versions of the protocol, 10000, which are now called
>=20
> rpcbind.
>=20
> But, the short answer, is that portmapper, version 2, is fine for
> these=20
> purposes.

Does this separation of versions also apply to "status"?  The version
given for that both on the client and server sides is "1".

Is that OK for NFSv3 operation?

Thanks.


	=09
__________________________________=20
Do you Yahoo!?=20
Read only the mail you want - Yahoo! Mail SpamGuard.=20
http://promotions.yahoo.com/new_mail=20


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=3D7477&alloc_id=3D16492&op=3Dclic=
k
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
