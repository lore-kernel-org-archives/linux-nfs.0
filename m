From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 4/5] knfsd: convert knfsd to kthread API
Date: Fri, 6 Jun 2008 14:16:12 -0400
Message-ID: <20080606181612.GB761@fieldses.org>
References: <1212765171-26042-1-git-send-email-jlayton@redhat.com>
	<1212765171-26042-2-git-send-email-jlayton@redhat.com>
	<1212765171-26042-3-git-send-email-jlayton@redhat.com>
	<1212765171-26042-4-git-send-email-jlayton@redhat.com>
	<1212765171-26042-5-git-send-email-jlayton@redhat.com>
	<20080606172431.GA761@fieldses.org>
	<20080606141116.07b79b14@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org, gnb@melbourne.sgi.com
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20080606141116.07b79b14@tleilax.poochiereds.net>
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

On Fri, Jun 06, 2008 at 02:11:16PM -0400, Jeff Layton wrote:
> I think I've goofed this part, actually. I was thinking that we didn't
> need to bump the refcount here, and that the kernel would realize that
> nfsd() hadn't returned and would prevent unloading until it had. This
> doesn't seem to be the case. I'll need to go back and add refcounting
> back in.

OK.  If you decide it is needed here, could you double-check the lockd
conversion as well?  Looks like some refcounting logic might have gotten
lost there too.

--b.
