From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: [BUG][PATCH] lockd won't work 248 days after booting.
Date: Thu, 07 Nov 2002 18:42:13 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021107.184213.39457110.taka@valinux.co.jp>
References: <20021107.183516.95909668.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 189jJ9-0007Jt-00
	for <nfs@lists.sourceforge.net>; Thu, 07 Nov 2002 01:50:39 -0800
Received: from localhost (gw1.valinux.co.jp [202.221.173.98])
	by sv1.valinux.co.jp (Postfix) with ESMTP id 37A0870021
	for <nfs@lists.sourceforge.net>; Thu,  7 Nov 2002 18:50:32 +0900 (JST)
To: nfs@lists.sourceforge.net
In-Reply-To: <20021107.183516.95909668.taka@valinux.co.jp>
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

Hello,

> I think lockd has jiffies wraparound problems.
> It's wrong that lockd set some timers to zero in hope that
> it'll exipre soon. But time_before() and time_after() won't
> work 248 days after booting.


We can check jiffies wraparound problems with a following patch.



--- kernel/timer.c.JIF	Tue Nov  5 17:13:00 2030
+++ kernel/timer.c	Tue Nov  5 21:27:58 2030
@@ -1094,6 +1094,7 @@ static void __devinit init_timers_cpu(in
 {
 	int j;
 	tvec_base_t *base;
+	unsigned long jif = jiffies;
        
 	base = &per_cpu(tvec_bases, cpu);
 	spin_lock_init(&base->lock);
@@ -1105,6 +1106,18 @@ static void __devinit init_timers_cpu(in
 	}
 	for (j = 0; j < TVR_SIZE; j++)
 		INIT_LIST_HEAD(base->tv1.vec + j);
+
+	base->timer_jiffies = jif;
+	base->tv1.index = jif & TVR_MASK;
+	jif >>= TVR_BITS;
+	base->tv2.index = jif & TVN_MASK;
+	jif >>= TVN_BITS;
+	base->tv3.index = jif & TVN_MASK;
+	jif >>= TVN_BITS;
+	base->tv4.index = jif & TVN_MASK;
+	jif >>= TVN_BITS;
+	base->tv5.index = jif & TVN_MASK;
+
 	tasklet_init(&per_cpu(timer_tasklet, cpu), run_timer_tasklet, 0UL);
 }
 	
@@ -1126,9 +1139,22 @@ static struct notifier_block __devinitda
 	.notifier_call	= timer_cpu_notify,
 };
 
+static int __init
+jiffies_setup(char *str)
+{
+	char *cur = str;
+	jiffies = simple_strtoul(cur, &cur, 0);
+	printk(KERN_INFO "jiffies is initialized to 0x%lx\n", jiffies);
+	return 1;
+}
+
+__setup("jiffies=", jiffies_setup);
 
 void __init init_timers(void)
 {
+	jiffies_64 = jiffies;
+	wall_jiffies = jiffies;
+
 	timer_cpu_notify(&timers_nb, (unsigned long)CPU_UP_PREPARE,
 				(void *)(long)smp_processor_id());
 	register_cpu_notifier(&timers_nb);


-------------------------------------------------------
This sf.net email is sponsored by: See the NEW Palm 
Tungsten T handheld. Power & Color in a compact size!
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
