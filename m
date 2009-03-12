From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 3/6] nfs-utils: skip getaddrinfo in
	create_auth_rpc_client unless we need port
Date: Thu, 12 Mar 2009 17:48:47 -0400
Message-ID: <20090312174847.6b96f35b@barsoom.rdu.redhat.com>
References: <1236789782-8867-1-git-send-email-jlayton@redhat.com>
	<1236789782-8867-4-git-send-email-jlayton@redhat.com>
	<7350E3A4-435F-4041-B18E-5453FB2F1B59@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <7350E3A4-435F-4041-B18E-5453FB2F1B59@oracle.com>
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

On Wed, 11 Mar 2009 18:09:11 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> > +
> > +	switch (ss->ss_family) {
> > +	case AF_INET:
> > +		if (s4->sin_port != 0) {
> > +			printerr(2, "DEBUG: port already set to %d\n",
> > +				 ntohs(s4->sin_port));
> > +			return 1;
> > +		}
> > +		if (!inet_ntop(AF_INET, &s4->sin_addr, node,
> > +				sizeof(struct sockaddr_in)))
> > +			return 0;  
> 
> I know you are copying this mostly verbatim, but I'm not sure exactly  
> what this is doing.  You can pass a C string containing the port  
> number, or a C string containing the service name, to getaddrinfo(3)  
> and have it fill in the port, I think.

This part wasn't copied...

What I'm trying to do here is skip doing a getaddrinfo if the port
number was already sent in the upcall. There appear to be 2 versions of
the info sent by the kernel in the upcall. The older one did not have a
field for the port number. For older kernels that don't have this
field, we need to look it up with getaddrinfo.

But...there's really no need to do a getaddrinfo call if we already have
a sockaddr that's ready to go, and I think that'll be the common case.

Come to think of it, we could just do this for IPv4 since we know that
all IPv6-enabled kernels will send the port. I'll have to think about
that some more...

Anyway, thanks for the review so far. I'll work on incorporating your
suggestions (particularly the ones about sockaddr vs. sockaddr_storage)
and will respin the set and resend after some more testing.

Cheers,
-- 
Jeff Layton <jlayton@redhat.com>
