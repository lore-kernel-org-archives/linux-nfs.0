Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:60597 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754830AbbG3LLi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jul 2015 07:11:38 -0400
From: Andrew W Elble <aweits@rit.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@poochiereds.net>, <linux-nfs@vger.kernel.org>,
        "Anna Schumaker" <schumakeranna@gmail.com>
Subject: Re: list_del corruption / unhash_ol_stateid()
References: <m23809zl8z.fsf@discipline.rit.edu>
	<m2zj2hwk4e.fsf@discipline.rit.edu>
	<20150728090206.1331e476@tlielax.poochiereds.net>
	<m2wpxktjfc.fsf@discipline.rit.edu>
	<20150728114933.6f917374@tlielax.poochiereds.net>
	<20150728210434.GC9349@fieldses.org>
	<m24mknq9ga.fsf@discipline.rit.edu>
	<m28u9yoi6z.fsf@discipline.rit.edu>
Date: Thu, 30 Jul 2015 07:11:37 -0400
In-Reply-To: <m28u9yoi6z.fsf@discipline.rit.edu> (Andrew W. Elble's message of
	"Wed, 29 Jul 2015 15:52:04 -0400")
Message-ID: <m2bnetnbme.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Update: can get to fail with slub_debug=FPU,nfsd4_stateids

The results seem to be in line with Jeff's theory.

The patch applied to test:

=========================

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 039f9c8a95e8..0b3a9637d199 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -734,6 +734,8 @@ nfs4_put_stid(struct nfs4_stid *s)
 
 	might_lock(&clp->cl_lock);
 
+	WARN_ON_ONCE(s->sc_type == 0x6b);
+
 	if (!atomic_dec_and_lock(&s->sc_count, &clp->cl_lock)) {
 		wake_up_all(&close_wq);
 		return;
@@ -939,6 +941,23 @@ static int nfs4_access_to_omode(u32 access)
 	return O_RDONLY;
 }
 
+static int warn_on_nofile(struct nfs4_file *fp, struct nfsd4_open *open) 
+{
+	struct file *filp = NULL;
+        int oflag = nfs4_access_to_omode(open->op_share_access);
+
+        spin_lock(&fp->fi_lock);
+        filp = fp->fi_fds[oflag];
+        spin_unlock(&fp->fi_lock);
+
+	if (filp)
+          return 1;
+
+        return 0;
+}
+
+
+
 /*
  * A stateid that had a deny mode associated with it is being released
  * or downgraded. Recalculate the deny mode on the file.
@@ -1024,6 +1043,7 @@ static void nfs4_free_ol_stateid(struct nfs4_stid *stid)
 	release_all_access(stp);
 	if (stp->st_stateowner)
 		nfs4_put_stateowner(stp->st_stateowner);
+	WARN_ON_ONCE(atomic_read(&stid->sc_count) > 0);
 	kmem_cache_free(stateid_slab, stid);
 }
 
@@ -1054,6 +1074,8 @@ static void put_ol_stateid_locked(struct nfs4_ol_stateid *stp,
 
 	WARN_ON_ONCE(!list_empty(&stp->st_locks));
 
+	WARN_ON_ONCE(s->sc_type == 0x6b);
+
 	if (!atomic_dec_and_test(&s->sc_count)) {
 		wake_up_all(&close_wq);
 		return;
@@ -3866,6 +3888,8 @@ nfs4_upgrade_open(struct svc_rqst *rqstp, struct nfs4_file *fp, struct svc_fh *c
 	if (!test_access(open->op_share_access, stp))
 		return nfs4_get_vfs_file(rqstp, fp, cur_fh, stp, open);
 
+	WARN_ON_ONCE(!warn_on_nofile(fp, open));
+
 	/* test and set deny mode */
 	spin_lock(&fp->fi_lock);
 	status = nfs4_file_check_deny(fp, open->op_share_deny);
@@ -3935,6 +3959,7 @@ static int nfs4_setlease(struct nfs4_delegation *dp)
 	if (!filp) {
 		/* We should always have a readable file here */
 		WARN_ON_ONCE(1);
+		locks_free_lock(fl);
 		return -EBADF;
 	}
 	fl->fl_file = filp;
@@ -4171,10 +4196,13 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 		init_open_stateid(stp, fp, open);
 		status = nfs4_get_vfs_file(rqstp, fp, current_fh, stp, open);
 		if (status) {
+		  WARN_ON_ONCE(!warn_on_nofile(fp, open));
 			release_open_stateid(stp);
 			goto out;
 		}
 
+		WARN_ON_ONCE(!warn_on_nofile(fp, open));
+
 		stp->st_clnt_odstate = find_or_hash_clnt_odstate(fp,
 							open->op_odstate);
 		if (stp->st_clnt_odstate == open->op_odstate)



=========================

The results:

[ 1185.524196] ------------[ cut here ]------------
[ 1185.529940] WARNING: CPU: 10 PID: 30157 at fs/nfsd/nfs4state.c:3891 nfsd4_process_open2+0xec8/0x1270 [nfsd]()
[ 1185.541634] Modules linked in: gfs2 dlm sctp drbd(OE) cts rpcsec_gss_krb5 nfsv4 dns_resolver nfs fscache dm_service_time iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi 8021q garp mrp stp llc bonding nf_log_ipv4 nf_log_common xt_LOG xt_conntrack iptable_filter nf_conntrack_ftp nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack ip_tables x86_pkg_temp_thermal coretemp dm_multipath kvm_intel kvm crct10dif_pclmul crc32_pclmul crc32c_intel ghash_clmulni_intel aesni_intel nfsd lrw gf128mul ipmi_devintf glue_helper iTCO_wdt ablk_helper cryptd iTCO_vendor_support dcdbas auth_rpcgss ipmi_si pcspkr mei_me sb_edac acpi_power_meter mei shpchp wmi lpc_ich edac_core mfd_core ipmi_msghandler acpi_pad nfs_acl lockd grace sunrpc binfmt_misc xfs mgag200 sr_mod syscopyarea sysfillrect cdrom sysimgblt i2c_algo_bit drm_kms_helper
[ 1185.625780]  ttm drm sd_mod ixgbe ahci tg3 mdio libahci dca ptp libata megaraid_sas i2c_core pps_core dm_mirror dm_region_hash dm_log dm_mod
[ 1185.639956] CPU: 10 PID: 30157 Comm: nfsd Tainted: G           OE   4.1.3_7 #1
[ 1185.648711] Hardware name: Dell Inc. PowerEdge R720/0X3D66, BIOS 2.2.2 01/16/2014
[ 1185.657864]  ffffffffa067558e ffff883fcaa8fbc8 ffffffff81657c67 0000000000000001
[ 1185.666854]  0000000000000000 ffff883fcaa8fc08 ffffffff8107853a ffff883fcaa8fc18
[ 1185.675992]  ffff881fed9263e0 ffff881f30480540 ffff881f30480528 ffff881f36a00000
[ 1185.685007] Call Trace:
[ 1185.688536]  [<ffffffff81657c67>] dump_stack+0x45/0x57
[ 1185.695026]  [<ffffffff8107853a>] warn_slowpath_common+0x8a/0xc0
[ 1185.702464]  [<ffffffff8107862a>] warn_slowpath_null+0x1a/0x20
[ 1185.709815]  [<ffffffffa06674e8>] nfsd4_process_open2+0xec8/0x1270 [nfsd]
[ 1185.718139]  [<ffffffffa0666382>] ? nfsd4_process_open1+0x152/0x3f0 [nfsd]
[ 1185.726595]  [<ffffffffa06562a2>] nfsd4_open+0x532/0x830 [nfsd]
[ 1185.733965]  [<ffffffffa0656a77>] nfsd4_proc_compound+0x4d7/0x7e0 [nfsd]
[ 1185.742185]  [<ffffffffa0642f83>] nfsd_dispatch+0xc3/0x210 [nfsd]
[ 1185.749733]  [<ffffffffa018cca2>] ? svc_tcp_adjust_wspace+0x12/0x30 [sunrpc]
[ 1185.758348]  [<ffffffffa018bbb0>] svc_process_common+0x440/0x6d0 [sunrpc]
[ 1185.766675]  [<ffffffffa018bf53>] svc_process+0x113/0x1b0 [sunrpc]
[ 1185.774298]  [<ffffffffa064298f>] nfsd+0xff/0x170 [nfsd]
[ 1185.781001]  [<ffffffffa0642890>] ? nfsd_destroy+0x80/0x80 [nfsd]
[ 1185.788538]  [<ffffffff810968b9>] kthread+0xc9/0xe0
[ 1185.794734]  [<ffffffff810967f0>] ? kthread_create_on_node+0x180/0x180
[ 1185.802733]  [<ffffffff8165f2a2>] ret_from_fork+0x42/0x70
[ 1185.809469]  [<ffffffff810967f0>] ? kthread_create_on_node+0x180/0x180
[ 1185.817458] ---[ end trace ae15837291fe646a ]---
[ 1186.313360] ------------[ cut here ]------------
[ 1186.319334] WARNING: CPU: 6 PID: 30156 at fs/nfsd/nfs4state.c:3961 nfsd4_process_open2+0xe6a/0x1270 [nfsd]()
[ 1186.331134] Modules linked in: gfs2 dlm sctp drbd(OE) cts rpcsec_gss_krb5 nfsv4 dns_resolver nfs fscache dm_service_time iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi 8021q garp mrp stp llc bonding nf_log_ipv4 nf_log_common xt_LOG xt_conntrack iptable_filter nf_conntrack_ftp nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack ip_tables x86_pkg_temp_thermal coretemp dm_multipath kvm_intel kvm crct10dif_pclmul crc32_pclmul crc32c_intel ghash_clmulni_intel aesni_intel nfsd lrw gf128mul ipmi_devintf glue_helper iTCO_wdt ablk_helper cryptd iTCO_vendor_support dcdbas auth_rpcgss ipmi_si pcspkr mei_me sb_edac acpi_power_meter mei shpchp wmi lpc_ich edac_core mfd_core ipmi_msghandler acpi_pad nfs_acl lockd grace sunrpc binfmt_misc xfs mgag200 sr_mod syscopyarea sysfillrect cdrom sysimgblt i2c_algo_bit drm_kms_helper
[ 1186.417242]  ttm drm sd_mod ixgbe ahci tg3 mdio libahci dca ptp libata megaraid_sas i2c_core pps_core dm_mirror dm_region_hash dm_log dm_mod
[ 1186.431744] CPU: 6 PID: 30156 Comm: nfsd Tainted: G        W  OE   4.1.3_7 #1
[ 1186.440610] Hardware name: Dell Inc. PowerEdge R720/0X3D66, BIOS 2.2.2 01/16/2014
[ 1186.449869]  ffffffffa067558e ffff883fceef3bc8 ffffffff81657c67 0000000000000001
[ 1186.459097]  0000000000000000 ffff883fceef3c08 ffffffff8107853a ffff881f6e414540
[ 1186.468328]  ffff881feee3e3e0 ffff881f6e414540 ffff881f3912e000 ffff881f3c3c0000
[ 1186.477507] Call Trace:
[ 1186.481105]  [<ffffffff81657c67>] dump_stack+0x45/0x57
[ 1186.487731]  [<ffffffff8107853a>] warn_slowpath_common+0x8a/0xc0
[ 1186.495273]  [<ffffffff8107862a>] warn_slowpath_null+0x1a/0x20
[ 1186.502640]  [<ffffffffa066748a>] nfsd4_process_open2+0xe6a/0x1270 [nfsd]
[ 1186.511023]  [<ffffffffa06562a2>] nfsd4_open+0x532/0x830 [nfsd]
[ 1186.518431]  [<ffffffffa0656a77>] nfsd4_proc_compound+0x4d7/0x7e0 [nfsd]
[ 1186.526697]  [<ffffffffa0642f83>] nfsd_dispatch+0xc3/0x210 [nfsd]
[ 1186.534252]  [<ffffffffa018cca2>] ? svc_tcp_adjust_wspace+0x12/0x30 [sunrpc]
[ 1186.542870]  [<ffffffffa018bbb0>] svc_process_common+0x440/0x6d0 [sunrpc]
[ 1186.551210]  [<ffffffffa018bf53>] svc_process+0x113/0x1b0 [sunrpc]
[ 1186.558839]  [<ffffffffa064298f>] nfsd+0xff/0x170 [nfsd]
[ 1186.565517]  [<ffffffffa0642890>] ? nfsd_destroy+0x80/0x80 [nfsd]
[ 1186.573028]  [<ffffffff810968b9>] kthread+0xc9/0xe0
[ 1186.579186]  [<ffffffff810967f0>] ? kthread_create_on_node+0x180/0x180
[ 1186.587220]  [<ffffffff8165f2a2>] ret_from_fork+0x42/0x70
[ 1186.593951]  [<ffffffff810967f0>] ? kthread_create_on_node+0x180/0x180
[ 1186.601996] ---[ end trace ae15837291fe646b ]---
[ 1308.795050] ------------[ cut here ]------------
[ 1308.801044] WARNING: CPU: 24 PID: 30158 at fs/nfsd/nfs4state.c:4199 nfsd4_process_open2+0x1261/0x1270 [nfsd]()
[ 1308.812986] Modules linked in: gfs2 dlm sctp drbd(OE) cts rpcsec_gss_krb5 nfsv4 dns_resolver nfs fscache dm_service_time iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi 8021q garp mrp stp llc bonding nf_log_ipv4 nf_log_common xt_LOG xt_conntrack iptable_filter nf_conntrack_ftp nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack ip_tables x86_pkg_temp_thermal coretemp dm_multipath kvm_intel kvm crct10dif_pclmul crc32_pclmul crc32c_intel ghash_clmulni_intel aesni_intel nfsd lrw gf128mul ipmi_devintf glue_helper iTCO_wdt ablk_helper cryptd iTCO_vendor_support dcdbas auth_rpcgss ipmi_si pcspkr mei_me sb_edac acpi_power_meter mei shpchp wmi lpc_ich edac_core mfd_core ipmi_msghandler acpi_pad nfs_acl lockd grace sunrpc binfmt_misc xfs mgag200 sr_mod syscopyarea sysfillrect cdrom sysimgblt i2c_algo_bit drm_kms_helper
[ 1308.900250]  ttm drm sd_mod ixgbe ahci tg3 mdio libahci dca ptp libata megaraid_sas i2c_core pps_core dm_mirror dm_region_hash dm_log dm_mod
[ 1308.915284] CPU: 24 PID: 30158 Comm: nfsd Tainted: G        W  OE   4.1.3_7 #1
[ 1308.924255] Hardware name: Dell Inc. PowerEdge R720/0X3D66, BIOS 2.2.2 01/16/2014
[ 1308.933531]  ffffffffa067558e ffff883fce893bc8 ffffffff81657c67 0000000000000001
[ 1308.942954]  0000000000000000 ffff883fce893c08 ffffffff8107853a ffff883fce893c18
[ 1308.952290]  ffff881fed9203e0 0000000018270000 ffff881f40eec948 ffff881f36a02af8
[ 1308.961644] Call Trace:
[ 1308.965298]  [<ffffffff81657c67>] dump_stack+0x45/0x57
[ 1308.971913]  [<ffffffff8107853a>] warn_slowpath_common+0x8a/0xc0
[ 1308.979547]  [<ffffffff8107862a>] warn_slowpath_null+0x1a/0x20
[ 1308.986924]  [<ffffffffa0667881>] nfsd4_process_open2+0x1261/0x1270 [nfsd]
[ 1308.995447]  [<ffffffffa0666382>] ? nfsd4_process_open1+0x152/0x3f0 [nfsd]
[ 1309.003978]  [<ffffffffa06562a2>] nfsd4_open+0x532/0x830 [nfsd]
[ 1309.011414]  [<ffffffffa0656a77>] nfsd4_proc_compound+0x4d7/0x7e0 [nfsd]
[ 1309.019704]  [<ffffffffa0642f83>] nfsd_dispatch+0xc3/0x210 [nfsd]
[ 1309.027368]  [<ffffffffa018cca2>] ? svc_tcp_adjust_wspace+0x12/0x30 [sunrpc]
[ 1309.036209]  [<ffffffffa018bbb0>] svc_process_common+0x440/0x6d0 [sunrpc]
[ 1309.044589]  [<ffffffffa018bf53>] svc_process+0x113/0x1b0 [sunrpc]
[ 1309.052266]  [<ffffffffa064298f>] nfsd+0xff/0x170 [nfsd]
[ 1309.059143]  [<ffffffffa0642890>] ? nfsd_destroy+0x80/0x80 [nfsd]
[ 1309.066775]  [<ffffffff810968b9>] kthread+0xc9/0xe0
[ 1309.073100]  [<ffffffff810967f0>] ? kthread_create_on_node+0x180/0x180
[ 1309.081303]  [<ffffffff8165f2a2>] ret_from_fork+0x42/0x70
[ 1309.088088]  [<ffffffff810967f0>] ? kthread_create_on_node+0x180/0x180
[ 1309.096314] ---[ end trace ae15837291fe646c ]---
[ 1309.102259] ------------[ cut here ]------------
[ 1309.108271] WARNING: CPU: 24 PID: 30158 at lib/list_debug.c:53 __list_del_entry+0x63/0xd0()
[ 1309.118421] list_del corruption, ffff881f36a02b28->next is LIST_POISON1 (dead000000100100)
[ 1309.128541] Modules linked in: gfs2 dlm sctp drbd(OE) cts rpcsec_gss_krb5 nfsv4 dns_resolver nfs fscache dm_service_time iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi 8021q garp mrp stp llc bonding nf_log_ipv4 nf_log_common xt_LOG xt_conntrack iptable_filter nf_conntrack_ftp nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack ip_tables x86_pkg_temp_thermal coretemp dm_multipath kvm_intel kvm crct10dif_pclmul crc32_pclmul crc32c_intel ghash_clmulni_intel aesni_intel nfsd lrw gf128mul ipmi_devintf glue_helper iTCO_wdt ablk_helper cryptd iTCO_vendor_support dcdbas auth_rpcgss ipmi_si pcspkr mei_me sb_edac acpi_power_meter mei shpchp wmi lpc_ich edac_core mfd_core ipmi_msghandler acpi_pad nfs_acl lockd grace sunrpc binfmt_misc xfs mgag200 sr_mod syscopyarea sysfillrect cdrom sysimgblt i2c_algo_bit drm_kms_helper
[ 1309.214812]  ttm drm sd_mod ixgbe ahci tg3 mdio libahci dca ptp libata megaraid_sas i2c_core pps_core dm_mirror dm_region_hash dm_log dm_mod
[ 1309.229585] CPU: 24 PID: 30158 Comm: nfsd Tainted: G        W  OE   4.1.3_7 #1
[ 1309.238657] Hardware name: Dell Inc. PowerEdge R720/0X3D66, BIOS 2.2.2 01/16/2014
[ 1309.248021]  ffffffff818c30d0 ffff883fce893b28 ffffffff81657c67 0000000000000001
[ 1309.257325]  ffff883fce893b78 ffff883fce893b68 ffffffff8107853a ffffffffa0667881
[ 1309.266608]  ffff881f36a02b28 ffff881f40eec94c ffff881f40eec948 ffff881f36a02af8
[ 1309.275896] Call Trace:
[ 1309.279613]  [<ffffffff81657c67>] dump_stack+0x45/0x57
[ 1309.286319]  [<ffffffff8107853a>] warn_slowpath_common+0x8a/0xc0
[ 1309.293968]  [<ffffffffa0667881>] ? nfsd4_process_open2+0x1261/0x1270 [nfsd]
[ 1309.302753]  [<ffffffff810785b6>] warn_slowpath_fmt+0x46/0x50
[ 1309.310052]  [<ffffffff81313bb3>] __list_del_entry+0x63/0xd0
[ 1309.317229]  [<ffffffff81313c31>] list_del+0x11/0x40
[ 1309.323613]  [<ffffffffa06611f8>] unhash_ol_stateid+0x28/0x40 [nfsd]
[ 1309.331547]  [<ffffffffa0666e76>] nfsd4_process_open2+0x856/0x1270 [nfsd]
[ 1309.339956]  [<ffffffffa0666382>] ? nfsd4_process_open1+0x152/0x3f0 [nfsd]
[ 1309.348496]  [<ffffffffa06562a2>] nfsd4_open+0x532/0x830 [nfsd]
[ 1309.355943]  [<ffffffffa0656a77>] nfsd4_proc_compound+0x4d7/0x7e0 [nfsd]
[ 1309.364257]  [<ffffffffa0642f83>] nfsd_dispatch+0xc3/0x210 [nfsd]
[ 1309.371915]  [<ffffffffa018cca2>] ? svc_tcp_adjust_wspace+0x12/0x30 [sunrpc]
[ 1309.380609]  [<ffffffffa018bbb0>] svc_process_common+0x440/0x6d0 [sunrpc]
[ 1309.389008]  [<ffffffffa018bf53>] svc_process+0x113/0x1b0 [sunrpc]
[ 1309.396761]  [<ffffffffa064298f>] nfsd+0xff/0x170 [nfsd]
[ 1309.403516]  [<ffffffffa0642890>] ? nfsd_destroy+0x80/0x80 [nfsd]
[ 1309.411179]  [<ffffffff810968b9>] kthread+0xc9/0xe0
[ 1309.417487]  [<ffffffff810967f0>] ? kthread_create_on_node+0x180/0x180
[ 1309.425586]  [<ffffffff8165f2a2>] ret_from_fork+0x42/0x70
[ 1309.432505]  [<ffffffff810967f0>] ? kthread_create_on_node+0x180/0x180
[ 1309.440602] ---[ end trace ae15837291fe646d ]---
[ 1309.446563] ------------[ cut here ]------------
[ 1309.452536] WARNING: CPU: 24 PID: 30158 at lib/list_debug.c:53 __list_del_entry+0x63/0xd0()
[ 1309.462706] list_del corruption, ffff881f36a02b38->next is LIST_POISON1 (dead000000100100)
[ 1309.472780] Modules linked in: gfs2 dlm sctp drbd(OE) cts rpcsec_gss_krb5 nfsv4 dns_resolver nfs fscache dm_service_time iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi 8021q garp mrp stp llc bonding nf_log_ipv4 nf_log_common xt_LOG xt_conntrack iptable_filter nf_conntrack_ftp nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack ip_tables x86_pkg_temp_thermal coretemp dm_multipath kvm_intel kvm crct10dif_pclmul crc32_pclmul crc32c_intel ghash_clmulni_intel aesni_intel nfsd lrw gf128mul ipmi_devintf glue_helper iTCO_wdt ablk_helper cryptd iTCO_vendor_support dcdbas auth_rpcgss ipmi_si pcspkr mei_me sb_edac acpi_power_meter mei shpchp wmi lpc_ich edac_core mfd_core ipmi_msghandler acpi_pad nfs_acl lockd grace sunrpc binfmt_misc xfs mgag200 sr_mod syscopyarea sysfillrect cdrom sysimgblt i2c_algo_bit drm_kms_helper
[ 1309.559071]  ttm drm sd_mod ixgbe ahci tg3 mdio libahci dca ptp libata megaraid_sas i2c_core pps_core dm_mirror dm_region_hash dm_log dm_mod
[ 1309.573829] CPU: 24 PID: 30158 Comm: nfsd Tainted: G        W  OE   4.1.3_7 #1
[ 1309.582892] Hardware name: Dell Inc. PowerEdge R720/0X3D66, BIOS 2.2.2 01/16/2014
[ 1309.592198]  ffffffff818c30d0 ffff883fce893b28 ffffffff81657c67 0000000000000001
[ 1309.601476]  ffff883fce893b78 ffff883fce893b68 ffffffff8107853a ffffffffa0667881
[ 1309.610680]  ffff881f36a02b38 ffff881f40eec94c ffff881f40eec948 ffff881f36a02af8
[ 1309.619877] Call Trace:
[ 1309.623476]  [<ffffffff81657c67>] dump_stack+0x45/0x57
[ 1309.630108]  [<ffffffff8107853a>] warn_slowpath_common+0x8a/0xc0
[ 1309.637666]  [<ffffffffa0667881>] ? nfsd4_process_open2+0x1261/0x1270 [nfsd]
[ 1309.646410]  [<ffffffff810785b6>] warn_slowpath_fmt+0x46/0x50
[ 1309.653674]  [<ffffffff81313bb3>] __list_del_entry+0x63/0xd0
[ 1309.660854]  [<ffffffff81313c31>] list_del+0x11/0x40
[ 1309.667228]  [<ffffffffa0661209>] unhash_ol_stateid+0x39/0x40 [nfsd]
[ 1309.675185]  [<ffffffffa0666e76>] nfsd4_process_open2+0x856/0x1270 [nfsd]
[ 1309.683646]  [<ffffffffa0666382>] ? nfsd4_process_open1+0x152/0x3f0 [nfsd]
[ 1309.692153]  [<ffffffffa06562a2>] nfsd4_open+0x532/0x830 [nfsd]
[ 1309.699604]  [<ffffffffa0656a77>] nfsd4_proc_compound+0x4d7/0x7e0 [nfsd]
[ 1309.707941]  [<ffffffffa0642f83>] nfsd_dispatch+0xc3/0x210 [nfsd]
[ 1309.715573]  [<ffffffffa018cca2>] ? svc_tcp_adjust_wspace+0x12/0x30 [sunrpc]
[ 1309.724270]  [<ffffffffa018bbb0>] svc_process_common+0x440/0x6d0 [sunrpc]
[ 1309.732680]  [<ffffffffa018bf53>] svc_process+0x113/0x1b0 [sunrpc]
[ 1309.740395]  [<ffffffffa064298f>] nfsd+0xff/0x170 [nfsd]
[ 1309.747180]  [<ffffffffa0642890>] ? nfsd_destroy+0x80/0x80 [nfsd]
[ 1309.754811]  [<ffffffff810968b9>] kthread+0xc9/0xe0
[ 1309.761065]  [<ffffffff810967f0>] ? kthread_create_on_node+0x180/0x180
[ 1309.769166]  [<ffffffff8165f2a2>] ret_from_fork+0x42/0x70
[ 1309.776005]  [<ffffffff810967f0>] ? kthread_create_on_node+0x180/0x180
[ 1309.784130] ---[ end trace ae15837291fe646e ]---
[ 1309.790143] ------------[ cut here ]------------
[ 1309.796195] WARNING: CPU: 30 PID: 30158 at fs/nfsd/nfs4state.c:737 nfs4_put_stid+0xa8/0xc0 [nfsd]()
[ 1309.807211] Modules linked in: gfs2 dlm sctp drbd(OE) cts rpcsec_gss_krb5 nfsv4 dns_resolver nfs fscache dm_service_time iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi 8021q garp mrp stp llc bonding nf_log_ipv4 nf_log_common xt_LOG xt_conntrack iptable_filter nf_conntrack_ftp nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack ip_tables x86_pkg_temp_thermal coretemp dm_multipath kvm_intel kvm crct10dif_pclmul crc32_pclmul crc32c_intel ghash_clmulni_intel aesni_intel nfsd lrw gf128mul ipmi_devintf glue_helper iTCO_wdt ablk_helper cryptd iTCO_vendor_support dcdbas auth_rpcgss ipmi_si pcspkr mei_me sb_edac acpi_power_meter mei shpchp wmi lpc_ich edac_core mfd_core ipmi_msghandler acpi_pad nfs_acl lockd grace sunrpc binfmt_misc xfs mgag200 sr_mod syscopyarea sysfillrect cdrom sysimgblt i2c_algo_bit drm_kms_helper
[ 1309.893143]  ttm drm sd_mod ixgbe ahci tg3 mdio libahci dca ptp libata megaraid_sas i2c_core pps_core dm_mirror dm_region_hash dm_log dm_mod
[ 1309.907929] CPU: 30 PID: 30158 Comm: nfsd Tainted: G        W  OE   4.1.3_7 #1
[ 1309.916955] Hardware name: Dell Inc. PowerEdge R720/0X3D66, BIOS 2.2.2 01/16/2014
[ 1309.926279]  ffffffffa067558e ffff883fce893b98 ffffffff81657c67 0000000000000001
[ 1309.935530]  0000000000000000 ffff883fce893bd8 ffffffff8107853a ffff883fce893be8
[ 1309.944766]  ffff881f36a02af8 0000000018270000 6b6b6b6b6b6b6b6b 6b6b6b6b6b6b6b6b
[ 1309.953970] Call Trace:
[ 1309.957513]  [<ffffffff81657c67>] dump_stack+0x45/0x57
[ 1309.964086]  [<ffffffff8107853a>] warn_slowpath_common+0x8a/0xc0
[ 1309.971594]  [<ffffffff8107862a>] warn_slowpath_null+0x1a/0x20
[ 1309.978884]  [<ffffffffa0663a58>] nfs4_put_stid+0xa8/0xc0 [nfsd]
[ 1309.986374]  [<ffffffffa0666a90>] nfsd4_process_open2+0x470/0x1270 [nfsd]
[ 1309.994754]  [<ffffffffa0666382>] ? nfsd4_process_open1+0x152/0x3f0 [nfsd]
[ 1310.003188]  [<ffffffffa06562a2>] nfsd4_open+0x532/0x830 [nfsd]
[ 1310.010558]  [<ffffffffa0656a77>] nfsd4_proc_compound+0x4d7/0x7e0 [nfsd]
[ 1310.018835]  [<ffffffffa0642f83>] nfsd_dispatch+0xc3/0x210 [nfsd]
[ 1310.026392]  [<ffffffffa018cca2>] ? svc_tcp_adjust_wspace+0x12/0x30 [sunrpc]
[ 1310.035000]  [<ffffffffa018bbb0>] svc_process_common+0x440/0x6d0 [sunrpc]
[ 1310.043332]  [<ffffffffa018bf53>] svc_process+0x113/0x1b0 [sunrpc]
[ 1310.050996]  [<ffffffffa064298f>] nfsd+0xff/0x170 [nfsd]
[ 1310.057686]  [<ffffffffa0642890>] ? nfsd_destroy+0x80/0x80 [nfsd]
[ 1310.065198]  [<ffffffff810968b9>] kthread+0xc9/0xe0
[ 1310.071380]  [<ffffffff810967f0>] ? kthread_create_on_node+0x180/0x180
[ 1310.079371]  [<ffffffff8165f2a2>] ret_from_fork+0x42/0x70
[ 1310.086137]  [<ffffffff810967f0>] ? kthread_create_on_node+0x180/0x180
[ 1310.094164] ---[ end trace ae15837291fe646f ]---
[ 1310.236482] =============================================================================
[ 1310.246335] BUG nfsd4_stateids (Tainted: G        W  OE  ): Poison overwritten
[ 1310.255124] -----------------------------------------------------------------------------

[ 1310.267511] Disabling lock debugging due to kernel taint
[ 1310.274197] INFO: 0xffff881f36a02af8-0xffff881f36a02af8. First byte 0x6a instead of 0x6b
[ 1310.284073] INFO: Allocated in nfs4_alloc_stid+0x29/0xc0 [nfsd] age=430 cpu=2 pid=30156
[ 1310.293768] 	__slab_alloc+0x3f6/0x477
[ 1310.298649] 	kmem_cache_alloc+0x123/0x160
[ 1310.303884] 	nfs4_alloc_stid+0x29/0xc0 [nfsd]
[ 1310.309506] 	nfsd4_process_open1+0x152/0x3f0 [nfsd]
[ 1310.315708] 	nfsd4_open+0xc9/0x830 [nfsd]
[ 1310.320933] 	nfsd4_proc_compound+0x4d7/0x7e0 [nfsd]
[ 1310.327269] 	nfsd_dispatch+0xc3/0x210 [nfsd]
[ 1310.332778] 	svc_process_common+0x440/0x6d0 [sunrpc]
[ 1310.339046] 	svc_process+0x113/0x1b0 [sunrpc]
[ 1310.344646] 	nfsd+0xff/0x170 [nfsd]
[ 1310.349235] 	kthread+0xc9/0xe0
[ 1310.353296] 	ret_from_fork+0x42/0x70
[ 1310.357923] INFO: Freed in nfs4_free_ol_stateid+0x45/0x70 [nfsd] age=486 cpu=4 pid=30155
[ 1310.367621] 	__slab_free+0x39/0x1df
[ 1310.372124] 	kmem_cache_free+0x123/0x150
[ 1310.377098] 	nfs4_free_ol_stateid+0x45/0x70 [nfsd]
[ 1310.383026] 	nfs4_put_stid+0x51/0xc0 [nfsd]
[ 1310.388311] 	nfsd4_close+0x21b/0x290 [nfsd]
[ 1310.393548] 	nfsd4_proc_compound+0x4d7/0x7e0 [nfsd]
[ 1310.399560] 	nfsd_dispatch+0xc3/0x210 [nfsd]
[ 1310.404888] 	svc_process_common+0x440/0x6d0 [sunrpc]
[ 1310.410986] 	svc_process+0x113/0x1b0 [sunrpc]
[ 1310.416399] 	nfsd+0xff/0x170 [nfsd]
[ 1310.420836] 	kthread+0xc9/0xe0
[ 1310.424803] 	ret_from_fork+0x42/0x70
[ 1310.429335] INFO: Slab 0xffffea007cda8000 objects=37 used=37 fp=0x          (null) flags=0x2fffff80004080
[ 1310.440578] INFO: Object 0xffff881f36a02af8 @offset=11000 fp=0xffff881f36a03020

[ 1310.451557] Bytes b4 ffff881f36a02ae8: 18 00 00 00 ce 75 00 00 40 22 0f 00 01 00 00 00  .....u..@"......
[ 1310.462788] Object ffff881f36a02af8: 6a 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  jkkkkkkkkkkkkkkk
[ 1310.473775] Object ffff881f36a02b08: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 1310.484769] Object ffff881f36a02b18: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 1310.495734] Object ffff881f36a02b28: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 1310.506693] Object ffff881f36a02b38: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 1310.517662] Object ffff881f36a02b48: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 1310.528604] Object ffff881f36a02b58: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 1310.539576] Object ffff881f36a02b68: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
[ 1310.550523] CPU: 24 PID: 30158 Comm: nfsd Tainted: G    B   W  OE   4.1.3_7 #1
[ 1310.559151] Hardware name: Dell Inc. PowerEdge R720/0X3D66, BIOS 2.2.2 01/16/2014
[ 1310.568074]  ffff881f36a02af8 ffff883fce893a28 ffffffff81657c67 00000000000001b8
[ 1310.576934]  ffff881ff1536100 ffff883fce893a68 ffffffff811ca65d 0000000000000080
[ 1310.585768]  ffff881f00000001 ffff881f36a02af9 ffff881ff1536100 000000000000006b
[ 1310.594593] Call Trace:
[ 1310.597855]  [<ffffffff81657c67>] dump_stack+0x45/0x57
[ 1310.604131]  [<ffffffff811ca65d>] print_trailer+0x14d/0x200
[ 1310.610952]  [<ffffffff811ca7df>] check_bytes_and_report+0xcf/0x110
[ 1310.618458]  [<ffffffff811cb547>] check_object+0x1d7/0x250
[ 1310.625179]  [<ffffffffa0663919>] ? nfs4_alloc_stid+0x29/0xc0 [nfsd]
[ 1310.632799]  [<ffffffff81655418>] alloc_debug_processing+0x76/0x118
[ 1310.640325]  [<ffffffff81655f44>] __slab_alloc+0x3f6/0x477
[ 1310.646945]  [<ffffffffa0663919>] ? nfs4_alloc_stid+0x29/0xc0 [nfsd]
[ 1310.654535]  [<ffffffff8109aab4>] ? groups_alloc+0x34/0x110
[ 1310.661300]  [<ffffffffa0663919>] ? nfs4_alloc_stid+0x29/0xc0 [nfsd]
[ 1310.668894]  [<ffffffff811cc0e3>] kmem_cache_alloc+0x123/0x160
[ 1310.675928]  [<ffffffffa0663919>] nfs4_alloc_stid+0x29/0xc0 [nfsd]
[ 1310.683463]  [<ffffffffa0666382>] nfsd4_process_open1+0x152/0x3f0 [nfsd]
[ 1310.691472]  [<ffffffffa0655e39>] nfsd4_open+0xc9/0x830 [nfsd]
[ 1310.698493]  [<ffffffffa0656a77>] nfsd4_proc_compound+0x4d7/0x7e0 [nfsd]
[ 1310.706522]  [<ffffffffa0642f83>] nfsd_dispatch+0xc3/0x210 [nfsd]
[ 1310.713844]  [<ffffffffa018bbb0>] svc_process_common+0x440/0x6d0 [sunrpc]
[ 1310.721937]  [<ffffffffa018bf53>] svc_process+0x113/0x1b0 [sunrpc]
[ 1310.729338]  [<ffffffffa064298f>] nfsd+0xff/0x170 [nfsd]
[ 1310.735782]  [<ffffffffa0642890>] ? nfsd_destroy+0x80/0x80 [nfsd]
[ 1310.743085]  [<ffffffff810968b9>] kthread+0xc9/0xe0
[ 1310.749034]  [<ffffffff810967f0>] ? kthread_create_on_node+0x180/0x180
[ 1310.756845]  [<ffffffff8165f2a2>] ret_from_fork+0x42/0x70
[ 1310.763397]  [<ffffffff810967f0>] ? kthread_create_on_node+0x180/0x180
[ 1310.771195] FIX nfsd4_stateids: Restoring 0xffff881f36a02af8-0xffff881f36a02af8=0x6b

[ 1310.782626] FIX nfsd4_stateids: Marking all objects used

-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
