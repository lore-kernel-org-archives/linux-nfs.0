From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] NFS using CacheFS
Date: Mon, 11 Oct 2004 17:30:39 +0200
Sender: linux-cachefs-bounces@redhat.com
Message-ID: <1097508639.20033.12.camel@lade.trondhjem.org>
References: <4161B664.70109@RedHat.com> <41661950.5070508@tequila.co.jp>
	<41667865.2000804@RedHat.com>  <20041011142329.GJ4072@admingilde.org>
Reply-To: Linux filesystem caching discussion list <linux-cachefs@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	Linux filesystem caching discussion list <linux-cachefs@redhat.com>,
	nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>,
	Clemens Schwaighofer <cs@tequila.co.jp>
Return-path: <linux-cachefs-bounces@redhat.com>
To: Martin Waitz <tali@admingilde.org>
In-Reply-To: <20041011142329.GJ4072@admingilde.org>
List-Unsubscribe: <http://www.redhat.com/mailman/listinfo/linux-cachefs>,
	<mailto:linux-cachefs-request@redhat.com?subject=unsubscribe>
List-Archive: </archives/linux-cachefs>
List-Post: <mailto:linux-cachefs@redhat.com>
List-Help: <mailto:linux-cachefs-request@redhat.com?subject=help>
List-Subscribe: <http://www.redhat.com/mailman/listinfo/linux-cachefs>,
	<mailto:linux-cachefs-request@redhat.com?subject=subscribe>
Errors-To: linux-cachefs-bounces@redhat.com
List-ID: <nfs.lists.sourceforge.net>

P=E5 m=E5 , 11/10/2004 klokka 16:23, skreiv Martin Waitz:
> hi :)
>=20
> On Fri, Oct 08, 2004 at 07:22:13AM -0400, Steve Dickson wrote:
> > The 'fscache' flag will be coming along with the nfs4 support, since
> > nfs4 mounting code does not have an open (unused) mounting flag....
>=20
> is such a flag even neccessary?
> The way I see fscache is that its operations will be no-ops anyway if y=
ou
> haven't mounted any backing cache.

You may not want to run cachefs on *all* your NFS partitions. It will
slow you down on those partitions that have lots of cache contention.

That said, David & co.: why did you choose not to use something similar
to the Solaris syntax for cachefs? The "layered filesystem" syntax has
the advantage that it would avoid entirely the need to change the NFS
mount syntax, and would make it easier to port cachefs to cifs etc.

Cheers,
  Trond


--
Linux-cachefs mailing list
Linux-cachefs@redhat.com
http://www.redhat.com/mailman/listinfo/linux-cachefs
