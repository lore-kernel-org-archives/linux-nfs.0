From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] sunrpc: on successful gss error pipe write, don't
	return error
Date: Fri, 18 Dec 2009 14:33:37 -0500
Message-ID: <1261164817.3420.23.camel@localhost>
References: <1261144574-1642-1-git-send-email-jlayton@redhat.com>
	<1261145468.3229.7.camel@localhost>
	<20091218093912.1c426ad6@tlielax.poochiereds.net>
	<1261147672.3229.14.camel@localhost>
	<20091218102550.6a48c900@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20091218102550.6a48c900@tlielax.poochiereds.net>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-12-18 at 10:25 -0500, Jeff Layton wrote: 
> On Fri, 18 Dec 2009 09:47:52 -0500
> Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> 
> > On Fri, 2009-12-18 at 09:39 -0500, Jeff Layton wrote: 
> > > Yeah, we could do that with the existing code. I sort of don't like
> > > that because it's hard to know if other functions could eventually
> > > return an EACCES for another reason and then that error would bubble up
> > > to this function. If you think it's the right thing to do though, I'm
> > > OK with it.
> > 
> > The error EACCES means 'you are not authorised'. I don't see how it can
> > be ambiguous here.
> > 
> 
> I guess I was thinking that the pipe writer might not be authorized to
> import the sec context for some reason, which would be a different
> situation. If that'll never be the case, then a single error code is
> probably fine. I'll respin it to just special case EACCES for now and
> will plan to have it special case the other error when that work is
> more fleshed out.
> 
> > > FWIW: The reason I'm poking around in here is because I'm taking a stab
> > > at fixing the problem where syscalls start returning errors when a krb5
> > > ticket expires.
> > > 
> > > As part of that, I want to have gssd send a more granular error code
> > > and have the kernel adjust what it does accordingly. I'd like to have
> > > it retry the upcall indefinitely when there's an expired credcache, and
> > > return an error when there's no credcache at all).
> > 
> > That makes sense.
> > 
> > > Without a separate downcall error field, we'll need to special case at
> > > least 2 different errors -- one for a "real" EACCES and one that
> > > indicates that the ticket expired and the upcall should be retried
> > > instead.
> > 
> > We can find another error for the 'ticket expired' case. EKEYEXPIRED
> > springs to mind...
> > 
> 
> That's exactly the error I was going to use.
> 
> > > > BTW: while looking at this, I spotted a nasty bug in
> > > > gss_import_sec_context_kerberos(). If the kzalloc() call fails, we will
> > > > return a random error code since 'p' still points to a valid memory
> > > > location...
> > > 
> > > Good catch. Do you want fix that one, or should I?
> > > 
> > 
> > I can do it, if you like.
> > 
> 
> Sure. I see another problem in this area too. gss_import_sec_context
> can return GSS_S_FAILURE which is unsigned and positive when cast to a
> signed value. gss_import_sec_context checks for a negative return from
> that function though. Should it be checking for non-zero instead?
> 

No. All the other functions there return ENOMEM on memory allocation
failure. The GSS_S_FAILURE is just wrong.


-------------------------------------------------------------------------------------------- 
SUNRPC: Fix the return value in gss_import_sec_context()

From: Trond Myklebust <Trond.Myklebust@netapp.com>

If the context allocation fails, it will return GSS_S_FAILURE, which is
neither a valid error code, nor is it even negative.

Return ENOMEM instead...

Reported-by: Jeff Layton <jlayton@redhat.com>
Cc: stable@kernel.org
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/auth_gss/gss_mech_switch.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)


diff --git a/net/sunrpc/auth_gss/gss_mech_switch.c b/net/sunrpc/auth_gss/gss_mech_switch.c
index 6efbb0c..76e4c6f 100644
--- a/net/sunrpc/auth_gss/gss_mech_switch.c
+++ b/net/sunrpc/auth_gss/gss_mech_switch.c
@@ -252,7 +252,7 @@ gss_import_sec_context(const void *input_token, size_t bufsize,
 		       struct gss_ctx		**ctx_id)
 {
 	if (!(*ctx_id = kzalloc(sizeof(**ctx_id), GFP_KERNEL)))
-		return GSS_S_FAILURE;
+		return -ENOMEM;
 	(*ctx_id)->mech_type = gss_mech_get(mech);
 
 	return mech->gm_ops
