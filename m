From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 5/5] nfs-utils: add IPv6 code to gssd
Date: Mon, 6 Apr 2009 12:24:09 -0400
Message-ID: <20090406122409.192523d2@tleilax.poochiereds.net>
References: <1238938983-7347-1-git-send-email-jlayton@redhat.com>
	<1238938983-7347-6-git-send-email-jlayton@redhat.com>
	<BCFA87B8-22EA-4ABB-87B5-38DAB2621579@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <BCFA87B8-22EA-4ABB-87B5-38DAB2621579@oracle.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 6 Apr 2009 11:35:21 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> On Apr 5, 2009, at 9:43 AM, Jeff Layton wrote:
> > All of the pieces to handle IPv6 are now in place. Add IPv6-specific
> > code wrapped in the proper #ifdef's so that IPv6 support works when
> > it's enabled at build-time.
> >
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> > utils/gssd/gssd_proc.c |   34 ++++++++++++++++++++++++++++++++++
> > 1 files changed, 34 insertions(+), 0 deletions(-)
> >
> > diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> > index 1f7dadd..8a595c2 100644
> > --- a/utils/gssd/gssd_proc.c
> > +++ b/utils/gssd/gssd_proc.c
> > @@ -111,10 +111,18 @@ static int
> > addrstr_to_sockaddr(struct sockaddr *sa, const char *addr, const int  
> > port)
> > {
> > 	struct sockaddr_in	*s4 = (struct sockaddr_in *) sa;
> > +#ifdef IPV6_SUPPORTED
> > +	struct sockaddr_in6	*s6 = (struct sockaddr_in6 *) sa;
> > +#endif /* IPV6_SUPPORTED */
> >
> > 	if (inet_pton(AF_INET, addr, &s4->sin_addr)) {
> > 		s4->sin_family = AF_INET;
> > 		s4->sin_port = htons(port);
> > +#ifdef IPV6_SUPPORTED
> > +	} else if (inet_pton(AF_INET6, addr, &s6->sin6_addr)) {
> > +		s6->sin6_family = AF_INET6;
> > +		s6->sin6_port = htons(port);
> > +#endif /* IPV6_SUPPORTED */
> 
> Does this support scope IDs?  Do we expect to get a link-local IPv6  
> address here?
> 

It doesn't support scope ID's. The upcall doesn't send the scopeid if
there's one defined.

Given that we rely on name resolution to some degree with krb5 auth,
I'm not sure that it makes much sense to deal with scopeid's here. AAAA
records in DNS don't have space for them.

PS: I'll fix the getnameinfo() autoconf patch to do what you suggest...

-- 
Jeff Layton <jlayton@redhat.com>
