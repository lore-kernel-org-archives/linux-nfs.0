From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] NFS: make remounts of NFS filesystems return a proper
	error (resend)
Date: Thu, 10 Apr 2008 08:19:45 -0400
Message-ID: <20080410081945.6da3a940@tleilax.poochiereds.net>
References: <1207829399-3328-1-git-send-email-jlayton@redhat.com>
	<1207829796.8465.0.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1207829796.8465.0.camel@heimdal.trondhjem.org>
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

On Thu, 10 Apr 2008 08:16:36 -0400
Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> 
> On Thu, 2008-04-10 at 08:09 -0400, Jeff Layton wrote:
> > Hi Trond,
> >    I sent this a few weeks ago and never got a response. Any thoughts?
> > 
> > Thanks,
> > Jeff
> 
> Won't it break 'mount -oro,remount /mnt'?
> 
> Cheers
>   Trond
> 

Erm...good point. I suppose we'll have to handle that as a special
case if we want to do this.

-- 
Jeff Layton <jlayton@redhat.com>
