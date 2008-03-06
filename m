From: Timo Aaltonen <tjaalton@cc.hut.fi>
Subject: Re: Last call for nfs-utils patches
Date: Thu, 6 Mar 2008 09:38:42 +0200 (EET)
Message-ID: <alpine.OSF.0.99.0803060931390.100983@replicant.hut.fi>
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

What about the changes which make rpc.gssd spam the syslog less, ie. 
lowering the priority of two printerr's? It did the trick wonderfully, no 
more syslog overflows when user creds have expired.

t
