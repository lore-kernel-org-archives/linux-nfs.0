From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: ETIMEDOUT in nfsd?
Date: Fri, 6 Aug 2004 14:20:27 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040806182027.GB465@fieldses.org>
References: <20040803081503.GM5581@sgi.com> <20040803191610.GC7781@fieldses.org> <20040804073500.GP5581@sgi.com> <20040804141346.GA19282@fieldses.org> <20040805022608.GR5581@sgi.com> <20040805142159.GB25948@fieldses.org> <20040806005050.GX5581@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bt9KV-00041d-Jc
	for nfs@lists.sourceforge.net; Fri, 06 Aug 2004 11:20:35 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1Bt9KV-0004iJ-4v
	for nfs@lists.sourceforge.net; Fri, 06 Aug 2004 11:20:35 -0700
To: Greg Banks <gnb@sgi.com>
In-Reply-To: <20040806005050.GX5581@sgi.com>
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

On Fri, Aug 06, 2004 at 10:50:50AM +1000, Greg Banks wrote:
> Perhaps I misunderstood your sentence...did you instead mean the
> assumption is that nothing non-idempotent happens *between* when the
> cache is missed and an upcall enqueued, and when the upcall completes?
> I was thinking something different...

No, the problem is just that you can't, as part of processing a single
request, perform, for example, a mkdir followed by a cache lookup that
might result in deferring and revisiting the request, because the wrong
thing will happen when you revisit the request.

With v2/v3, requests are simple enough that this shouldn't be a problem.

But this is a bit harder to avoid when processing a v4 compound.

--Bruce Fields


-------------------------------------------------------
This SF.Net email is sponsored by OSTG. Have you noticed the changes on
Linux.com, ITManagersJournal and NewsForge in the past few weeks? Now,
one more big change to announce. We are now OSTG- Open Source Technology
Group. Come see the changes on the new OSTG site. www.ostg.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
