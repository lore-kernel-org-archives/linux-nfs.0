From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 05/11] nfs-utils: declare a static common buffer for
 nfssvc.c routines
Date: Mon, 8 Jun 2009 14:30:56 -0400
Message-ID: <20090608143056.5815c152@tlielax.poochiereds.net>
References: <1244484044-21355-1-git-send-email-jlayton@redhat.com>
	<1244484044-21355-6-git-send-email-jlayton@redhat.com>
	<EBCB2BCD-7C12-4D3C-A93A-FBD4291986EC@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:51078 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751216AbZFHSbC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jun 2009 14:31:02 -0400
In-Reply-To: <EBCB2BCD-7C12-4D3C-A93A-FBD4291986EC@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 8 Jun 2009 14:22:28 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Jun 8, 2009, at 2:00 PM, Jeff Layton wrote:
> 
> > Several of the routines in nfssvc.c declare a buffer for strings.  
> > Use a
> > shared static buffer instead to keep it off of the stack. Also, the
> > buffer allocated in some places is *really* large. BUFSIZ is generally
> > 8k. These routines don't need nearly that much.
> >
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> > utils/nfsd/nfssvc.c |   28 +++++++++++++++++-----------
> > 1 files changed, 17 insertions(+), 11 deletions(-)
> >
> > diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
> > index 0a7546a..025554d 100644
> > --- a/utils/nfsd/nfssvc.c
> > +++ b/utils/nfsd/nfssvc.c
> > @@ -24,18 +24,25 @@
> > #define NFSD_VERS_FILE    "/proc/fs/nfsd/versions"
> > #define NFSD_THREAD_FILE  "/proc/fs/nfsd/threads"
> >
> > +/*
> > + * declaring a common static scratch buffer here keeps us from  
> > having to
> > + * continually thrash the stack. The value of 128 bytes here is  
> > really just a
> > + * SWAG and can be increased if necessary. It ought to be enough  
> > for the
> > + * routines below however.
> > + */
> > +char buf[128];
> > +
> > static void
> > nfssvc_setfds(int port, unsigned int ctlbits, char *haddr)
> > {
> > 	int fd, n, on=1;
> > -	char buf[BUFSIZ];
> > 	int udpfd = -1, tcpfd = -1;
> > 	struct sockaddr_in sin;
> >
> > 	fd = open(NFSD_PORTS_FILE, O_RDONLY);
> > 	if (fd < 0)
> > 		return;
> > -	n = read(fd, buf, BUFSIZ);
> > +	n = read(fd, buf, sizeof(buf));
> >
> > 	close(fd);
> > 	if (n != 0)
> > 		return;
> > @@ -91,7 +98,7 @@ nfssvc_setfds(int port, unsigned int ctlbits, char  
> > *haddr)
> > 		}
> > 	}
> > 	if (udpfd >= 0) {
> > -		snprintf(buf, BUFSIZ,"%d\n", udpfd);
> > +		snprintf(buf, sizeof(buf), "%d\n", udpfd);
> 
> Since sizeof(buf) is a SWAG, maybe we should have some way of finding  
> out if the buffer is ever overflowed. Just a thought.
> 

I don't think it's possible with the strings we're snprintf'ing into
there today. In general I'm all for bounds checking, but I don't think
it'll ever actually fire here.

It may be more of a danger for the nfssvc_versbits function, but even
there I don't think it's possible. It might be reasonable follow-on
patch though to guard against that problem for future changes.


> > 		if (write(fd, buf, strlen(buf)) != strlen(buf)) {
> > 			xlog(L_ERROR,
> > 			       "writing fds to kernel failed: errno %d (%m)",
> > @@ -103,7 +110,7 @@ nfssvc_setfds(int port, unsigned int ctlbits,  
> > char *haddr)
> > 	if (tcpfd >= 0) {
> > 		if (fd < 0)
> > 			fd = open(NFSD_PORTS_FILE, O_WRONLY);
> > -		snprintf(buf, BUFSIZ,"%d\n", tcpfd);
> > +		snprintf(buf, sizeof(buf), "%d\n", tcpfd);
> > 		if (write(fd, buf, strlen(buf)) != strlen(buf)) {
> > 			xlog(L_ERROR,
> > 			       "writing fds to kernel failed: errno %d (%m)",
> > @@ -118,7 +125,7 @@ static void
> > nfssvc_versbits(unsigned int ctlbits, int minorvers4)
> > {
> > 	int fd, n, off;
> > -	char buf[BUFSIZ], *ptr;
> > +	char *ptr;
> >
> > 	ptr = buf;
> > 	off = 0;
> > @@ -128,17 +135,17 @@ nfssvc_versbits(unsigned int ctlbits, int  
> > minorvers4)
> >
> > 	for (n = NFSD_MINVERS; n <= NFSD_MAXVERS; n++) {
> > 		if (NFSCTL_VERISSET(ctlbits, n))
> > -		    off += snprintf(ptr+off, BUFSIZ - off, "+%d ", n);
> > +		    off += snprintf(ptr+off, sizeof(buf) - off, "+%d ", n);
> > 		else
> > -		    off += snprintf(ptr+off, BUFSIZ - off, "-%d ", n);
> > +		    off += snprintf(ptr+off, sizeof(buf) - off, "-%d ", n);
> > 	}
> > 	n = minorvers4 >= 0 ? minorvers4 : -minorvers4;
> > 	if (n >= NFSD_MINMINORVERS4 && n <= NFSD_MAXMINORVERS4)
> > -		    off += snprintf(ptr+off, BUFSIZ - off, "%c4.%d",
> > +		    off += snprintf(ptr+off, sizeof(buf) - off, "%c4.%d",
> > 				    minorvers4 > 0 ? '+' : '-',
> > 				    n);
> > 	xlog(D_GENERAL, "Writing version string to kernel: %s", buf);
> > -	snprintf(ptr+off, BUFSIZ - off, "\n");
> > +	snprintf(ptr+off, sizeof(buf) - off, "\n");
> > 	if (write(fd, buf, strlen(buf)) != strlen(buf))
> > 		xlog(L_ERROR, "Setting version failed: errno %d (%m)", errno);
> >
> > @@ -168,9 +175,8 @@ nfssvc(int port, int nrservs, unsigned int  
> > versbits, int minorvers4,
> > 		 * Just write the number in.
> > 		 * Cannot handle port number yet, but does anyone care?
> > 		 */
> > -		char buf[20];
> > 		int n;
> > -		snprintf(buf, 20,"%d\n", nrservs);
> > +		snprintf(buf, sizeof(buf), "%d\n", nrservs);
> > 		n = write(fd, buf, strlen(buf));
> > 		close(fd);
> > 		if (n != strlen(buf))
> > -- 
> > 1.6.0.6
> >
> 
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 
> 
> 


-- 
Jeff Layton <jlayton@redhat.com>
