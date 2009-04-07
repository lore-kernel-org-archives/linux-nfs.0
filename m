From: Tom Talpey <tmtalpey@gmail.com>
Subject: Re: [PATCH 3/5] nfs-utils: query for remote port using rpcbind
	instead of getaddrinfo
Date: Tue, 07 Apr 2009 16:01:31 -0400
Message-ID: <49dbb129.02045a0a.023b.6bc7@mx.google.com>
References: <1239117946-7535-1-git-send-email-jlayton@redhat.com>
	<1239117946-7535-4-git-send-email-jlayton@redhat.com>
	<41F98279-F000-4C1C-8E44-3568C89FC2BD@oracle.com>
	<49db7f0d.85c2f10a.5025.ffffb257@mx.google.com>
	<20090407131151.69203e5e@tleilax.poochiereds.net>
	<49dbacf3.14025a0a.5898.ffffbaa2@mx.google.com>
	<20090407155305.5790407c@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20090407155305.5790407c@tleilax.poochiereds.net>
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

At 03:53 PM 4/7/2009, Jeff Layton wrote:
>On Tue, 07 Apr 2009 15:43:39 -0400
>Tom Talpey <tmtalpey@gmail.com> wrote:
>
>> At 01:11 PM 4/7/2009, Jeff Layton wrote:
>> >On Tue, 07 Apr 2009 12:27:49 -0400
>> >Tom Talpey <tmtalpey@gmail.com> wrote:
>> >
>> >> At 12:02 PM 4/7/2009, Chuck Lever wrote:
>> >> >
>> >> >On Apr 7, 2009, at 11:25 AM, Jeff Layton wrote:
>> >> >> +	/* Use standard NFS port for NFSv4 */
>> >> >> +	if (program == 100003 && version == 4) {
>> >> >> +		port = 2049;
>> >> >> +		goto set_port;
>> >> >> +	}
>> >> >
>> >> >I think this patch set looks pretty reasonable.  Here's my one  
>> >> >remaining quibble.
>> >> >
>> >> >You can specify "port=" for nfs4 mounts, in which case we want to use  
>> >> >that value here, too, I think.  It would be simpler overall if the  
>> >> 
>> >> *Must* use a port= specification. The 2049 definition is only true for
>> >> NFSv4/TCP, as a counterexample the NFSv4/RDMA IANA binding is
>> >> port 20049. So slamming the port to 2049 would break NFSv4/RDMA.
>> >> 
>> >
>> >rpc.gssd doesn't seem to be rdma-enabled at this point. It only seems
>> >to handle "tcp" and "udp" in the existing code.
>> 
>> Fair enough. But hardwiring 2049 for all transports is going to very
>> problematic. What's the motivation for bypassing the rpcbind query
>> altogether (that "goto set_port" skips over it)? Why not at least
>> try the query first?
>>
>> >Does libtirpc handle RDMA properly? If so, this might not be too hard
>> >to enable, but I'd probably rather see it in a follow on patchset (and
>> >maybe by someone with more of a clue about RDMA than I currently have).
>> 
>> No, libtirpc doesn't have any RDMA support. But, there's no need for
>> RDMA support in it - only NFS does RDMA, in practice, and currently
>> that's just in-kernel.
>> 
>> My concern is simply that there be a way to specify, or discover a port
>> that isn't 2049 here. If mount.nfs supports it, other nfs-utils should too.
>> 
>
>I forget which version is the cutoff, but newer kernels tell gssd which
>port to use. That hardwiring is only for older kernels that don't send
>the port in the upcall.

Ah - well, if "older" is < 2.6.24, then no problem since those kernels don't
support NFS/RDMA. There are some backports to earlier kernels, but they
could address this as part of the backport.

>
>Could we try a short-timeout rpcbind call for those older kernels that
>don't send the port? Sure. Is it worth it? I'm not as sure there.

I wouldn't recommend a short timeout, arbitrary numbers rarely work
the way you might want them to. I guess my opinion is that in the
absence of any information, a standard rpcbind call is best, before
concluding a default 2049 is the only option.

>
>I'd rather see these people just update their kernels so that this
>isn't needed...

Agreed. Would it make sense to log a message when the default 2049
is used? At least then, there's a chance an admin will know it's needed.

Tom.
