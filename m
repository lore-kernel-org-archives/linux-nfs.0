From: David Greaves <david@dgreaves.com>
Subject: [PATCH] Makes nfs mount warning less frequent and more valuable
Date: Wed, 16 Mar 2005 15:06:01 +0000
Message-ID: <42384B59.3060408@dgreaves.com>
References: <4237178A.5030003@dgreaves.com> <Pine.LNX.4.61.0503151439250.22235@guppy.limebrokerage.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060809060100040506020404"
Cc: Ion Badulescu <ionut@badula.org>, Erez Zadok <ezk@cs.sunysb.edu>,
	am-utils@fsl.cs.sunysb.edu, nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DBa65-0002wM-7d
	for nfs@lists.sourceforge.net; Wed, 16 Mar 2005 07:06:09 -0800
Received: from s2.ukfsn.org ([217.158.120.143] helo=mail.ukfsn.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DBa63-0005wS-G2
	for nfs@lists.sourceforge.net; Wed, 16 Mar 2005 07:06:09 -0800
To: neilb@cse.unsw.edu.au
In-Reply-To: <Pine.LNX.4.61.0503151439250.22235@guppy.limebrokerage.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This is a multi-part message in MIME format.
--------------060809060100040506020404
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Neil,

This is in response to an ongoing quest to shut the kernel up when it 
whines:
   kernel: nfs warning: mount version older than kernel
incessantly and uselessly, I spoke to the am-utils people and eventually 
got some help tracking it down.

Googling around the error reveals many, many confused souls and no 
obvious reason for the message.

Ion Badulescu wrote:

> David,
>
> The basic answer is: don't worry about it, it's not harmful in any way.
>
> Until amd supports NFSv4, it will continue to cause the kernel to 
> print out this message. I've always questioned the usefulness of this 
> message, given that v2 and v3 clients (and mount programs) are fully 
> supported and will continue to be for the foreseeable future, but it 
> never bothered me enough to do something about it.

So is this the logic to produce a potentially useful warning?
patch is against 2.6.11

(This code is only executed at mount time so I assume the minor 
additional logic for a mere warning is acceptable)

It certainly makes life quieter with heavily automounted systems.


Signed-off-by: David Greaves <david@dgreaves.com>


--------------060809060100040506020404
Content-Type: text/plain;
 name="inode.c.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="inode.c.patch"

--- fs/nfs/inode.c.orig	2005-03-15 16:12:07.000000000 +0000
+++ fs/nfs/inode.c	2005-03-16 13:42:13.000000000 +0000
@@ -1385,9 +1385,19 @@ static struct super_block *nfs_get_sb(st
 	/* Zero out the NFS state stuff */
 	init_nfsv4_state(server);
 
+	/* NFS v2 and v3 are interoperable and will continue to be so..
+	 * This should be reviewed when NFS_MOUNT_VERSION increments */
+	if ((data->version <2 ||
+	     data->version >6 ||
+	     NFS_MOUNT_VERSION < 2 ||
+	     NFS_MOUNT_VERSION > 6)
+	    && data->version != NFS_MOUNT_VERSION) {
+		printk("nfs warning: possibly dangerous mount version incompatibility: mount(v%d) %s than kernel(v%d)\n",
+		       data->version, data->version < NFS_MOUNT_VERSION ? "older" : "newer", NFS_MOUNT_VERSION);
+	}
+	
+	/* All <> values of NFS_MOUNT_VERSION 2..6 are handled */
 	if (data->version != NFS_MOUNT_VERSION) {
-		printk("nfs warning: mount version %s than kernel\n",
-			data->version < NFS_MOUNT_VERSION ? "older" : "newer");
 		if (data->version < 2)
 			data->namlen = 0;
 		if (data->version < 3)

--------------060809060100040506020404--


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
