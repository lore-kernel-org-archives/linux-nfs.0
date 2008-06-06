From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 4/5] knfsd: convert knfsd to kthread API
Date: Fri, 6 Jun 2008 15:05:37 -0400
Message-ID: <20080606150537.14c9537c@tleilax.poochiereds.net>
References: <1212765171-26042-1-git-send-email-jlayton@redhat.com>
	<1212765171-26042-2-git-send-email-jlayton@redhat.com>
	<1212765171-26042-3-git-send-email-jlayton@redhat.com>
	<1212765171-26042-4-git-send-email-jlayton@redhat.com>
	<1212765171-26042-5-git-send-email-jlayton@redhat.com>
	<20080606172431.GA761@fieldses.org>
	<20080606141116.07b79b14@tleilax.poochiereds.net>
	<20080606181612.GB761@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org, gnb@melbourne.sgi.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20080606181612.GB761@fieldses.org>
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

On Fri, 6 Jun 2008 14:16:12 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Fri, Jun 06, 2008 at 02:11:16PM -0400, Jeff Layton wrote:
> > I think I've goofed this part, actually. I was thinking that we didn't
> > need to bump the refcount here, and that the kernel would realize that
> > nfsd() hadn't returned and would prevent unloading until it had. This
> > doesn't seem to be the case. I'll need to go back and add refcounting
> > back in.
> 
> OK.  If you decide it is needed here, could you double-check the lockd
> conversion as well?  Looks like some refcounting logic might have gotten
> lost there too.
> 
> --b.

Full disclosure:

I don't completely understand module refcounts and when we need to take
a reference. So feel free to set me straight if my comments below are
wrong :-)

The change to lockd was deliberate and was suggested by Neil Brown, when
I was working on an earlier version of the lockd-kthread patch:

--------------[snip]------------------

> -	module_put_and_exit(0);
> +	module_put(THIS_MODULE);
> +	return 0;  

This changes bothers me.  Putting the last ref to a module in code
inside that module is not safe, which is why module_put_and_exit
exists. 

So this module_put is either unsafe or not needed.  I think the
latter.

As you say in the comment, lockd_down now blocks until lockd actually
exits.  As every caller for lockd_down will own a reference to the
lockd module, the lockd thread no longer needs to own a reference too.
So I think it is safe to remove the module_put, and also remove the
__module_get at the top of the lockd function.

--------------[snip]------------------

So I followed his advice and everything seems to be OK. I don't see a way
to yank out the lockd module while lockd is actually up, since the
callers of lockd_up() have to have a reference to the lockd module, and
if those modules go away, then lockd should be down anyway.

This is what led me to think that we didn't need this for nfsd either,
but that seems to be incorrect. I think nfsd is different because it's
started directly from userspace. We don't have any persistent module
references so we need to take them explicitly.

-- 
Jeff Layton <jlayton@redhat.com>
