From: Jim Davis <jdavis@CS.Arizona.EDU>
Subject: Re: rpc.gssd segfault on FC5 client
Date: Mon, 29 Jan 2007 15:49:53 -0700
Message-ID: <45BE7A11.1060706@CS.Arizona.EDU>
References: <1169911208.2767.15.camel@localhost.localdomain>	
	<20070128230148.GB12125@fieldses.org>	
	<1170030999.9144.8.camel@localhost.localdomain>	
	<20070129010419.GF12125@fieldses.org>	
	<1170079837.2871.15.camel@localhost.localdomain>	
	<45BE5A87.3010204@CS.Arizona.EDU>	
	<4d569c330701291402pa6760c4mf64cbfd82cfc6fd2@mail.gmail.com>	
	<45BE6FF9.6000101@CS.Arizona.EDU>
	<4d569c330701291444n36e3a891t318bcfe192c75a04@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HBfK7-0007qJ-O0
	for nfs@lists.sourceforge.net; Mon, 29 Jan 2007 14:50:03 -0800
Received: from optima.cs.arizona.edu ([192.12.69.5])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HBfK5-0006e6-PC
	for nfs@lists.sourceforge.net; Mon, 29 Jan 2007 14:50:05 -0800
In-Reply-To: <4d569c330701291444n36e3a891t318bcfe192c75a04@mail.gmail.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Kevin Coffman wrote:
> I'm not seeing nfs-utils-debuginfo available.  What is included with
> nfs-utils-debuginfo-1.0.8.rc2-4.FC5.2 ?

Oh, right, I downloaded that rpm to another system and tarred the 
contents across to this one.  (That system had the same problem but I 
decided to focus on just this one.)  The rpm is supposed to have 
debuggable versions of the nfs-utils in it:

korat$ rpm -ql nfs-utils-debuginfo
/usr/lib/debug/sbin/rpc.lockd.debug
/usr/lib/debug/sbin/rpc.statd.debug
/usr/lib/debug/usr/sbin/exportfs.debug
/usr/lib/debug/usr/sbin/nfsstat.debug
/usr/lib/debug/usr/sbin/nhfsstone.debug
/usr/lib/debug/usr/sbin/rpc.gssd.debug
/usr/lib/debug/usr/sbin/rpc.idmapd.debug
/usr/lib/debug/usr/sbin/rpc.mountd.debug
/usr/lib/debug/usr/sbin/rpc.nfsd.debug
/usr/lib/debug/usr/sbin/rpc.svcgssd.debug
/usr/lib/debug/usr/sbin/showmount.debug
/usr/src/debug/nfs-utils-1.0.8-rc2
/usr/src/debug/nfs-utils-1.0.8-rc2/support
/usr/src/debug/nfs-utils-1.0.8-rc2/support/export
/usr/src/debug/nfs-utils-1.0.8-rc2/support/export/client.c
/usr/src/debug/nfs-utils-1.0.8-rc2/support/export/export.c
/usr/src/debug/nfs-utils-1.0.8-rc2/support/export/hostname.c
/usr/src/debug/nfs-utils-1.0.8-rc2/support/export/mount.h
/usr/src/debug/nfs-utils-1.0.8-rc2/support/export/mount_xdr.c
/usr/src/debug/nfs-utils-1.0.8-rc2/support/export/nfsctl.c
/usr/src/debug/nfs-utils-1.0.8-rc2/support/export/rmtab.c
/usr/src/debug/nfs-utils-1.0.8-rc2/support/export/xtab.c
/usr/src/debug/nfs-utils-1.0.8-rc2/support/include
/usr/src/debug/nfs-utils-1.0.8-rc2/support/include/exportfs.h
/usr/src/debug/nfs-utils-1.0.8-rc2/support/include/gssapi
/usr/src/debug/nfs-utils-1.0.8-rc2/support/include/gssapi/gssapi.h
/usr/src/debug/nfs-utils-1.0.8-rc2/support/include/ha-callout.h
/usr/src/debug/nfs-utils-1.0.8-rc2/support/include/misc.h
/usr/src/debug/nfs-utils-1.0.8-rc2/support/include/mount.h
/usr/src/debug/nfs-utils-1.0.8-rc2/support/include/nfs
/usr/src/debug/nfs-utils-1.0.8-rc2/support/include/nfs/nfs.h
/usr/src/debug/nfs-utils-1.0.8-rc2/support/include/nfslib.h
/usr/src/debug/nfs-utils-1.0.8-rc2/support/include/rpcmisc.h
/usr/src/debug/nfs-utils-1.0.8-rc2/support/include/xio.h
/usr/src/debug/nfs-utils-1.0.8-rc2/support/include/xlog.h
/usr/src/debug/nfs-utils-1.0.8-rc2/support/misc
/usr/src/debug/nfs-utils-1.0.8-rc2/support/misc/mountpoint.c
/usr/src/debug/nfs-utils-1.0.8-rc2/support/nfs
/usr/src/debug/nfs-utils-1.0.8-rc2/support/nfs/cacheio.c
/usr/src/debug/nfs-utils-1.0.8-rc2/support/nfs/closeall.c
/usr/src/debug/nfs-utils-1.0.8-rc2/support/nfs/exports.c
/usr/src/debug/nfs-utils-1.0.8-rc2/support/nfs/getfh.c
/usr/src/debug/nfs-utils-1.0.8-rc2/support/nfs/lockdsvc.c
/usr/src/debug/nfs-utils-1.0.8-rc2/support/nfs/nfsclient.c
/usr/src/debug/nfs-utils-1.0.8-rc2/support/nfs/nfsctl.c
/usr/src/debug/nfs-utils-1.0.8-rc2/support/nfs/nfsexport.c
/usr/src/debug/nfs-utils-1.0.8-rc2/support/nfs/nfssvc.c
/usr/src/debug/nfs-utils-1.0.8-rc2/support/nfs/rmtab.c
/usr/src/debug/nfs-utils-1.0.8-rc2/support/nfs/rpcdispatch.c
/usr/src/debug/nfs-utils-1.0.8-rc2/support/nfs/rpcmisc.c
/usr/src/debug/nfs-utils-1.0.8-rc2/support/nfs/svc_socket.c
/usr/src/debug/nfs-utils-1.0.8-rc2/support/nfs/wildmat.c
/usr/src/debug/nfs-utils-1.0.8-rc2/support/nfs/xio.c
/usr/src/debug/nfs-utils-1.0.8-rc2/support/nfs/xlog.c
/usr/src/debug/nfs-utils-1.0.8-rc2/support/nfs/xmalloc.c
/usr/src/debug/nfs-utils-1.0.8-rc2/support/rpc
/usr/src/debug/nfs-utils-1.0.8-rc2/support/rpc/include
/usr/src/debug/nfs-utils-1.0.8-rc2/support/rpc/include/rpc
/usr/src/debug/nfs-utils-1.0.8-rc2/support/rpc/include/rpc/auth.h
/usr/src/debug/nfs-utils-1.0.8-rc2/support/rpc/include/rpc/auth_gss.h
/usr/src/debug/nfs-utils-1.0.8-rc2/support/rpc/include/rpc/clnt.h
/usr/src/debug/nfs-utils-1.0.8-rc2/support/rpc/include/rpc/xdr.h
/usr/src/debug/nfs-utils-1.0.8-rc2/utils
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/exportfs
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/exportfs/exportfs.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/gssd
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/gssd/context.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/gssd/err_util.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/gssd/gss_oids.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/gssd/gss_oids.h
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/gssd/gss_util.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/gssd/gss_util.h
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/gssd/gssd.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/gssd/gssd.h
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/gssd/gssd_main_loop.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/gssd/gssd_proc.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/gssd/krb5_util.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/gssd/krb5_util.h
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/gssd/write_bytes.h
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/idmapd
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/idmapd/atomicio.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/idmapd/cfg.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/idmapd/cfg.h
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/idmapd/idmapd.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/idmapd/nfs_idmap.h
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/idmapd/setproctitle.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/idmapd/strlcat.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/idmapd/strlcpy.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/lockd
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/lockd/lockd.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/mountd
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/mountd/auth.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/mountd/cache.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/mountd/mount_dispatch.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/mountd/mountd.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/mountd/mountd.h
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/mountd/rmtab.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/mountd/svc_run.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/nfsd
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/nfsd/nfsd.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/nfsstat
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/nfsstat/nfsstat.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/nhfsstone
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/nhfsstone/nhfsstone.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/showmount
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/showmount/showmount.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/statd
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/statd/callback.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/statd/log.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/statd/misc.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/statd/monitor.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/statd/notify.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/statd/notlist.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/statd/notlist.h
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/statd/rmtcall.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/statd/simu.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/statd/sm_inter.h
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/statd/sm_inter_clnt.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/statd/sm_inter_svc.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/statd/sm_inter_xdr.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/statd/stat.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/statd/statd.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/statd/statd.h
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/statd/state.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/statd/svc_run.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/svcgssd
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/svcgssd/cacheio.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/svcgssd/context.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/svcgssd/err_util.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/svcgssd/gss_oids.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/svcgssd/gss_util.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/svcgssd/svcgssd.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/svcgssd/svcgssd_main_loop.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/svcgssd/svcgssd_mech2file.c
/usr/src/debug/nfs-utils-1.0.8-rc2/utils/svcgssd/svcgssd_proc.c
korat$


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
