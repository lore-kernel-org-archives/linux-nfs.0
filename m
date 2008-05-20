From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 0/3] [RFC] knfsd: convert to kthread API and remove
	signaling for shutdown
Date: Tue, 20 May 2008 07:05:08 -0400
Message-ID: <20080520070508.675b8bb0@tupile.poochiereds.net>
References: <1211078114-18384-1-git-send-email-jlayton@redhat.com>
	<18481.6416.571430.593722@notabene.brown>
	<4831F860.6050801@melbourne.sgi.com>
	<18482.4782.858347.981553@notabene.brown>
	<20080519222457.6f24daa5@tupile.poochiereds.net>
	<483238B3.4010702@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Greg Banks <gnb@melbourne.sgi.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <483238B3.4010702@melbourne.sgi.com>
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

On Mon, 19 May 2008 19:34:27 -0700
Greg Banks <gnb@melbourne.sgi.com> wrote:

> Jeff Layton wrote:
> >
> > This is the problem we have now with the BKL. So much of
> > rpc/nlm/nfs/nfsd runs under it that it's nearly impossible to tell what
> > it's intended to actually protect. 
> Practically none of nfsd runs under BKL, except the startup and shutdown
> sequences and some of the write handlers for /proc/fs/nfsd/.

You're quite correct. I was thinking mainly of lockd (which runs
entirely under the BKL) and large swaths of NFS client and RPC code
which also do. It looks like nfsd doesn't do as much under the BKL (and
that is definitely a good thing!).

> > If we're going to start a push
> > toward BKL removal, my humble request is that we try to be as explicit
> > as possible about what locks protect what data structures.
> >   
> See comments in net/sunrpc/svcsock.c and net/sunrpc/svc.c.  Here the BKL
> is protecting the global nfsd_serv pointer.
> 

Ok. Good to know. When I do the kthread conversion I'll make sure
that's protected, though with Neil's mutex patch I shouldn't need to
change much of the locking, if any.

-- 
Jeff Layton <jlayton@redhat.com>
