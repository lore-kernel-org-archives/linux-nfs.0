From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS file locking for clustered filesystems
Date: Wed, 11 Aug 2004 22:34:45 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1092288885.4079.40.camel@lade.trondhjem.org>
References: <Pine.LNX.4.58.0407131427580.6626@localhost.localdomain>
	 <20040802105103.GJ25023@suse.de>
	 <1091461098.3980.22.camel@lade.trondhjem.org>
	 <Pine.LNX.4.58.0408101139260.11489@localhost.localdomain>
	 <1092184994.5857.19.camel@lade.trondhjem.org>
	 <Pine.LNX.4.58.0408111155570.2546@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Olaf Kirch <okir@suse.de>, nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bv8Fl-0008Jn-3A
	for nfs@lists.sourceforge.net; Wed, 11 Aug 2004 22:35:53 -0700
Received: from adsl-207-214-87-84.dsl.snfc21.pacbell.net ([207.214.87.84] helo=lade.trondhjem.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1Bv8Fj-0004V1-CW
	for nfs@lists.sourceforge.net; Wed, 11 Aug 2004 22:35:53 -0700
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <Pine.LNX.4.58.0408111155570.2546@localhost.localdomain>
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

P=E5 on , 11/08/2004 klokka 14:35, skreiv Sridhar Samudrala:

> So, in the case of a client which doesn't allow blocking, are you suggest=
ing
> that the cluster filesystem to return LCK_BLOCKED immediately and start t=
he
> asynchrous call and return LCK_DENIED in a few seconds if it cannot compl=
ete
> the operation?

Sort of.

Firstly, having the filesystem return NLM-specific errors is a no-no.
Lets keep the errors generic (-EAGAIN =3D=3D -EWOULDBLOCK for instance.)
NFSv4 does not understand LCK_BLOCKED.

Secondly, I suggest that lockd should manage its timeouts itself rather
than relying on the clustered filesystem to do so. Timers are cheap...

> But i am not sure if we can handle this easily with the current design of
> lockd. As soon as the lock operation returns LCK_BLOCKED, i think svc_sen=
d() is
> called from svc_process() which will send a reply with NLM_BLOCKED.

For NFSv4 this is not a problem: NFS4ERR_DELAY will make the client back
off and retry the request later.

For NLM, you are clearly going to have to figure out a way around the
above problem. (but that's why you get paid the big bucks right? ;-))
Note that the sunrpc server code already has a mechanism for deferring
requests when dealing with blocking behaviour (in case it needs to do an
upcall) and then replaying them later. Perhaps you could look into
reusing that here?

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
