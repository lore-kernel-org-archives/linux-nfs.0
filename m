From: Mike Mackovitch <macko-2kanFRK1NckAvxtiuMwx3w@public.gmane.org>
Subject: Re: Massive NFS problems on large cluster with large number of
	mounts
Date: Tue, 29 Jul 2008 10:43:34 -0700
Message-ID: <20080729174334.GD8686@m3.macko.edu>
References: <486B89F5.9000109@aei.mpg.de> <20080702203130.GA24850@fieldses.org> <1215032676.7087.30.camel@localhost> <487DC43F.8040408@aei.mpg.de> <20080716190658.GF20298@fieldses.org> <76bd70e30807170747r31af3280icf0bd3fdbde17bac@mail.gmail.com> <20080717144852.GA11759@fieldses.org> <76bd70e30807170811s78175c0ep3a52da7c0ef95fc6@mail.gmail.com> <76bd70e30807281355t4890a9b2q6960d79552538f60@mail.gmail.com> <20080729073203.546a4269@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chucklever@gmail.com, chuck.lever@oracle.com,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Carsten Aulbert <carsten.aulbert-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>,
	linux-nfs@vger.kernel.org,
	Henning Fehrmann <henning.fehrmann-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>,
	Steffen Grunewald <steffen.grunewald-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out3.apple.com ([17.254.13.22]:49734 "EHLO
	mail-out3.apple.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750932AbYG2RwI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jul 2008 13:52:08 -0400
In-Reply-To: <20080729073203.546a4269-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 29, 2008 at 07:32:03AM -0400, Jeff Layton wrote:
> 
> IMNSHO, the whole concept of "privileged ports" is pretty antiquated
> anyway. It doesn't mean much unless you have a very tightly controlled
> physical network...
> 
> Being able to allow the client to use non-privileged ports could be
> useful. It's less of a problem than it used to be since the NFS client
> shares sockets better now, but it could still be a problem in an HPC-type
> environment. The NFS server already has an option to allow for clients
> that do this so we might as well allow the client to do it too.
> 
> I tend to be of the opinion that we should try to use option names that
> other OS's have already established where possible. This makes it easier
> for admins in mixed environments (shared autofs maps and fewer option
> synonyms to remember). My vote would be for calling the new option
> "insecure", or at least making "insecure" a synonym for whatever the
> new mount option is.

BSD has had such an option for years: "resvport"
You can make the default be enabled and if you don't
want it just specify "noresvport".

It has the added bonus that it doesn't falsely imply anything
about security.  (If you want security, use Kerberos.)

HTH
--macko
