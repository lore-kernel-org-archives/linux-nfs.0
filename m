From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: NFS file locking for clustered filesystems
Date: Wed, 11 Aug 2004 14:35:44 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0408111155570.2546@localhost.localdomain>
References: <Pine.LNX.4.58.0407131427580.6626@localhost.localdomain>
 <20040802105103.GJ25023@suse.de>  <1091461098.3980.22.camel@lade.trondhjem.org>
  <Pine.LNX.4.58.0408101139260.11489@localhost.localdomain>
 <1092184994.5857.19.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: Olaf Kirch <okir@suse.de>, nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bv0lt-0004DA-Eo
	for nfs@lists.sourceforge.net; Wed, 11 Aug 2004 14:36:33 -0700
Received: from e34.co.us.ibm.com ([32.97.110.132])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1Bv0lt-0001L3-0I
	for nfs@lists.sourceforge.net; Wed, 11 Aug 2004 14:36:33 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1092184994.5857.19.camel@lade.trondhjem.org>
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

On Tue, 10 Aug 2004, Trond Myklebust wrote:

> P=E5 ty , 10/08/2004 klokka 17:15, skreiv Sridhar Samudrala:
>
> > I gathered the following from your suggestions to make the cluster file=
system
> > process the lock/unlock calls asynchronously,
> >
> > NLM LOCK/UNLOCK Call on a file in a cluster filesystem exported from an=
 NFS
> > server will always respond with NLM LOCK/UNLOCK Reply with NLM_BLOCKED =
as the
> > status.
>
> No. That would break the spec. See:
>    http://www.opengroup.org/onlinepubs/9629799/NLM_LOCK.htm#tagcjh_11_11
>
> NLM_BLOCKED is only a valid response if the client actually asked for
> blocking behaviour.
>
> In the case where the server is not able to reply in a timely fashion (I
> would suggest a short timeout period of a few seconds) it should reply
> with LCK_DENIED. (Note that when I talk about a "short timeout period",
> I do not mean that lockd itself is allowed to block.)

So, in the case of a client which doesn't allow blocking, are you suggestin=
g
that the cluster filesystem to return LCK_BLOCKED immediately and start the
asynchrous call and return LCK_DENIED in a few seconds if it cannot complet=
e
the operation?

But i am not sure if we can handle this easily with the current design of
lockd. As soon as the lock operation returns LCK_BLOCKED, i think svc_send(=
) is
called from svc_process() which will send a reply with NLM_BLOCKED.

Thanks
Sridhar


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
