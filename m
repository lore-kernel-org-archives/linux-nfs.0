From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 1/4] sunrpc: parse and return errors reported by gssd
Date: Thu, 07 Jan 2010 14:39:57 -0500
Message-ID: <1262893197.3309.15.camel@localhost>
References: <1262875325-4488-1-git-send-email-jlayton@redhat.com>
	<1262875325-4488-2-git-send-email-jlayton@redhat.com>
	<1262891516.3309.14.camel@localhost>
	<20100107142113.65d6b890@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20100107142113.65d6b890@tlielax.poochiereds.net>
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

On Thu, 2010-01-07 at 14:21 -0500, Jeff Layton wrote: 
> On Thu, 07 Jan 2010 14:11:56 -0500
> Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> 
> > On Thu, 2010-01-07 at 09:42 -0500, Jeff Layton wrote:
> > 
> > > @@ -646,6 +652,7 @@ gss_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
> > >  		err = PTR_ERR(p);
> > >  		switch (err) {
> > >  		case -EACCES:
> > > +		case -EKEYEXPIRED:
> > >  			gss_msg->msg.errno = err;
> > >  			err = mlen;
> > >  			break;
> > 
> >               ^^^^^^^^^^^^^^^^^^^^^ This doesn't appear to want to apply
> > to mainline. Did you perhaps skip a patch?
> > 
> > Trond
> 
> Sorry, I should have made it clear...
> 
> This set is based on your linux-next tree. Specifically, it depends on
> commit 486bad2e40e938cd68fd853b7a9fa3115a9d3a4a in your tree:
> 
>     sunrpc: on successful gss error pipe write, don't return error
> 
> ...I didn't repost that one since I figured you already had it queued
> up for 2.6.34.
> 
> Thanks,

Oh, duh... No problem, I'll rebase onto that branch...

Trond
