From: Fabio Olive Leite <fleite@redhat.com>
Subject: Re: time_after cannot be used alone by NFS code	in
	32bit	architectures
Date: Tue, 8 May 2007 14:09:07 -0300
Message-ID: <20070508170907.GA32335@sleipnir.redhat.com>
References: <20070426043344.GO10449@sleipnir.redhat.com>
	<1178106770.5960.28.camel@raven.themaw.net>
	<1178591824.3918.10.camel@raven.themaw.net>
	<17984.5736.617053.65429@notabene.brown>
	<1178627674.25317.2.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
To: linux-nfs <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HlTBZ-0004Cp-8W
	for nfs@lists.sourceforge.net; Tue, 08 May 2007 10:09:13 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HlTBa-0005xr-MW
	for nfs@lists.sourceforge.net; Tue, 08 May 2007 10:09:16 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l48H98Ud018695
	for <nfs@lists.sourceforge.net>; Tue, 8 May 2007 13:09:08 -0400
Received: from pobox-2.corp.redhat.com (pobox-2.corp.redhat.com [10.11.255.15])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l48H98f9017214
	for <nfs@lists.sourceforge.net>; Tue, 8 May 2007 13:09:08 -0400
Received: from sleipnir.redhat.com (vpn-14-126.rdu.redhat.com [10.11.14.126])
	by pobox-2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id
	l48H96Mj024753
	for <nfs@lists.sourceforge.net>; Tue, 8 May 2007 13:09:07 -0400
Received: from sleipnir.redhat.com (localhost.localdomain [127.0.0.1])
	by sleipnir.redhat.com (8.13.8/8.13.7) with ESMTP id l48H98Gi016062
	for <nfs@lists.sourceforge.net>; Tue, 8 May 2007 14:09:09 -0300
Received: (from fleite@localhost)
	by sleipnir.redhat.com (8.13.8/8.13.8/Submit) id l48H98C6016061
	for nfs@lists.sourceforge.net; Tue, 8 May 2007 14:09:08 -0300
In-Reply-To: <1178627674.25317.2.camel@heimdal.trondhjem.org>
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

On Tue, May 08, 2007 at 08:34:34AM -0400, Trond Myklebust wrote:
> =

>     dentry verifiers are always set to the parent directory's
>     cache_change_attribute. There is no reason to be testing for
>     anything other than equality when we're trying to find out if
>     the dentry has been checked since the last time the directory
>     was modified.

I think this is exactly the simple fix I was trying to get at, but
couldn't see. Thanks a real lot for taking care of it.

Now, if anyone wants to argument the 1 in 2^32 chance of hitting the
correct millisecond 50 days after the current update... =3D) joking!

Thanks,
F=E1bio
-- =

ex sed lex awk yacc, e pluribus unix, amem

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
