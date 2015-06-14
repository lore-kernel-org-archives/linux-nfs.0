Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:35035 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751417AbbFNN3X convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 14 Jun 2015 09:29:23 -0400
Received: by iesa3 with SMTP id a3so47898476ies.2
        for <linux-nfs@vger.kernel.org>; Sun, 14 Jun 2015 06:29:23 -0700 (PDT)
MIME-Version: 1.0
Date: Sun, 14 Jun 2015 21:29:23 +0800
Message-ID: <CAHnGgyE2yhRBALmoknYq8jFQr6Hx-o4m5NimchqAuBa4r28bNQ@mail.gmail.com>
Subject: [BUG]rpcbind crashed when scanning rpcbind port with QualysGuard
From: ditang chen <ditang.c@gmail.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

In the RHEL6.3GA(libtirpc-0.2.1-5) environment，when scanning rpcbind
port with QualysGuard
and rpcbind crashed due to the xprt->xp_ops is NULL.

the xprt data seems to be invalid， but how the event(fd = 4) is received?

(gdb) bt
#0  0x00007f768ab481ca in svc_getreq_common (fd=<value optimized out>)
at svc.c:650
#1  0x00007f768ab48411 in svc_getreq_poll (pfdp=<value optimized out>,
pollretval=1) at svc.c:761
#2  0x00007f768b18dafe in ?? ()
#3  0x00007f768b18c958 in main ()
(gdb) f 0
#0  0x00007f768ab481ca in svc_getreq_common (fd=<value optimized out>)
at svc.c:650
650      if (SVC_RECV (xprt, &msg))
(gdb) p *xprt
$4 = {xp_fd = -778108926, xp_port = 23969, xp_ops = 0x0, xp_addrlen =
16, xp_raddr = {sin6_family = 2, sin6_port = 11909,
    sin6_flowinfo = 786193825, sin6_addr = {__in6_u = {__u6_addr8 =
'\000' <repeats 15 times>, __u6_addr16 = {0, 0, 0, 0, 0, 0, 0, 0},
        __u6_addr32 = {0, 0, 0, 0}}}, sin6_scope_id = 0}, xp_ops2 =
0x7f768ad5a9e0, xp_tp = 0x0, xp_netid = 0x7f768b3ba430 "tcp",
  xp_ltaddr = {maxlen = 0, len = 0, buf = 0x0}, xp_rtaddr = {maxlen =
16, len = 16, buf = 0x7f768b3b4270}, xp_verf = {oa_flavor = 0,
    oa_base = 0x7f768b3b1088 "", oa_length = 0}, xp_auth = 0x0, xp_p1
= 0x7f768b3b1050, xp_p2 = 0x0, xp_p3 = 0x0, xp_type = 0}

(gdb) p __svc_xports[3]
$5 = (SVCXPRT *) 0x0
(gdb) p *__svc_xports[4]
$7 = {xp_fd = -778108926, xp_port = 23969, xp_ops = 0x0, xp_addrlen =
16, xp_raddr = {sin6_family = 2, sin6_port = 11909,
    sin6_flowinfo = 786193825, sin6_addr = {__in6_u = {__u6_addr8 =
'\000' <repeats 15 times>, __u6_addr16 = {0, 0, 0, 0, 0, 0, 0, 0},
        __u6_addr32 = {0, 0, 0, 0}}}, sin6_scope_id = 0}, xp_ops2 =
0x7f768ad5a9e0, xp_tp = 0x0, xp_netid = 0x7f768b3ba430 "tcp",
  xp_ltaddr = {maxlen = 0, len = 0, buf = 0x0}, xp_rtaddr = {maxlen =
16, len = 16, buf = 0x7f768b3b4270}, xp_verf = {oa_flavor = 0,
    oa_base = 0x7f768b3b1088 "", oa_length = 0}, xp_auth = 0x0, xp_p1
= 0x7f768b3b1050, xp_p2 = 0x0, xp_p3 = 0x0, xp_type = 0}
(gdb) p *__svc_xports[5]
$8 = {xp_fd = 5, xp_port = 65535, xp_ops = 0x7f768ad5aa40, xp_addrlen
= 0, xp_raddr = {sin6_family = 0, sin6_port = 0, sin6_flowinfo = 0,
    sin6_addr = {__in6_u = {__u6_addr8 = '\000' <repeats 15 times>,
__u6_addr16 = {0, 0, 0, 0, 0, 0, 0, 0}, __u6_addr32 = {0, 0, 0, 0}}},
    sin6_scope_id = 0}, xp_ops2 = 0x7f768ad5aa30, xp_tp =
0x7f768b3b1470 "-", xp_netid = 0x7f768b3b1450 "local", xp_ltaddr =
{maxlen = 128,
    len = 128, buf = 0x7f768b3b13c0}, xp_rtaddr = {maxlen = 0, len =
0, buf = 0x0}, xp_verf = {oa_flavor = 0, oa_base = 0x0, oa_length =
0},
  xp_auth = 0x0, xp_p1 = 0x7f768b3b12f0, xp_p2 = 0x0, xp_p3 = 0x0, xp_type = 3}
(gdb) p *__svc_xports[6]
$9 = {xp_fd = 6, xp_port = 0, xp_ops = 0x7f768ad5a940, xp_addrlen =
16, xp_raddr = {sin6_family = 2, sin6_port = 39910,
    sin6_flowinfo = 786193825, sin6_addr = {__in6_u = {__u6_addr8 =
'\000' <repeats 15 times>, __u6_addr16 = {0, 0, 0, 0, 0, 0, 0, 0},
        __u6_addr32 = {0, 0, 0, 0}}}, sin6_scope_id = 0}, xp_ops2 =
0x7f768ad5a920, xp_tp = 0x7f768b3b71d0 "-",
  xp_netid = 0x7f768b3b71b0 "udp", xp_ltaddr = {maxlen = 16, len = 16,
buf = 0x7f768b3b7190}, xp_rtaddr = {maxlen = 16, len = 16,
    buf = 0x7f768b3ba410}, xp_verf = {oa_flavor = 0, oa_base =
0x7f768b3b4c40 "", oa_length = 0}, xp_auth = 0x0, xp_p1 =
0x7f768b3b4e60,
  xp_p2 = 0x7f768b3b4c00, xp_p3 = 0x0, xp_type = 1}
(gdb) p *__svc_xports[7]
$10 = {xp_fd = 7, xp_port = 0, xp_ops = 0x7f768ad5a940, xp_addrlen =
16, xp_raddr = {sin6_family = 2, sin6_port = 53663,
    sin6_flowinfo = 786193825, sin6_addr = {__in6_u = {__u6_addr8 =
'\000' <repeats 15 times>, __u6_addr16 = {0, 0, 0, 0, 0, 0, 0, 0},
        __u6_addr32 = {0, 0, 0, 0}}}, sin6_scope_id = 0}, xp_ops2 =
0x7f768ad5a920, xp_tp = 0x0, xp_netid = 0x7f768b3b7340 "udp",
  xp_ltaddr = {maxlen = 16, len = 16, buf = 0x7f768b3b72f0}, xp_rtaddr
= {maxlen = 16, len = 16, buf = 0x7f768b3bd730}, xp_verf = {
    oa_flavor = 0, oa_base = 0x7f768b3b7b20 "", oa_length = 0},
xp_auth = 0x0, xp_p1 = 0x7f768b3b7d40, xp_p2 = 0x7f768b3b7ae0, xp_p3 =
0x0,
  xp_type = 1}
(gdb) p *__svc_xports[8]
$11 = {xp_fd = 8, xp_port = 65535, xp_ops = 0x7f768ad5aa40, xp_addrlen
= 0, xp_raddr = {sin6_family = 0, sin6_port = 0, sin6_flowinfo = 0,
    sin6_addr = {__in6_u = {__u6_addr8 = '\000' <repeats 15 times>,
__u6_addr16 = {0, 0, 0, 0, 0, 0, 0, 0}, __u6_addr32 = {0, 0, 0, 0}}},
    sin6_scope_id = 0}, xp_ops2 = 0x7f768ad5aa30, xp_tp =
0x7f768b3ba640 "-", xp_netid = 0x7f768b3ba620 "tcp", xp_ltaddr =
{maxlen = 128,
    len = 128, buf = 0x7f768b3ba590}, xp_rtaddr = {maxlen = 0, len =
0, buf = 0x0}, xp_verf = {oa_flavor = 0, oa_base = 0x0, oa_length =
0},
  xp_auth = 0x0, xp_p1 = 0x7f768b3ba4c0, xp_p2 = 0x0, xp_p3 = 0x0, xp_type = 3}
(gdb) p *__svc_xports[9]
Cannot access memory at address 0x0

(gdb) p msg
$2 = {rm_xid = 913288379, rm_direction = CALL, ru = {RM_cmb =
{cb_rpcvers = 2, cb_prog = 100000, cb_vers = 2, cb_proc = 4, cb_cred =
{
        oa_flavor = 1, oa_base = 0x7fffb121f350 "Tn\337\020",
oa_length = 80}, cb_verf = {oa_flavor = 0, oa_base = 0x7fffb121f4e0
"",
        oa_length = 0}}, RM_rmb = {rp_stat = 2, ru = {RP_ar = {ar_verf
= {oa_flavor = 2, oa_base = 0x1 <Address 0x1 out of bounds>,
            oa_length = 2971792208}, ar_stat = 80, ru = {AR_versions =
{low = 0, high = 0}, AR_results = {where = 0x0,
              proc = 0x7fffb121f4e0}}}, RP_dr = {rj_stat = 2, ru =
{RJ_versions = {low = 4, high = 1}, RJ_why = AUTH_REJECTEDVERF}}}}}}
