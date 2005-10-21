From: "Weathers, Norman R." <Norman.R.Weathers@conocophillips.com>
Subject: RE: Issue with parallel writes over NFS
Date: Fri, 21 Oct 2005 11:08:00 -0500
Message-ID: <D821697F08061F4FBB069FA1AAAA92370C4649@hoexmb7.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ESzRI-00064U-ST
	for nfs@lists.sourceforge.net; Fri, 21 Oct 2005 09:08:16 -0700
Received: from mailman1.ppco.com ([138.32.33.10])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44)
	id 1ESzRE-0006lu-9D
	for nfs@lists.sourceforge.net; Fri, 21 Oct 2005 09:08:13 -0700
Received: from bvlextrd03.conoco.net (bvlextrd03.conoco.net [138.32.33.146])
	by mailman1.ppco.com (Switch-3.1.7/Switch-3.1.7) with ESMTP id j9LG82aN016586
	for <nfs@lists.sourceforge.net>; Fri, 21 Oct 2005 11:08:02 -0500
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
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

Thanks for the pointer.  We think that the application may be
able to do this.  Just for reference of mind, when you are saying
page align block writes, are you meaning basically the page size
of the vm (in this case, Opteron boxes running 64 bit FC3, which I
am hoping is still 4k)?

Thanks again.

Norman Weathers
Linux System Admin

-----Original Message-----
From: Trond Myklebust [mailto:trond.myklebust@fys.uio.no]=20
Sent: Thursday, October 20, 2005 4:16 PM
To: Weathers, Norman R.
Cc: nfs@lists.sourceforge.net
Subject: Re: [NFS] Issue with parallel writes over NFS


to den 20.10.2005 klokka 14:25 (-0500) skreiv Weathers, Norman R.:
> The strange thing is that this exact same code, test and actual
> application, run extremely well behaved on
> linux 2.4 kernel based distro's, and it doesn't seem to care if the
code
> uses multiples of 4k or some other
> multiple, or something off the wall like 24000 bytes.

Yes. In the interest of better performance for standard buffered I/O,
we've moved towards a model where we page align block writes in the case
where the user is not locking or using direct I/O. This improves the
ability of the client to coagulate pages into r/wsized blocks.

Can you move the application over to using direct I/O? It sounds to me
as if this is pretty much what you want to be using in this environment
anyway. Note that unlike the case of 2.4.x kernels, the NFS direct I/O
implementation in 2.6.x does not have any page or block alignment
requirements.

Cheers,
 Trond



-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
