From: Chip Salzenberg <chip@pobox.com>
Subject: [PATCH] Require nfs-utils 1.0.5; document where to get it
Date: Tue, 29 Jul 2003 13:52:28 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20030729205227.GA16486@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Linus Torvalds <torvalds@transmeta.com>
List-ID: <nfs.lists.sourceforge.net>

The below patch to 2.6 notes that users should get nfs-utils 1.0.5
(1.0.3 had a security bug and 1.0.4 had a memory usage bug), and tells
them where to get it.

--- linux-2.6/Documentation/Changes	2003-07-16 15:54:46.000000000 -0700
+++ linux-2.6/Documentation/Changes.NEW	2003-07-29 13:47:56.000000000 -0700
@@ -64,5 +64,5 @@
 o  procps                 2.0.9                   # ps --version
 o  oprofile               0.5.3                   # oprofiled --version
-o  nfs-utils              1.0.3                   # showmount --version
+o  nfs-utils              1.0.5                   # showmount --version
 
 Kernel compilation
@@ -382,5 +382,10 @@
 --------
 o  <http://oprofile.sf.net/download/>
- 
+
+NFS-Utils
+---------
+o  <http://nfs.sourceforge.net/>
+
+
 Suggestions and corrections
 ===========================



-- 
Chip Salzenberg               - a.k.a. -               <chip@pobox.com>
"I wanted to play hopscotch with the impenetrable mystery of existence,
    but he stepped in a wormhole and had to go in early."  // MST3K
