Return-Path: <nfsv4-bounces@linux-nfs.org>
Subject: Re: [PATCH 0/2] Make libtirpc work with old style portmapper
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <201008301503.19783.okir@suse.de>
Date: Mon, 30 Aug 2010 11:59:18 -0400
Message-Id: <30F1122D-13FB-4B6B-9BA2-99112306581F@oracle.com>
References: <201008301503.19783.okir@suse.de>
To: Olaf Kirch <okir@suse.de>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Content-Type: text/plain; charset="iso-8859-1"
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>


On Aug 30, 2010, at 9:03 AM, Olaf Kirch wrote:

>=20
> Hi Steve et al,
>=20
> We recently got a bug report from a customer trying to run nfs-utils
> (which is compiled against libtirpc on SLES 11) on a system with
> portmapper installed instead of rpcbind. Which failed miserably,
> because none of the RPC servers was able to register with portmap.
>=20
> One might argue, if it hurts don't do it, but OTOH this configuration
> isn't totally outlandish. In particular, ISVs may decide they want
> to compile an RPC enabled application against libtirpc, but still
> want it to run on a wide range of Linux versions.
>=20
> I looked into the issue and put together the following two patches,
> which I'm submitting for your kindly review.

I've seen a couple of other requests for this feature, and wrote some patch=
es last year that did something similar.  I never got around to finishing t=
hem.

I worried at the time that this might introduce a security weakness, since,=
 after all, the rpcbind SET operation goes over AF_UNIX, which is authentic=
ated, but pmap uses sockets with privileged ports to detect authorized user=
s.  I see that your logic uses the pmap SET/UNSET calls by default.  This b=
ypasses AF_UNIX completely in pretty much all local cases, which changes th=
e behavior of rpcb_set() and rpcb_unset(), and could break the local rpcbin=
d security model.  It might be better to use pmap_setunset() only when loca=
l_rpcb() fails.

Another minor problem I think I remember is that if libtirpc is used on a s=
ystem (perhaps because it is statically linked with said ISV RPC-enabled ap=
plication) that does not have /etc/netconfig installed, the transport creat=
ion logic in rpcb_clnt.c simply doesn't work.


> Thanks
> Olaf
> --=20
> Neo didn't bring down the Matrix. SOA did. (soafacts.com)
> --------------------------------------------
> Olaf Kirch - Director Server (okir@novell.com)
> SUSE LINUX Products GmbH, Maxfeldstr. 5, D-90409 N=FCrnberg
> GF: Markus Rex, HRB 16746 (AG N=FCrnberg)
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=20
chuck[dot]lever[at]oracle[dot]com




_______________________________________________
NOTE: THIS LIST IS DEPRECATED.  Please use linux-nfs@vger.kernel.org instea=
d.
(To subscribe to linux-nfs@vger.kernel.org: send "subscribe linux-nfs" in t=
he body of a message to majordomo@vger.kernel.org.)

NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
