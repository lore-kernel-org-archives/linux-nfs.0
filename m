From: Matt Schillinger <mschilli@vss.fsi.com>
Subject: kernel recompile nfsd.
Date: 07 May 2003 10:15:44 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1052320545.15797.43.camel@mosix>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from adsl-66-136-174-212.dsl.stlsmo.swbell.net ([66.136.174.212] helo=esds.vss.fsi.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19DQbO-0004ZA-00
	for <nfs@lists.sourceforge.net>; Wed, 07 May 2003 08:13:02 -0700
Received: from mosix.vss.fsi.com (mosix [198.51.27.89])
	by esds.vss.fsi.com (8.9.1a/8.9.1) with ESMTP id KAA29538
	for <nfs@lists.sourceforge.net>; Wed, 7 May 2003 10:12:46 -0500 (CDT)
To: nfs@lists.sourceforge.net
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

I'm sorry to bother the list, but I'm over my head on this one.

I have 2 machines, and I rebuilt them both with the 2.4.19 kernel.

the vanilla kernel was patched with the nfsfh patch to cause nfsd to
workaround a CWD bug in IRIX (pre 6.5.13).

both machines had working nfs functionality previous to install of new
kernel.

On thor, the kernel installed, and there were no problems. it's running
fine with 2.4.19.

On loki, the kernel installed, and I can run everything, EXCEPT nfsd. 

Following is the results of an 'insmod nfsd'. I have tried booting into
the original kernel (redhat 2.4.18-27.8.0smp), and I get the SAME
errors. I'm sure it was just bad timing that the kernel recompile caused
this problem, but I don't have a good enough understanding of C to
figure out what is missing. Am I missing a library?  I cannot recall any
package removal that would result in such, but i'm at your mercy to help
me solve this.

Thanks for your help,

Matt Schillinger
mschilli@vss.fsi.com

----- ERROR MESSAGES

[root@loki root]# insmod nfsd
Using /lib/modules/2.4.18-27.8.0smp/kernel/fs/nfsd/nfsd.o
/lib/modules/2.4.18-27.8.0smp/kernel/fs/nfsd/nfsd.o: unresolved symbol
lockd_up_Rsmp_f6933c48
/lib/modules/2.4.18-27.8.0smp/kernel/fs/nfsd/nfsd.o: unresolved symbol
svc_recv_Rsmp_d4b0af86
/lib/modules/2.4.18-27.8.0smp/kernel/fs/nfsd/nfsd.o: unresolved symbol
svc_process_Rsmp_6060d411
/lib/modules/2.4.18-27.8.0smp/kernel/fs/nfsd/nfsd.o: unresolved symbol
svc_exit_thread_Rsmp_dec6f1d7
/lib/modules/2.4.18-27.8.0smp/kernel/fs/nfsd/nfsd.o: unresolved symbol
xdr_decode_string_Rsmp_6755aa62
/lib/modules/2.4.18-27.8.0smp/kernel/fs/nfsd/nfsd.o: unresolved symbol
nfsd_debug_Rsmp_bf9d1b96
/lib/modules/2.4.18-27.8.0smp/kernel/fs/nfsd/nfsd.o: unresolved symbol
nlmsvc_invalidate_client_Rsmp_b1c3f825
/lib/modules/2.4.18-27.8.0smp/kernel/fs/nfsd/nfsd.o: unresolved symbol
svc_proc_register_Rsmp_9f7f54cb
/lib/modules/2.4.18-27.8.0smp/kernel/fs/nfsd/nfsd.o: unresolved symbol
svc_proc_unregister_Rsmp_12e280e3
/lib/modules/2.4.18-27.8.0smp/kernel/fs/nfsd/nfsd.o: unresolved symbol
svc_proc_read_Rsmp_866b52d3
/lib/modules/2.4.18-27.8.0smp/kernel/fs/nfsd/nfsd.o: unresolved symbol
svc_create_Rsmp_d78d9b91
/lib/modules/2.4.18-27.8.0smp/kernel/fs/nfsd/nfsd.o: unresolved symbol
xdr_encode_array_Rsmp_716530af
/lib/modules/2.4.18-27.8.0smp/kernel/fs/nfsd/nfsd.o: unresolved symbol
svc_reserve_Rsmp_953572d2
/lib/modules/2.4.18-27.8.0smp/kernel/fs/nfsd/nfsd.o: unresolved symbol
svc_destroy_Rsmp_f610e525
/lib/modules/2.4.18-27.8.0smp/kernel/fs/nfsd/nfsd.o: unresolved symbol
svc_create_thread_Rsmp_ecdbf055
/lib/modules/2.4.18-27.8.0smp/kernel/fs/nfsd/nfsd.o: unresolved symbol
nlmsvc_ops_Rsmp_014eb062
/lib/modules/2.4.18-27.8.0smp/kernel/fs/nfsd/nfsd.o: unresolved symbol
svc_makesock_Rsmp_0d236ea6
/lib/modules/2.4.18-27.8.0smp/kernel/fs/nfsd/nfsd.o: unresolved symbol
xdr_decode_string_inplace_Rsmp_7bd87272
/lib/modules/2.4.18-27.8.0smp/kernel/fs/nfsd/nfsd.o: unresolved symbol
lockd_down_Rsmp_a7b91a7b

-- 
Matt Schillinger
System Administrator
FlightSafety International
mschilli@vss.fsi.com
314-551-8403




-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
