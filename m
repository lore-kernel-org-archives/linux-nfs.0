From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] gssd: have gssd deal with scopeid field in upcall
Date: Wed, 9 Dec 2009 15:45:54 -0500
Message-ID: <20091209154554.27da9f1b@tlielax.poochiereds.net>
References: <1260305091-19523-1-git-send-email-jlayton@redhat.com>
	<20091209185050.GA23234@fieldses.org>
	<20091209141049.61e8fb0b@tlielax.poochiereds.net>
	<20091209201649.GE23234@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20091209201649.GE23234@fieldses.org>
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

On Wed, 9 Dec 2009 15:16:49 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Wed, Dec 09, 2009 at 02:10:49PM -0500, Jeff Layton wrote:
> > On Wed, 9 Dec 2009 13:50:50 -0500
> > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > 
> > > On Tue, Dec 08, 2009 at 03:44:51PM -0500, Jeff Layton wrote:
> > > > Recent kernels (2.6.32) have started displaying the scopeid for some
> > > > addresses in the upcall.
> > > 
> > > Does this mean we lost compatibility with old gssd's?
> > > 
> > > (Would it be better to keep the "address" line the same (if that's the
> > > problematic line), and add a new line that old gssd's can avoid?)
> > > 
> > > Or are the new addresses only going to occur in cases that would have
> > > stumped old gssd's anyway?  (In which case, how did old gssd's fail?)
> > > 
> > 
> > The problem is only with IPv6 addresses (obviously) and even then, it
> > only tacks them onto certain addresses -- link-local and site-local
> > addrs. I only happened to notice because I was using a site-local
> > prefix on a private network segment for testing.
> > 
> > IMO, NFS+IPv6+krb5 is new enough that we can just chalk this up to a bug
> > and not worry too much about backward compatibility.
> 
> OK, thanks.  So old gssd's couldn't handle context initialization over
> ipv6 anyway, so there's no regression, as long as they just ignored
> upcalls with addresses they didn't understand (rather than, say,
> crashing, or trying to talk to connect to some random address).
> 

gssd has been able to handle context initialization over ipv6 for a few
months now (since I did the patches to add IPv6 support to gssd back in
April/May. It worked fine with 2.6.30-ish kernels (I think), but some
of the kernel code changed here recently (I think in 2.6.32) such that
the addresses sent in the upcall sometimes get the scopeid tacked on.

So, there *is* technically a regression here, but it's pretty miminal.
You have to:

1) be using IPv6 + NFS + krb5

...and...

2) be using a site-local address prefix, which I think is fec::/10.

...my feeling is that the number of people that are doing both here are
so small that it's probably not worth worrying about.

In practice, no distro that I'm aware of is shipping IPv6 enabled
nfs-utils yet. The only people who could potentially get burned by this
are early adopters who build their own nfs-utils anyway and they should
be able to cope with any problems this caused.

-- 
Jeff Layton <jlayton@redhat.com>
