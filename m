From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [RFC][Resend] Make NFS-Client readahead tunable
Date: Thu, 18 Sep 2008 15:20:48 +0200
Message-ID: <1221744048.15314.30.camel@lappy.programming.kicks-ass.net>
References: <124712.40022.qm@web32602.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Greg Banks <gnb@melbourne.sgi.com>,
	linux-nfs list <linux-nfs@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: Martin Knoblauch <knobi@knobisoft.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756162AbYIRNVV@vger.kernel.org>
In-Reply-To: <124712.40022.qm@web32602.mail.mud.yahoo.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2008-09-18 at 01:38 -0700, Martin Knoblauch wrote:

>  I believe Peter wanted to add per bdi stuff for nfs some time ago. Not sure what came out of it.

$ mount localhost:/ /mnt/tmp
$ grep nfs /proc/$$/mountinfo
21 17 0:17 / /var/lib/nfs/rpc_pipefs rw - rpc_pipefs rpc_pipefs rw
31 13 0:20 / /proc/fs/nfsd rw - nfsd nfsd rw
37 17 0:22 / /mnt/tmp rw - nfs localhost:/ rw,vers=3,rsize=65536,wsize=65536,namlen=255,hard,nointr,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=127.0.0.1,mountvers=3,mountproto=tcp,addr=127.0.0.1
$ ls -la /sys/class/bdi/0\:22/
total 0
drwxr-xr-x  3 root root    0 2008-09-18 15:16 .
drwxr-xr-x 21 root root    0 2008-09-18 15:16 ..
-rw-r--r--  1 root root 4096 2008-09-18 15:19 max_ratio
-rw-r--r--  1 root root 4096 2008-09-18 15:19 min_ratio
drwxr-xr-x  2 root root    0 2008-09-18 15:19 power
-rw-r--r--  1 root root 4096 2008-09-18 15:19 read_ahead_kb
lrwxrwxrwx  1 root root    0 2008-09-18 15:19 subsystem -> ../../bdi
-rw-r--r--  1 root root 4096 2008-09-18 15:19 uevent
$ cat /sys/class/bdi/0\:22/read_ahead_kb
960
