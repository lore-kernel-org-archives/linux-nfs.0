From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: PATCH - > 256 NFS mounts. Was: Re: Linux NFS FAQ updates
Date: Thu, 8 May 2003 11:02:18 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16057.44186.465124.590551@notabene.cse.unsw.edu.au>
References: <6440EA1A6AA1D5118C6900902745938E07D55565@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19DZnj-0005el-00
	for <nfs@lists.sourceforge.net>; Wed, 07 May 2003 18:02:23 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <Charles.Lever@netapp.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Thu, 8 May 2003 11:02:16 +1000
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: message from Lever, Charles on Thursday April 24
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

On Thursday April 24, Charles.Lever@netapp.com wrote:

>                       and question B3 discusses the
> "255 NFS mounts per client" limitation.

You could add something more to this section if you like....

"It is possible to exceed the limit of 256 filesystems using 
<a href="See Below">this</a> patch.  It utilised 3 more major numbers
(which have been allocated by lanana) and so allows upto
1024 non-device mounts (such as NFS).
This patch does <b>not</b> address issues of running out of privileged 
ports and so the effective limit is still well below 1024 ( but can be
maximised by mixing UDP and TCP mounts)."

I will probably submit this patch for inclusion in 2.4.22-pre1.

In the mean time I would welcome success/failure reports.

NeilBrown

----------------------------------
Allow more than 256 nfs mounts

Utilise 3 extra major device numbers for anonymous
devices so that more than 256 NFS mounts are possible.

 ----------- Diffstat output ------------
 ./fs/super.c            |   22 +++++++++++++++++-----
 ./include/linux/major.h |    7 +++++++
 2 files changed, 24 insertions(+), 5 deletions(-)

diff ./fs/super.c~current~ ./fs/super.c
--- ./fs/super.c~current~	2003-05-08 09:58:56.000000000 +1000
+++ ./fs/super.c	2003-05-08 10:51:26.000000000 +1000
@@ -572,7 +572,14 @@ int do_remount_sb(struct super_block *sb
  * filesystems which don't use real block-devices.  -- jrs
  */
 
-enum {Max_anon = 256};
+static int anon_majors[]= {UNNAMED_MAJOR, 
+			   UNNAMED_MAJOR_1, 
+			   UNNAMED_MAJOR_2,
+			   UNNAMED_MAJOR_3,
+};
+#define	num_anon_majors (sizeof(anon_majors)/sizeof(anon_majors[0]))
+#define Max_anon (num_anon_majors<<8)
+
 static unsigned long unnamed_dev_in_use[Max_anon/(8*sizeof(unsigned long))];
 static spinlock_t unnamed_dev_lock = SPIN_LOCK_UNLOCKED;/* protects the above */
 
@@ -582,9 +589,14 @@ static spinlock_t unnamed_dev_lock = SPI
  */
 static void put_anon_dev(kdev_t dev)
 {
-	spin_lock(&unnamed_dev_lock);
-	clear_bit(MINOR(dev), unnamed_dev_in_use);
-	spin_unlock(&unnamed_dev_lock);
+	int i;
+	for (i=0; i<num_anon_majors; i++)
+		if (MAJOR(dev) == anon_majors[i]) {
+			spin_lock(&unnamed_dev_lock);
+			clear_bit(MINOR(dev)+(i<<8), unnamed_dev_in_use);
+			spin_unlock(&unnamed_dev_lock);
+			break;
+		}
 }
 
 /**
@@ -643,7 +655,7 @@ retry:
 	set_bit(dev, unnamed_dev_in_use);
 	spin_unlock(&unnamed_dev_lock);
 
-	s->s_dev = dev;
+	s->s_dev = MKDEV(anon_majors[dev>>8],dev&255);
 	insert_super(s, type);
 	return s;
 }

diff ./include/linux/major.h~current~ ./include/linux/major.h
--- ./include/linux/major.h~current~	2003-05-08 09:59:26.000000000 +1000
+++ ./include/linux/major.h	2003-05-08 10:05:42.000000000 +1000
@@ -143,6 +143,13 @@
 
 #define	UMEM_MAJOR	116	/* http://www.umem.com/ Battery Backed RAM */
 
+/* combined with UNNAMED_MAJOR, these allow upto
+ * 1024 non device (e.g. nfs) mounts
+ */
+#define	UNNAMED_MAJOR_1	144
+#define	UNNAMED_MAJOR_2	145
+#define	UNNAMED_MAJOR_3 146
+
 #define RTF_MAJOR	150
 #define RAW_MAJOR	162
 


-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
