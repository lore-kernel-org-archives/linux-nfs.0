Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from master.debian.org ([70.103.162.29]:35312 "EHLO
	master.debian.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750835Ab1CWAeH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Mar 2011 20:34:07 -0400
Date: Wed, 23 Mar 2011 11:09:26 +1100
From: =?iso-8859-1?Q?An=EDbal?= Monsalve Salazar <anibal@debian.org>
To: Kevin Coffman <kwc@citi.umich.edu>
Cc: linux-nfs@vger.kernel.org, 619052@bugs.debian.org,
        Tom Boven <tom.boven@telenet.be>, Bones <bones_was_here@yahoo.com.au>,
        Luk Claes <luk@debian.org>
Subject: rpc.gssd: double free or corruption (was: libgssglue-0.2)
Message-ID: <20110323000925.GA6353@master.debian.org>
References: <AANLkTik72b2H3yVx7-YcE1Bmp73LboMzZ+DSOjww=RS0@mail.gmail.com>
Content-Type: multipart/mixed; boundary="4Ckj6UjgE2iN1+kY"
In-Reply-To: <AANLkTik72b2H3yVx7-YcE1Bmp73LboMzZ+DSOjww=RS0@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--4Ckj6UjgE2iN1+kY
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

On Wed, Mar 16, 2011 at 09:28:04PM -0400, Kevin Coffman wrote:
>A new version of library libgssglue is now available from:
>
>http://www.citi.umich.edu/projects/nfsv4/linux/libgssglue/libgssglue-0.2.tar.gz
>
>Changes since libgssglue-0.1:
>
>	* Modify the gss_acquire_cred() code to accept, and
>	  properly handle, an input name of GSS_C_NO_NAME.
>	  Other misc. changes to support this change.
>	* Remove some generated files from git.  Change
>	  autogen.sh to clean up files that might become
>	  outdated and incompatible.
>--
>To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html

Hello Kevin,

Please have a look at Debian bug#619052.

http://bugs.debian.org/619052

The attached file is the original bug report.

Thank you,

Aníbal

--4Ckj6UjgE2iN1+kY
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: attachment; filename="bug_619052_message_5.mbox.txt"

>From tom.boven@telenet.be Sun Mar 20 20:26:03 2011
Received: (at submit) by bugs.debian.org; 20 Mar 2011 20:26:03 +0000
X-Spam-Checker-Version: SpamAssassin 3.2.5-bugs.debian.org_2005_01_02
	(2008-06-10) on busoni.debian.org
X-Spam-Level: 
X-Spam-Bayes: score:0.0000 Tokens: new, 81; hammy, 151; neutral, 288; spammy,
	0. spammytokens: hammytokens:0.000-+--H*M:reportbug, 0.000-+--H*MI:reportbug,
	0.000-+--H*x:reportbug, 0.000-+--H*UA:reportbug, 0.000-+--UD:init.d
X-Spam-Status: No, score=-9.6 required=4.0 tests=BAYES_00,FOURLA,HAS_PACKAGE,
	IMPRONONCABLE_1,IMPRONONCABLE_2,MURPHY_WRONG_WORD1,MURPHY_WRONG_WORD2,
	XMAILER_REPORTBUG autolearn=ham version=3.2.5-bugs.debian.org_2005_01_02
Return-path: <tom.boven@telenet.be>
Received: from georges.telenet-ops.be ([195.130.137.68])
	by busoni.debian.org with esmtp (Exim 4.69)
	(envelope-from <tom.boven@telenet.be>)
	id 1Q1PCN-00016e-3G
	for submit@bugs.debian.org; Sun, 20 Mar 2011 20:26:03 +0000
Received: from mail.boven.lan ([94.225.247.193])
	by georges.telenet-ops.be with bizsmtp
	id MYS01g0014B5xiu06YS0eD; Sun, 20 Mar 2011 21:26:00 +0100
Received: from localhost (localhost [127.0.0.1])
	by mail.boven.lan (Postfix) with SMTP id CEF3FBEC
	for <submit@bugs.debian.org>; Sun, 20 Mar 2011 21:25:59 +0100 (CET)
Received: from mail.boven.lan (localhost [127.0.0.1])
	by mail.boven.lan (Postfix) with ESMTP id DFEA59CB;
	Sun, 20 Mar 2011 21:25:55 +0100 (CET)
Received: from tom.computers.lan (tom.computers.lan [192.168.100.49])
	by mail.boven.lan (Postfix) with ESMTP id A71D3179;
	Sun, 20 Mar 2011 21:25:55 +0100 (CET)
Received: from brainkiller by tom.computers.lan with local (Exim 4.74)
	(envelope-from <tom.boven@telenet.be>)
	id 1Q1PCF-0001b0-He; Sun, 20 Mar 2011 21:25:55 +0100
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
From: Tom Boven <tom.boven@telenet.be>
To: Debian Bug Tracking System <submit@bugs.debian.org>
Subject: rpc.gssd: double free or corruption
Message-ID: <20110320202555.6048.87455.reportbug@tom.computers.lan>
X-Mailer: reportbug 5.0
Date: Sun, 20 Mar 2011 21:25:55 +0100
X-Text-Classification: not_spam
X-POPFile-Link: http://mail.lan :8000/jump_to_message?view=176264
Delivered-To: submit@bugs.debian.org

Package: nfs-common
Version: 1:1.2.2-5
Severity: important


When installing nfs-common from sid I reccieve the following stacktrace
at every start of the package:

 * Starting NFS common utilities
 * *** glibc detected *** /usr/sbin/rpc.gssd: double free or corruption
 * (!prev): 0x00000000020910d0 ***
 ======= Backtrace: =========
 /lib/libc.so.6(+0x71ab6)[0x7f7df3515ab6]
 /lib/libc.so.6(cfree+0x6c)[0x7f7df351a82c]
 /lib/libc.so.6(fclose+0x14d)[0x7f7df35069fd]
 /usr/lib/libgssglue.so.1(+0x46a0)[0x7f7df43426a0]
 /usr/lib/libgssglue.so.1(+0x47b7)[0x7f7df43427b7]
 /usr/lib/libgssglue.so.1(gss_indicate_mechs+0x2d)[0x7f7df434218d]
 /usr/sbin/rpc.gssd[0x403f4e]
 /usr/sbin/rpc.gssd[0x404368]
 /lib/libc.so.6(__libc_start_main+0xfd)[0x7f7df34c2c4d]
 /usr/sbin/rpc.gssd[0x4036f9]
 ======= Memory map: ========
 00400000-0040e000 r-xp 00000000 fe:01 83370
 /usr/sbin/rpc.gssd
 0060e000-00612000 rw-p 0000e000 fe:01 83370
 /usr/sbin/rpc.gssd
 00612000-00614000 rw-p 00000000 00:00 0 
 02091000-020b2000 rw-p 00000000 00:00 0
 [heap]
 7f7dec000000-7f7dec021000 rw-p 00000000 00:00 0 
 7f7dec021000-7f7df0000000 ---p 00000000 00:00 0 
 7f7df2a52000-7f7df2a67000 r-xp 00000000 08:15 561944
 /lib/libgcc_s.so.1
 7f7df2a67000-7f7df2c67000 ---p 00015000 08:15 561944
 /lib/libgcc_s.so.1
 7f7df2c67000-7f7df2c68000 rw-p 00015000 08:15 561944
 /lib/libgcc_s.so.1
 7f7df2c68000-7f7df2c7f000 r-xp 00000000 08:15 562192
 /lib/libpthread-2.11.2.so
 7f7df2c7f000-7f7df2e7e000 ---p 00017000 08:15 562192
 /lib/libpthread-2.11.2.so
 7f7df2e7e000-7f7df2e7f000 r--p 00016000 08:15 562192
 /lib/libpthread-2.11.2.so
 7f7df2e7f000-7f7df2e80000 rw-p 00017000 08:15 562192
 /lib/libpthread-2.11.2.so
 7f7df2e80000-7f7df2e84000 rw-p 00000000 00:00 0 
 7f7df2e84000-7f7df2e97000 r-xp 00000000 08:15 561995
 /lib/libresolv-2.11.2.so
 7f7df2e97000-7f7df3096000 ---p 00013000 08:15 561995
 /lib/libresolv-2.11.2.so
 7f7df3096000-7f7df3097000 r--p 00012000 08:15 561995
 /lib/libresolv-2.11.2.so
 7f7df3097000-7f7df3098000 rw-p 00013000 08:15 561995
 /lib/libresolv-2.11.2.so
 7f7df3098000-7f7df309a000 rw-p 00000000 00:00 0 
 7f7df309a000-7f7df309c000 r-xp 00000000 08:15 561964
 /lib/libkeyutils.so.1.3
 7f7df309c000-7f7df329b000 ---p 00002000 08:15 561964
 /lib/libkeyutils.so.1.3
 7f7df329b000-7f7df329c000 rw-p 00001000 08:15 561964
 /lib/libkeyutils.so.1.3
 7f7df329c000-7f7df32a3000 r-xp 00000000 fe:01 50300
 /usr/lib/libkrb5support.so.0.1
 7f7df32a3000-7f7df34a3000 ---p 00007000 fe:01 50300
 /usr/lib/libkrb5support.so.0.1
 7f7df34a3000-7f7df34a4000 rw-p 00007000 fe:01 50300
 /usr/lib/libkrb5support.so.0.1
 7f7df34a4000-7f7df35fc000 r-xp 00000000 08:15 562191
 /lib/libc-2.11.2.so
 7f7df35fc000-7f7df37fc000 ---p 00158000 08:15 562191
 /lib/libc-2.11.2.so
 7f7df37fc000-7f7df3800000 r--p 00158000 08:15 562191
 /lib/libc-2.11.2.so
 7f7df3800000-7f7df3801000 rw-p 0015c000 08:15 562191
 /lib/libc-2.11.2.so
 7f7df3801000-7f7df3806000 rw-p 00000000 00:00 0 
 7f7df3806000-7f7df3809000 r-xp 00000000 08:15 562017
 /lib/libcom_err.so.2.1
 7f7df3809000-7f7df3a08000 ---p 00003000 08:15 562017
 /lib/libcom_err.so.2.1
 7f7df3a08000-7f7df3a09000 rw-p 00002000 08:15 562017
 /lib/libcom_err.so.2.1
 7f7df3a09000-7f7df3a31000 r-xp 00000000 fe:01 49582
 /usr/lib/libk5crypto.so.3.1
 7f7df3a31000-7f7df3c30000 ---p 00028000 fe:01 49582
 /usr/lib/libk5crypto.so.3.1
 7f7df3c30000-7f7df3c32000 rw-p 00027000 fe:01 49582
 /usr/lib/libk5crypto.so.3.1
 7f7df3c32000-7f7df3cf4000 r-xp 00000000 fe:01 49613
 /usr/lib/libkrb5.so.3.3
 7f7df3cf4000-7f7df3ef3000 ---p 000c2000 fe:01 49613
 /usr/lib/libkrb5.so.3.3
 7f7df3ef3000-7f7df3efe000 rw-p 000c1000 fe:01 49613
 /usr/lib/libkrb5.so.3.3
 7f7df3efe000-7f7df3f38000 r-xp 00000000 fe:01 49585
 /usr/lib/libgssapi_krb5.so.2.2
 7f7df3f38000-7f7df4137000 ---p 0003a000 fe:01 49585
 /usr/lib/libgssapi_krb5.so.2.2
 7f7df4137000-7f7df413a000 rw-p 00039000 fe:01 49585
 /usr/lib/libgssapi_krb5.so.2.2
 7f7df413a000-7f7df413c000 r-xp 00000000 08:15 562187
 /lib/libdl-2.11.2.so
 7f7df413c000-7f7df433c000 ---p 00002000 08:15 562187
 /lib/libdl-2.11.2.so
 7f7df433c000-7f7df433d000 r--p 00002000 08:15 562187
 /lib/libdl-2.11.2.so
 7f7df433d000-7f7df433e000 rw-p 00003000 08:15 562187
 /lib/libdl-2.11.2.so
 7f7df433e000-7f7df4347000 r-xp 00000000 fe:01 50870
 /usr/lib/libgssglue.so.1.0.0
 7f7df4347000-7f7df4546000 ---p 00009000 fe:01 50870
 /usr/lib/libgssglue.so.1.0.0
 7f7df4546000-7f7df4547000 rw-p 00008000 fe:01 50870
 /usr/lib/libgssglue.so.1.0.0
 7f7df4547000-7f7df4556000 r-xp 00000000 fe:01 58365
 /usr/lib/librpcsecgss.so.3.0.0
 7f7df4556000-7f7df4755000 ---p 0000f000 fe:01 58365
 /usr/lib/librpcsecgss.so.3.0.0
 7f7df4755000-7f7df4756000 rw-p 0000e000 fe:01 58365
 /usr/lib/librpcsecgss.so.3.0.0
 7f7df4756000-7f7df4774000 r-xp 00000000 08:15 562300
 /lib/ld-2.11.2.so
 7f7df494a000-7f7df4951000 rw-p 00000000 00:00 0 
 7f7df4971000-7f7df4973000 rw-p 00000000 00:00 0 
 7f7df4973000-7f7df4974000 r--p 0001d000 08:15 562300
 /lib/ld-2.11.2.so
 7f7df4974000-7f7df4975000 rw-p 0001e000 08:15 562300
 /lib/ld-2.11.2.so
 7f7df4975000-7f7df4976000 rw-p 00000000 00:00 0 
 7fffd2983000-7fffd29a4000 rw-p 00000000 00:00 0
 [stack]
 7fffd29bc000-7fffd29bd000 r-xp 00000000 00:00 0
 [vdso]
 ffffffffff600000-ffffffffff601000 r-xp 00000000 00:00 0
 [vsyscall]
 /etc/init.d/nfs-common: regel 133:  6110 Afgebroken
 start-stop-daemon --start --oknodo --quiet --exec /usr/sbin/rpc.gssd --
 $RPCGSSDOPTS
                                                                                                                                                                                                         [fail

Since I use automount and several NFS4 kerberised mounts Nautilus fails
to launch due to this bug.


-- System Information:
Debian Release: wheezy/sid
  APT prefers unstable
  APT policy: (500, 'unstable')
Architecture: amd64 (x86_64)

Kernel: Linux 2.6.38-1-amd64 (SMP w/4 CPU cores)
Locale: LANG=nl_BE.utf8, LC_CTYPE=nl_BE.utf8 (charmap=UTF-8)
Shell: /bin/sh linked to /bin/dash

Versions of packages nfs-common depends on:
ii  adduser                  3.112+nmu2      add and remove users and groups
ii  initscripts              2.88dsf-13.1    scripts for initializing and shutt
ii  libc6                    2.11.2-13       Embedded GNU C Library: Shared lib
ii  libcap2                  1:2.20-1        support for getting/setting POSIX.
ii  libcomerr2               1.41.12-2       common error description library
ii  libevent-1.4-2           1.4.13-stable-1 An asynchronous event notification
ii  libgssapi-krb5-2         1.9+dfsg-1      MIT Kerberos runtime libraries - k
ii  libgssglue1              0.2-1           mechanism-switch gssapi library
ii  libk5crypto3             1.9+dfsg-1      MIT Kerberos runtime libraries - C
ii  libkrb5-3                1.9+dfsg-1      MIT Kerberos runtime libraries
ii  libnfsidmap2             0.24-1          An nfs idmapping library
ii  librpcsecgss3            0.19-2          allows secure rpc communication us
ii  libwrap0                 7.6.q-19        Wietse Venema's TCP wrappers libra
ii  lsb-base                 3.2-27          Linux Standard Base 3.2 init scrip
ii  netbase                  4.45            Basic TCP/IP networking system
ii  portmap                  6.0.0-3         RPC port mapper
ii  ucf                      3.0025+nmu1     Update Configuration File: preserv

nfs-common recommends no packages.

nfs-common suggests no packages.

-- no debconf information






--4Ckj6UjgE2iN1+kY--
