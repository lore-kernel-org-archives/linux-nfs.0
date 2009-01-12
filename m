From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: nfs client lockdep warning
Date: Mon, 12 Jan 2009 13:02:11 +0100
Message-ID: <1231761731.4371.7.camel@laptop>
References: <20090108203658.GE19312@fieldses.org>
	 <1231447707.7179.10.camel@heimdal.trondhjem.org>
	 <20090108212056.GF19312@fieldses.org>
	 <20090109043315.GA12139@gondor.apana.org.au>
	 <1231480697.11687.522.camel@twins>
	 <20090109062333.GB13304@gondor.apana.org.au>
	 <1231483868.11687.523.camel@twins>  <20090109202939.GA5466@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	linux-nfs@vger.kernel.org, Trond Myklebust <trond@netapp.com>,
	Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20090109202939.GA5466@fieldses.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-01-09 at 15:29 -0500, J. Bruce Fields wrote:

> > > > Is there anything pinning that user-space page, if not its free to
> > > > fault, which would mean its a real warning... 
> > > 
> > > It's kernel memory, not user memory.  See xs_udp_send_request in
> > > net/sunrpc.

> > ---
> > diff --git a/mm/memory.c b/mm/memory.c
> > index 7b9db65..a2ed52e 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -3079,6 +3079,9 @@ void print_vma_addr(char *prefix, unsigned long ip)
> >  #ifdef CONFIG_PROVE_LOCKING
> >  void might_fault(void)
> >  {
> > +	if (get_fs() == KERNEL_DS)
> 
> Looks like that should be
> 
> 	if ((segment_eq(get_fs(), KERNEL_DS))
> 
> ?  Anyway, with that, sure, that eliminates the lockdep warning.

Right, thanks!

---
Subject: lockdep,mm: fix might_fault() annotation

Some code (nfs/sunrpc) uses socket ops on kernel memory while holding
the mmap_sem, this is safe because kernel memory doesn't get paged out,
therefore we'll never actually fault, and the might_fault() annotations
will generate false positives.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 mm/memory.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index e009ce8..c2d4c47 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3165,6 +3165,15 @@ void print_vma_addr(char *prefix, unsigned long ip)
 #ifdef CONFIG_PROVE_LOCKING
 void might_fault(void)
 {
+	/*
+	 * Some code (nfs/sunrpc) uses socket ops on kernel memory while
+	 * holding the mmap_sem, this is safe because kernel memory doesn't
+	 * get paged out, therefore we'll never actually fault, and the
+	 * below annotations will generate false positives.
+	 */
+	if (segment_eq(get_fs(), KERNEL_DS))
+		return;
+
 	might_sleep();
 	/*
 	 * it would be nicer only to annotate paths which are not under


