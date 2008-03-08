From: Timo Aaltonen <tjaalton@cc.hut.fi>
Subject: Re: Last call for nfs-utils patches
Date: Sat, 8 Mar 2008 20:07:38 +0200 (EET)
Message-ID: <alpine.OSF.0.99.0803082004371.100983@replicant.hut.fi>
References: <47CD680B.1070106@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <47CD680B.1070106@RedHat.com>
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

On Tue, 4 Mar 2008, Steve Dickson wrote:

>
> I'm planning on cutting a nfs-utils-1.1.2 release since
> there has been a number commits since the last 1.1.1 release.
>
> The attached list are all of the commits that have been made to
> the git://linux-nfs.org/nfs-utils git tree.
>
> (Note: to get a working copy of this tree use:
>    git clone  git://linux-nfs.org/nfs-utils nfs-utils)
>
> So if you don't see a commit you have posted to either
> the nfs or nfsv4 mailing list it probably means I missed it
> so you might want to bring it to my attention.
> (Please Note, the patch authors in some of my earlier
> commit are incorrect. This was simply due to my lack
> of git knowledge. Once it was pointed it out to me,
> the problem was corrected.)
>
> Also if you were holding off posting some (hopefully)
> non-intrusive patches now it the time. There is a very
> good chance I will not cut the release until this weekend.

Here's another patch (by Niall Sheridan) that needs approval:

- - -

rpc.gssd FD_ALLOC_BLOCK too low

The max number of sec=krb5 mounts that rpc.gssd will handle is hardcoded 
at 32. From utils/gssd/gssd.h:
#define FD_ALLOC_BLOCK 32

This causes problems and errors like:
  RPC: AUTH_GSS upcall timed out.
when the number of kerberized nfs mounts approaches the hard limit.

Since linux supports a maximum of 256 nfs mounts, perhaps this number can 
be upped to 200 or so.

http://launchpadlibrarian.net/11961434/nfs-utils-fd-alloc-block.debdiff

- - -

what say you?

t
