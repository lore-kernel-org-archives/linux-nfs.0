From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] problems with lockd in 2.6.22.6
Date: Fri, 7 Sep 2007 12:19:45 -0400
Message-ID: <20070907161945.GI24638@fieldses.org>
References: <200709071749.55760.wolfgang.walter@studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: neilb@suse.de, netdev@vger.kernel.org, nfs@lists.sourceforge.net
To: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <200709071749.55760.wolfgang.walter@studentenwerk.mhn.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Fri, Sep 07, 2007 at 05:49:55PM +0200, Wolfgang Walter wrote:
> Hello,
>=20
> we upgraded the kernel of a nfs-server from 2.6.17.11 to 2.6.22.6. Si=
nce then we get the message
>=20
> lockd: too many open TCP sockets, consider increasing the number of n=
fsd threads
> lockd: last TCP connect from ^\\236^\=C3=89^D
>=20
> 1) These random characters in the second line are caused by a bug in =
svc_tcp_accept.
> I already posted this patch on netdev@vger.kernel.org:

Thanks, I've applied that.  (The bug is a little subtle: there's
actually two previous __svc_print_addr() calls which might have
initialized "buf" correctly, and it's not obvious that the second isn't
always called (since it's in a dprintk, which is a macro that expands
into a printk inside a conditional)).

> with this patch applied one gets something like
>=20
> lockd: too many open TCP sockets, consider increasing the number of
> nfsd threads lockd: last TCP connect from 10.11.0.12, port=3D784
>=20
>=20
> 2) The number of nfsd threads we are running on the machine is 1024.
> So this is not the problem. It seems, though, that in the case of
> lockd svc_tcp_accept does not check the number of nfsd threads but th=
e
> number of lockd threads which is one.  As soon as the number of open
> lockd sockets surpasses 80 this message gets logged.  This usually
> happens every evening when a lot of people shutdown their workstation=
=2E

So to be clear: there's not an actual problem here other than that the
logs are getting spammed?  (Not that that isn't a problem in itself.)

> 3) For unknown reason these sockets then remain open. In the morning
> when people start their workstation again we therefor not only get a
> lot of these messages again but often the nfs-server does not proberl=
y
> work any more. Restarting the nfs-daemon is a workaround.

Hm, thanks.

--b.
