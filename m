From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: connection openings from server to client
Date: Wed, 02 Jun 2010 09:01:33 -0400
Message-ID: <1275483693.2923.11.camel__22528.9968228482$1275483707$gmane$org@heimdal.trondhjem.org>
References: <87mxvdmzrv.fsf@tac.ki.iif.hu> <4C0643B4.8090305@inria.fr>
	 <87iq61mwgs.fsf@tac.ki.iif.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Guillaume Rousse <Guillaume.Rousse-MZpvjPyXg2s@public.gmane.org>, nfsv4@linux-nfs.org,
	linux-nfs@vger.kernel.org
To: Ferenc Wagner <wferi-eEbw3PyuezQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:59937 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753090Ab0FBNBl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Jun 2010 09:01:41 -0400
In-Reply-To: <87iq61mwgs.fsf-/U8DR9OPLL8grVaPS+uXcA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2010-06-02 at 14:48 +0200, Ferenc Wagner wrote:
> Guillaume Rousse <Guillaume.Rousse-MZpvjPyXg2s@public.gmane.org> writes:
>=20
> > Le 02/06/2010 13:37, Ferenc Wagner a =C3=A9crit :
> >=20
> >> I read that letting NFS4 through firewalls is quite easy and entai=
ls
> >> opening up port 2049 of the server only.  It indeed works.  But ou=
r NFS
> >> client has its own firewall as well, and that logs backward connec=
tion
> >> attempts from low (665-1022) ports of the NFS4 server to port 5947=
3 of
> >> the client.  These connections aren't let through, but I wonder if=
 they
> >> should be, and if it's NFS related at all...
> >
> > They are delegation callbacks. If those connections can't succeed, =
you
> > wont' have delegation support.
>=20
> Thank you for the quick and clear explanation.  Is there some "best
> practice" available for firewalling delegation callbacks?  If that's
> infeasible, is there any way to explicitly disable delegation support=
 in
> the server, to suppress the useless trials?

On the NFS client, you should set the 'nfs.callback_tcpport' kernel
parameter to a known port number, then open that TCP port for incoming
connections on your firewall.

e.g. if you decide to open TCP port 2050, then you should add something
like the following line to /etc/modprobe.d/options-nfs.conf:

options nfs callback_tcpport=3D2050

Then either reboot the client, or unload, its nfs kernel module and
reload it...

Cheers
  Trond

