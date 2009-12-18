From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] sunrpc: on successful gss error pipe write, don't
	return error (try #3)
Date: Fri, 18 Dec 2009 16:30:18 -0500
Message-ID: <1261171818.3420.71.camel@localhost>
References: <1261171430-15075-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1261171430-15075-1-git-send-email-jlayton@redhat.com>
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

On Fri, 2009-12-18 at 16:23 -0500, Jeff Layton wrote: 
> When handling the gssd downcall, the kernel should distinguish between a
> successful downcall that contains an error code and a failed downcall
> (i.e. where the parsing failed or some other sort of problem occurred).
> 
> In the former case, gss_pipe_downcall should be returning the number of
> bytes written to the pipe instead of an error. In the event of other
> errors, we generally want the initiating task to retry the upcall so
> we set msg.errno to -EAGAIN. An unexpected error code here is a bug
> however, so BUG() in that case.

That looks good. I'll apply it after the two other fixes.

Trond
