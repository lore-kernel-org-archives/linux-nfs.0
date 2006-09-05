From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH 016 of 19] knfsd: match GRANTED_RES replies
	using	cookies
Date: Tue, 5 Sep 2006 19:39:40 +0200
Message-ID: <20060905173940.GA12578@suse.de>
References: <20060901141639.27206.patches@notabene>
	<1060901043932.27641@suse.de> <1157126618.5632.52.camel@localhost>
	<20060904090939.GC28400@suse.de>
	<1157472751.8238.4.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NeilBrown <neilb@suse.de>, Andrew Morton <akpm@osdl.org>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GKetk-0004mU-5D
	for nfs@lists.sourceforge.net; Tue, 05 Sep 2006 10:39:44 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GKetk-0003pc-Nj
	for nfs@lists.sourceforge.net; Tue, 05 Sep 2006 10:39:45 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1157472751.8238.4.camel@localhost>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Tue, Sep 05, 2006 at 12:12:30PM -0400, Trond Myklebust wrote:
> Right. The question is how many clients out there do still rely on the
> current behaviour?

Right. I know that old SunOS releases did, as did HPUX-6.5 or whatever
it was. But that was ages ago.

Suse has had this code change for a while now in SL10.1 (6 months) as
well as SLES10, and I haven't heard of any interoperability problems,
neither from partners or users, nor from our own QA.

> Looking at Brent's 'NFS Illustrated', I see that he notes that for
> NLM_GRANTED, the cookie is "An opaque value that is normally the same as
> the client sent in the LOCK request, though the client cannot depend on
> it". Which sounds like weasel words for "some clients still do depend on
> it".

The spec says the same (except it doesn't mention that the cookie is
"normally the same", it just explicitly states that the client must not
rely on the cookie in the GRANT call being the same as the one in the
LOCK call).

My guess is that this was an implementation "shortcut" in the original
Sun code that metastased into all the derived implementations, and when
they discovered it was a bad bug that could lead to lock mix-up, this
sloppiness had spread all over the Unix landscape and they needed to
put stern words into the standard...

In summary, I think more than 10 years after the publication of the
X/Open NLM spec it is acceptable to remove that kludge.

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
