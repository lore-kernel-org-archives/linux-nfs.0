Return-Path: <SRS0=CV1o=SX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76ABBC10F14
	for <linux-nfs@archiver.kernel.org>; Sun, 21 Apr 2019 04:16:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0EC6420869
	for <linux-nfs@archiver.kernel.org>; Sun, 21 Apr 2019 04:16:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=nazar.ca header.i=@nazar.ca header.b="RQSR4Q57"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725907AbfDUEQa (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 21 Apr 2019 00:16:30 -0400
Received: from ny019.relay.arandomserver.com ([172.96.188.181]:44631 "EHLO
        ny019.relay.arandomserver.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1725822AbfDUEQ3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 21 Apr 2019 00:16:29 -0400
X-Greylist: delayed 2410 seconds by postgrey-1.27 at vger.kernel.org; Sun, 21 Apr 2019 00:16:28 EDT
Received: from nyc006.hawkhost.com ([172.96.186.142])
        by se004.arandomserver.com with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
        (Exim 4.89)
        (envelope-from <nazard@nazar.ca>)
        id 1hI3H5-00068d-FF; Sat, 20 Apr 2019 22:36:17 -0500
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=nazar.ca;
         s=default; h=Content-Transfer-Encoding:Content-Type:MIME-Version:Date:
        Message-ID:Subject:From:To:Sender:Reply-To:Cc:Content-ID:Content-Description:
        Resent-Date:Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:
        In-Reply-To:References:List-Id:List-Help:List-Unsubscribe:List-Subscribe:
        List-Post:List-Owner:List-Archive;
        bh=Ahn8WwEOUIuuvGLW1dxHskMYgy74zH0mAkw9OloZNH8=; b=RQSR4Q57bAP2dsjqB3UzhbUonE
        1UmVRO7mNty0nOI6FyU8q6vbt5UiY9VP8t6fED6D10576PLsujJ/bkhOvhFw7N2ke8EzNf5Q96NMF
        EhOwi44JIv1yBizQuFE063VVzHKeQ4Fi8AHM19Gv0grz+pnMGleKVgycmoScwEN3jNv35nQQSeSUG
        Vy1PuryVqDivt7KISc/kuKT+XlS387WRzEEOGfcS3iTvJlXdaSr2uktlVNfL5FF562hvF2PJAVVqj
        /rE/uAvYqaTYt4tcRqdDVD1Q5nUznDuPbtq5FDuWQ1308ncfLZ4pdjlsbfM34f+pH1xFveiDz601S
        HVA87QSg==;
Received: from [24.114.57.253] (port=47378 helo=[192.168.21.100])
        by nyc006.hawkhost.com with esmtpsa (TLSv1.2:ECDHE-RSA-AES128-GCM-SHA256:128)
        (Exim 4.91)
        (envelope-from <nazard@nazar.ca>)
        id 1hI3H4-00028I-Ef; Sat, 20 Apr 2019 23:36:14 -0400
To:     NeilBrown <neilb@suse.com>, "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs@vger.kernel.org
From:   Doug Nazar <nazard@nazar.ca>
Subject: nfsd bug after f875a792abe9 (nfsd: allow nfsv3 readdir request to be
 larger.)
Message-ID: <5b98d3d5-4b80-8783-b212-4fd7ab9b1006@nazar.ca>
Date:   Sat, 20 Apr 2019 23:36:13 -0400
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:66.0) Gecko/20100101
 Thunderbird/66.0
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-AuthUser: nazard@nazar.ca
X-Originating-IP: 172.96.186.142
X-SpamExperts-Domain: nyc006.hawkhost.com
X-SpamExperts-Username: relay
Authentication-Results: arandomserver.com; auth=pass (login) smtp.auth=relay@nyc006.hawkhost.com
X-SpamExperts-Outgoing-Class: ham
X-SpamExperts-Outgoing-Evidence: Combined (0.07)
X-Recommended-Action: accept
X-Filter-ID: EX5BVjFpneJeBchSMxfU5uickW2/ksS/6GZYwv8I3c1602E9L7XzfQH6nu9C/Fh9KJzpNe6xgvOx
 q3u0UDjvO2qWYvHr5e5v4y+vmIfNl9RTYi2bf0F0JzgUQ/o6tR7CRUw4v+0fRrD6BwODIzG45g3f
 lW5F0IcsXeNa+co8V9yuz0/t36AmZ31zVm+t5xJiyCm/UAQ2SEBSVDG1qvxGXgTJsjWw5+0eZIpQ
 IcK9yrT73sIvjVcN7PAGgTt3i/caamXJnfNsEivVywpSKcw8S9VWAGyvoRQuFtgkm3FOixOLwYXe
 7hgy8nqT6sXW5geDVctLDhjLwwTBe6sple9evjxuUR2yT6Jbfuvo1HgHyp4DoGSe4KNgvD+yXfyv
 uRRz/Wolhpv46LSlmsDAxm/NRX0zh4GtkKf2sT6kagFfWLEU3i+wzMIePIjt1tyjrE+etx8z45qX
 NiodnQoWM0Lc+sZ7ikueiXlF3Zx8nQgcd3Z60TI5JtgX1dWh8TRIc/KfzQc+gvjLvoRqcK+zwapi
 p+/SK/zHu0QCeXFVZHKumiLds2Lz03fg06TwWaGcBr+RZ+qfTCHaFZsEHfuYXCWd0+idX4Ts4xdG
 +C13IyWeZaLjVEb960EyAgATYa+igH83d3giwZDSaEJjTaP32npntqeo+i7VlbrnKronyPCLdEWi
 MkV3mlc+6ICH9Iw79RAZ5XG1wJWJUloUn1mHfSxmTdM+m4WpRRDP6YzwkAPgQJb//u/Y1ylYBAwu
 i+M+hUbkwaJf8m5+rjcT5IRasoePX+yKM5WDmKTxCg7Kd0WJuKg4be7RDe63PojihgzUoKH0UV8S
 hebT8U8Xw9HTDfreWZGV3UJjayAcY2bQ5G9VxbfGeYyaxdEK7ImrLTs11eAfF6Z6yh6jdWTYg/cY
 wIlS4K0eOCh/lEFVTyvhmLVYk3U1lfwBlzoNEpB9QCKXQ/ZsEfJL2hMI4yCDSSr/HxDyN9qwFtz1
 1hJHF8bwpFIrm35nhC/w5XQuMvhpvrWBiW7161l60pdnVEsemwezvMStPPY4ocfmWv3Fe9Iziczd
 q+A=
X-Report-Abuse-To: spam@se001.arandomserver.com
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

After recently upgrading the kernel on one of my servers I was getting 
the below crashes. Tracked it down to an NFSv3 root client, bisection 
points to f875a792abe9. A revert of that on top of 
5.1.0-rc5-00289-gee2725f711fa works fine.

Relevant exports:
/storage2/cubox/root 
192.168.21.0/24(sec=sys,rw,no_root_squash,insecure,nohide,no_subtree_check,crossmnt,async)
/ 
*(sec=krb5,rw,fsid=0,no_root_squash,insecure,no_subtree_check,crossmnt,async)
/storage2 
*(sec=krb5,rw,no_root_squash,insecure,nohide,no_subtree_check,crossmnt,async)


Client has the following mounts to this server (running a modified 4.9.124):
192.168.21.90:/storage2/cubox/root on / type nfs 
(rw,relatime,vers=3,rsize=1048576,wsize=1048576,namlen=255,hard,nolock,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=192.168.21.90,mountvers=3,mountproto=tcp,local_lock=all,addr=192.168.21.90)
192.168.21.90:/storage2/cubox/root/var/tmp on /var/tmp type nfs4 
(rw,relatime,vers=4.2,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=krb5,clientaddr=192.168.21.242,local_lock=none,addr=192.168.21.90)


Thanks,
Doug


Initial BUG with HEAD when I started testing.
Apr 20 05:48:10 wraith.dragoninc.ca  [  968.294654] BUG: unable to 
handle kernel NULL pointer dereference at 0000000000000008
Apr 20 05:48:10 wraith.dragoninc.ca  [  968.294772] #PF error: [normal 
kernel read fault]
Apr 20 05:48:10 wraith.dragoninc.ca  [  968.294776] PGD 0 P4D 0
Apr 20 05:48:10 wraith.dragoninc.ca  [  968.294780] Oops: 0000 [#1] SMP 
NOPTI
Apr 20 05:48:10 wraith.dragoninc.ca  [  968.294784] CPU: 1 PID: 5459 
Comm: nfsd Not tainted 5.1.0-rc5-00289-gee2725f711fa #67
Apr 20 05:48:10 wraith.dragoninc.ca  [  968.294787] Hardware name: 
Gigabyte Technology Co., Ltd. GA-MA78LMT-S2/GA-MA78LMT-S2, BIOS F14 
08/16/2011
Apr 20 05:48:10 wraith.dragoninc.ca  [  968.294794] RIP: 
0010:do_tcp_sendpages+0x308/0x5d0
Apr 20 05:48:10 wraith.dragoninc.ca  [  968.294799] Code: ff 48 63 e8 48 
8b 5c 24 40 65 48 33 1c 25 28 00 00 00 48 89 e8 0f 85 73 02 00 00 48 83 
c4 48 5b 5d 41 5c 41 5d 41 5e 41 5f c3 <49> 8b 57 08 48 8d 42 ff 83 e2 
01 49 0f 44 c7 f0 ff 40 34 8b 91 b8
Apr 20 05:48:10 wraith.dragoninc.ca  [  968.294804] RSP: 
0018:ffffc90000437c90 EFLAGS: 00010202
Apr 20 05:48:10 wraith.dragoninc.ca  [  968.294808] RAX: 
0000000000000001 RBX: 0000000000028000 RCX: ffff888210505600
Apr 20 05:48:10 wraith.dragoninc.ca  [  968.294811] RDX: 
ffffffff8154b1a0 RSI: 0000000000001000 RDI: ffff888210316e80
Apr 20 05:48:10 wraith.dragoninc.ca  [  968.294814] RBP: 
0000000000000000 R08: 0000000000001000 R09: 0000000000000003
Apr 20 05:48:10 wraith.dragoninc.ca  [  968.294817] R10: 
0000000000000002 R11: 0000000000000005 R12: 0000000000001000
Apr 20 05:48:10 wraith.dragoninc.ca  [  968.294820] R13: 
00000000000005a8 R14: ffff888210316e80 R15: 0000000000000000
Apr 20 05:48:10 wraith.dragoninc.ca  [  968.294823] FS: 
0000000000000000(0000) GS:ffff888217a40000(0000) knlGS:0000000000000000
Apr 20 05:48:10 wraith.dragoninc.ca  [  968.294826] CS:  0010 DS: 0000 
ES: 0000 CR0: 0000000080050033
Apr 20 05:48:10 wraith.dragoninc.ca  [  968.294829] CR2: 
0000000000000008 CR3: 00000002150aa000 CR4: 00000000000006e0
Apr 20 05:48:10 wraith.dragoninc.ca  [  968.294832] Call Trace:
Apr 20 05:48:10 wraith.dragoninc.ca  [  968.294837] 
tcp_sendpage_locked+0x42/0x60
Apr 20 05:48:10 wraith.dragoninc.ca  [  968.294841] tcp_sendpage+0x38/0x50
Apr 20 05:48:10 wraith.dragoninc.ca  [  968.294844] inet_sendpage+0x3a/0xe0
Apr 20 05:48:10 wraith.dragoninc.ca  [  968.294856]  ? 
encode_post_op_attr.isra.4+0xf4/0x100 [nfsd]
Apr 20 05:48:10 wraith.dragoninc.ca  [  968.294865] 
kernel_sendpage+0x15/0x30
Apr 20 05:48:10 wraith.dragoninc.ca  [  968.294878] 
svc_send_common+0xed/0x150 [sunrpc]
Apr 20 05:48:10 wraith.dragoninc.ca  [  968.294887] 
svc_sendto+0xf6/0x1a0 [sunrpc]
Apr 20 05:48:10 wraith.dragoninc.ca  [  968.294892]  ? 
refcount_dec_and_lock+0x18/0x70
Apr 20 05:48:10 wraith.dragoninc.ca  [  968.294899]  ? 
auth_domain_put+0x10/0x60 [sunrpc]
Apr 20 05:48:10 wraith.dragoninc.ca  [  968.294907]  ? 
svc_authorise+0x34/0x40 [sunrpc]
Apr 20 05:48:10 wraith.dragoninc.ca  [  968.294915]  ? 
svc_process_common.isra.8+0x10b/0x6a0 [sunrpc]
Apr 20 05:48:10 wraith.dragoninc.ca  [  968.294923] 
svc_tcp_sendto+0x29/0x40 [sunrpc]
Apr 20 05:48:10 wraith.dragoninc.ca  [  968.294930] svc_send+0x94/0x190 
[sunrpc]
Apr 20 05:48:10 wraith.dragoninc.ca  [  968.294990]  ? 
nfsd_destroy+0x50/0x50 [nfsd]
Apr 20 05:48:10 wraith.dragoninc.ca  [  968.295049]  nfsd+0xdd/0x140 [nfsd]
Apr 20 05:48:10 wraith.dragoninc.ca  [  968.295054] kthread+0x10e/0x130
Apr 20 05:48:10 wraith.dragoninc.ca  [  968.295058]  ? 
kthread_park+0x80/0x80
Apr 20 05:48:10 wraith.dragoninc.ca  [  968.295062] ret_from_fork+0x22/0x40


Sometimes during bisection I saw this error instead:
Apr 20 21:45:56 wraith.dragoninc.ca  [  365.972318] BUG: unable to 
handle kernel paging request at ffff888214c15000
Apr 20 21:45:56 wraith.dragoninc.ca  [  365.972336] #PF error: [PROT] 
[WRITE]
Apr 20 21:45:56 wraith.dragoninc.ca  [  365.972339] PGD 2201067 P4D 
2201067 PUD 2204067 PMD 2155bd063 PTE 8000000214c15161
Apr 20 21:45:56 wraith.dragoninc.ca  [  365.972344] Oops: 0003 [#1] SMP 
NOPTI
Apr 20 21:45:56 wraith.dragoninc.ca  [  365.972349] CPU: 1 PID: 5456 
Comm: nfsd Not tainted 5.0.0-11058-ga840b56ba385 #79
Apr 20 21:45:56 wraith.dragoninc.ca  [  365.972352] Hardware name: 
Gigabyte Technology Co., Ltd. GA-MA78LMT-S2/GA-MA78LMT-S2, BIOS F14 
08/16/2011
Apr 20 21:45:56 wraith.dragoninc.ca  [  365.972360] RIP: 
0010:__memmove+0x57/0x1a0
Apr 20 21:45:56 wraith.dragoninc.ca  [  365.972363] Code: 00 72 05 40 38 
fe 74 3b 48 83 ea 20 48 83 ea 20 4c 8b 1e 4c 8b 56 08 4c 8b 4e 10 4c 8b 
46 18 48 8d 76 20 4c 89 1f 4c 89 57 08 <4c> 89 4f 10 4c 89 47 18 48 8d 
7f 20 73 d4 48 83 c2 20 e9 a2 00 00
Apr 20 21:45:56 wraith.dragoninc.ca  [  365.972370] RSP: 
0018:ffffc90000437d48 EFLAGS: 00010286
Apr 20 21:45:56 wraith.dragoninc.ca  [  365.972373] RAX: 
ffff88821498400c RBX: ffffffffdfc7fff4 RCX: ffff888214984024
Apr 20 21:45:56 wraith.dragoninc.ca  [  365.972377] RDX: 
ffffffffdf9eefd4 RSI: ffff8882121b8000 RDI: ffff888214c14fec
Apr 20 21:45:56 wraith.dragoninc.ca  [  365.972379] RBP: 
000000002038002c R08: 0000000000000000 R09: 0000000000000000
Apr 20 21:45:56 wraith.dragoninc.ca  [  365.972382] R10: 
0000000000000000 R11: 0000000000000000 R12: 0000000000000008
Apr 20 21:45:56 wraith.dragoninc.ca  [  365.972385] R13: 
ffff888214e692d4 R14: ffff888211f27000 R15: 0000000000000007
Apr 20 21:45:56 wraith.dragoninc.ca  [  365.972388] FS: 
0000000000000000(0000) GS:ffff888217a40000(0000) knlGS:0000000000000000
Apr 20 21:45:56 wraith.dragoninc.ca  [  365.972391] CS:  0010 DS: 0000 
ES: 0000 CR0: 0000000080050033
Apr 20 21:45:56 wraith.dragoninc.ca  [  365.972394] CR2: 
ffff888214c15000 CR3: 0000000210996000 CR4: 00000000000006e0
Apr 20 21:45:56 wraith.dragoninc.ca  [  365.972397] Call Trace:
Apr 20 21:45:56 wraith.dragoninc.ca  [  365.972413] 
encode_entry.isra.8+0x1bc/0x310 [nfsd]
Apr 20 21:45:56 wraith.dragoninc.ca  [  365.972422] 
nfsd_readdir+0x184/0x230 [nfsd]
Apr 20 21:45:56 wraith.dragoninc.ca  [  365.972430]  ? 
nfs3svc_encode_readdirres+0xc0/0xc0 [nfsd]
Apr 20 21:45:56 wraith.dragoninc.ca  [  365.972437]  ? 
nfsd_finish_read+0x190/0x190 [nfsd]
Apr 20 21:45:56 wraith.dragoninc.ca  [  365.972445] 
nfsd3_proc_readdir+0x84/0x120 [nfsd]
Apr 20 21:45:56 wraith.dragoninc.ca  [  365.972452] 
nfsd_dispatch+0xc1/0x1b0 [nfsd]
Apr 20 21:45:56 wraith.dragoninc.ca  [  365.972465] 
svc_process_common.isra.8+0x355/0x6a0 [sunrpc]
Apr 20 21:45:56 wraith.dragoninc.ca  [  365.972474]  ? 
svc_recv+0x2ac/0x820 [sunrpc]
Apr 20 21:45:56 wraith.dragoninc.ca  [  365.972480]  ? 
nfsd_destroy+0x50/0x50 [nfsd]
Apr 20 21:45:56 wraith.dragoninc.ca  [  365.972488] 
svc_process+0xd2/0x110 [sunrpc]
Apr 20 21:45:56 wraith.dragoninc.ca  [  365.972494]  nfsd+0xdd/0x140 [nfsd]
Apr 20 21:45:56 wraith.dragoninc.ca  [  365.972499] kthread+0x10e/0x130
Apr 20 21:45:56 wraith.dragoninc.ca  [  365.972502]  ? 
kthread_park+0x80/0x80
Apr 20 21:45:56 wraith.dragoninc.ca  [  365.972506] ret_from_fork+0x22/0x40

