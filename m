From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: mount point not recovering after NFS server comes back
Date: Fri, 18 Jul 2003 05:48:09 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C6113D06AA2@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19dUeo-0007RA-00
	for <nfs@lists.sourceforge.net>; Fri, 18 Jul 2003 05:48:18 -0700
Received: from frejya.corp.netapp.com (frejya [10.10.20.91])
	by mx01.netapp.com (8.12.9/8.12.9/NTAP-1.5) with ESMTP id h6ICmDQw013124
	for <nfs@lists.sourceforge.net>; Fri, 18 Jul 2003 05:48:13 -0700 (PDT)
Received: from svlexc01.hq.netapp.com (svlexc01.corp.netapp.com [10.10.22.171])
	by frejya.corp.netapp.com (8.12.9/8.12.9/NTAP-1.5) with ESMTP id h6ICmDRa010475
	for <nfs@lists.sourceforge.net>; Fri, 18 Jul 2003 05:48:13 -0700 (PDT)
To: <nfs@lists.sourceforge.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

hi antonio-

replying directly to antonio@geto.net bounced,
so i'm sending to the list instead.

using a short timeout with TCP is probably a
bad idea, though it's doubtful that is the
root cause of your problem.

have you tried the same mount options but using
UDP instead?

can you send us a network trace?  raw tcpdump
with snaplen of 1536 is preferred.


> -----Original Message-----
> From: antonio@geto.net [mailto:antonio@geto.net]=20
> Sent: Thursday, July 17, 2003 5:48 PM
> To: nfs@lists.sourceforge.net
> Subject: [NFS] mount point not recovering after NFS server comes back
>=20
>=20
> Hi everybody -- I'm really hoping someone can push me in the right=20
> direction on this . . .
>=20
> NFS server is a NetApp filer running OnTap 6.3.2
> NFS clients are RedHat 9 boxes running linux 2.4.20.
>=20
> We are using soft mounts with these options:
> rw,soft,intr,nfsvers=3D3,wsize=3D32768,rsize=3D32768, \
> proto=3Dtcp,timeo=3D3,retrans=3D1,noac,sync
>=20
> We are using these mount point options so that our application
> (which constantly is writing to the NFS server) can detect
> an NFS operation timeout after 0.9 seconds and fail over to local
> disk to queue until the NFS server comes back.
>=20
> Problem is -- is that is the NFS server is gone for any=20
> length of time,
> the mount point doesn't "recover".  df -k hangs forever, I can't
> re-mount the mount point, and any processes that attempt to stat
> or otherwise access the mount point are shown as being in an=20
> "uninterruptable sleep" according to ps.
>=20
> The only was I've been able to restore access to our mount=20
> point is to=20
> reboot the clients that are hung.  After enabling nfs/rpc=20
> debugging I'm=20
> seeing this in /var/log/messages after attempting an NFS operation:
>=20
> Jul 17 14:40:04 ts_10_2_20_22 kernel: RPC: 47394 reserved req=20
> f7aca7c8 xid=20
> 6e94a90f
> Jul 17 14:40:04 ts_10_2_20_22 kernel: RPC: 47394 xprt_reserve=20
> returns 0
> Jul 17 14:40:04 ts_10_2_20_22 kernel: RPC: 47395=20
> xprt_reconnect f7aca000=20
> connected 0
> Jul 17 14:40:04 ts_10_2_20_22 kernel: RPC: 47395 TCP write queue full
>=20
>=20
> According to ltrace and strace, processes hang in one of the=20
> following=20
> locations:
>=20
> __xstat64(3, "/corelog", 0x08058f74 <unfinished ...
> stat64("/corelog",  <unfinished ...>
> statfs("/corelog",  <unfinished ...>
>=20
>=20
> Restarting nfslock and portmap have no effect.  Note that I=20
> can mount the=20
> same NFS share to a different location on the client and work=20
> from there=20
> -- but in order to restore access to the original mount point=20
> I have to=20
> reboot the server...
>=20
> any ideas?
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
> -------------------------------------------------------
> This SF.net email is sponsored by: VM Ware
> With VMware you can run multiple operating systems on a=20
> single machine.
> WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual=20
> machines at the
> same time. Free trial click here: http://www.vmware.com/wl/offer/345/0
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20


-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines at the
same time. Free trial click here: http://www.vmware.com/wl/offer/345/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
