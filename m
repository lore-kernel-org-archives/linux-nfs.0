From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS file locking for clustered filesystems
Date: Tue, 10 Aug 2004 17:43:14 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1092184994.5857.19.camel@lade.trondhjem.org>
References: <Pine.LNX.4.58.0407131427580.6626@localhost.localdomain>
	 <20040802105103.GJ25023@suse.de>
	 <1091461098.3980.22.camel@lade.trondhjem.org>
	 <Pine.LNX.4.58.0408101139260.11489@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Olaf Kirch <okir@suse.de>, nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BuhDJ-0000xF-Rr
	for nfs@lists.sourceforge.net; Tue, 10 Aug 2004 17:43:33 -0700
Received: from adsl-207-214-87-84.dsl.snfc21.pacbell.net ([207.214.87.84] helo=lade.trondhjem.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1BuhDJ-0004vF-8c
	for nfs@lists.sourceforge.net; Tue, 10 Aug 2004 17:43:33 -0700
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <Pine.LNX.4.58.0408101139260.11489@localhost.localdomain>
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

P=E5 ty , 10/08/2004 klokka 17:15, skreiv Sridhar Samudrala:

> I gathered the following from your suggestions to make the cluster filesy=
stem
> process the lock/unlock calls asynchronously,
>=20
> NLM LOCK/UNLOCK Call on a file in a cluster filesystem exported from an N=
FS
> server will always respond with NLM LOCK/UNLOCK Reply with NLM_BLOCKED as=
 the
> status.

No. That would break the spec. See:
   http://www.opengroup.org/onlinepubs/9629799/NLM_LOCK.htm#tagcjh_11_11

NLM_BLOCKED is only a valid response if the client actually asked for
blocking behaviour.

In the case where the server is not able to reply in a timely fashion (I
would suggest a short timeout period of a few seconds) it should reply
with LCK_DENIED. (Note that when I talk about a "short timeout period",
I do not mean that lockd itself is allowed to block.)

> Once the cluster filesystem is done granting or denying the lock, the ser=
ver
> will send a NLM GRANTED_MSG/GRANTED_RES callbacks with the appropriate st=
atus.
>=20
> Is this correct?

See above. That is only true if the client requested a blocking lock.

> As Olaf suggested, can't we use the existing fl_notify callback instead o=
f
> setting up a new callback?

Possibly. As long as the design remains clean...

Cheers,
  Trond


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
