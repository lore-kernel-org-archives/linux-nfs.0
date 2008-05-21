From: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Subject: [PATCH] usb-storage: don't call utsname()
Date: Wed, 21 May 2008 13:51:17 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.0805211349480.3409-100000@iolanthe.rowland.org>
References: <20080521123700.GA8770@infradead.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Christoph Hellwig <hch@infradead.org>,
	"Frank Ch. Eigler" <fche@redhat.com>,
	Adrian Bunk <bunk@kernel.org>,
	USB Storage list <usb-storage-ijkIwGHArpdIPJnuZ7Njw4oP9KaGy4wf@public.gmane.org>,
	Kernel development list <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem-xgOahHnHvIuGfricDzPwBeTW4wlIGRCZ@public.gmane.org>,
	<systemtap-R2MHTz/CkKAf7BdofF/totBPR1lH4CV8@public.gmane.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	<linux-cifs-client@lists.samba.org>, <linux-nfs@vger.kernel.org>
To: Greg KH <greg@kroah.com>,
	Matthew Dharm <mdharm-usb-JGfshJpz5UybPZpvUQj5UqxOck334EZe@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from iolanthe.rowland.org ([192.131.102.54]:60468 "HELO
	iolanthe.rowland.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1757839AbYEURvS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 May 2008 13:51:18 -0400
In-Reply-To: <20080521123700.GA8770@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch (as1100) replaces the core-kernel function call to utsname()
in usb-storage with the UTS_RELEASE macro.  It's used only for warning
about extra unusual_devs entries.

Signed-off-by: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>

---

Index: usb-2.6/drivers/usb/storage/usb.c
===================================================================
--- usb-2.6.orig/drivers/usb/storage/usb.c
+++ usb-2.6/drivers/usb/storage/usb.c
@@ -53,7 +53,7 @@
 #include <linux/slab.h>
 #include <linux/kthread.h>
 #include <linux/mutex.h>
-#include <linux/utsname.h>
+#include <linux/utsrelease.h>
 
 #include <scsi/scsi.h>
 #include <scsi/scsi_cmnd.h>
@@ -531,8 +531,8 @@ static int get_device_info(struct us_dat
 		if (msg >= 0 && !(us->fflags & US_FL_NEED_OVERRIDE))
 			printk(KERN_NOTICE USB_STORAGE "This device "
 				"(%04x,%04x,%04x S %02x P %02x)"
-				" has %s in unusual_devs.h (kernel"
-				" %s)\n"
+				" has %s in unusual_devs.h (kernel "
+				UTS_RELEASE ")\n"
 				"   Please send a copy of this message to "
 				"<linux-usb@vger.kernel.org> and "
 				"<usb-storage-ijkIwGHArpdIPJnuZ7Njw4oP9KaGy4wf@public.gmane.org>\n",
@@ -541,8 +541,7 @@ static int get_device_info(struct us_dat
 				le16_to_cpu(ddesc->bcdDevice),
 				idesc->bInterfaceSubClass,
 				idesc->bInterfaceProtocol,
-				msgs[msg],
-				utsname()->release);
+				msgs[msg]);
 	}
 
 	return 0;

