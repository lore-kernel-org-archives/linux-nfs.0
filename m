Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:42361 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755373Ab1HRIRU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Aug 2011 04:17:20 -0400
Date: Thu, 18 Aug 2011 18:17:00 +1000
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH] Update addres for Free Software Foundation
Message-ID: <20110818181700.2e808b98@notabene.brown>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


License texts contain multiple address for FSF, some wrong.
So update them and  replace COPYING file with
http://www.gnu.org/licenses/gpl-2.0.txt
which has a few changes to preamble and commentary.

Also remove extra COPYING file from utils/statd/

Signed-off-by: NeilBrown <neilb@suse.de>

--

Probably not the most important patch in the world, but I think it is worth
keeping this text consistent.

diff --git a/COPYING b/COPYING
index 60549be..d159169 100644
--- a/COPYING
+++ b/COPYING
@@ -1,12 +1,12 @@
-		    GNU GENERAL PUBLIC LICENSE
-		       Version 2, June 1991
+                    GNU GENERAL PUBLIC LICENSE
+                       Version 2, June 1991
 
- Copyright (C) 1989, 1991 Free Software Foundation, Inc.
-                       59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ Copyright (C) 1989, 1991 Free Software Foundation, Inc.,
+ 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  Everyone is permitted to copy and distribute verbatim copies
  of this license document, but changing it is not allowed.
 
-			    Preamble
+                            Preamble
 
   The licenses for most software are designed to take away your
 freedom to share and change it.  By contrast, the GNU General Public
@@ -15,7 +15,7 @@ software--to make sure the software is free for all its users.  This
 General Public License applies to most of the Free Software
 Foundation's software and to any other program whose authors commit to
 using it.  (Some other Free Software Foundation software is covered by
-the GNU Library General Public License instead.)  You can apply it to
+the GNU Lesser General Public License instead.)  You can apply it to
 your programs, too.
 
   When we speak of free software, we are referring to freedom, not
@@ -55,8 +55,8 @@ patent must be licensed for everyone's free use or not licensed at all.
 
   The precise terms and conditions for copying, distribution and
 modification follow.
-
-		    GNU GENERAL PUBLIC LICENSE
+
+                    GNU GENERAL PUBLIC LICENSE
    TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
 
   0. This License applies to any program or other work which contains
@@ -110,7 +110,7 @@ above, provided that you also meet all of these conditions:
     License.  (Exception: if the Program itself is interactive but
     does not normally print such an announcement, your work based on
     the Program is not required to print an announcement.)
-
+
 These requirements apply to the modified work as a whole.  If
 identifiable sections of that work are not derived from the Program,
 and can be reasonably considered independent and separate works in
@@ -168,7 +168,7 @@ access to copy from a designated place, then offering equivalent
 access to copy the source code from the same place counts as
 distribution of the source code, even though third parties are not
 compelled to copy the source along with the object code.
-
+
   4. You may not copy, modify, sublicense, or distribute the Program
 except as expressly provided under this License.  Any attempt
 otherwise to copy, modify, sublicense or distribute the Program is
@@ -225,7 +225,7 @@ impose that choice.
 
 This section is intended to make thoroughly clear what is believed to
 be a consequence of the rest of this License.
-
+
   8. If the distribution and/or use of the Program is restricted in
 certain countries either by patents or by copyrighted interfaces, the
 original copyright holder who places the Program under this License
@@ -255,7 +255,7 @@ make exceptions for this.  Our decision will be guided by the two goals
 of preserving the free status of all derivatives of our free software and
 of promoting the sharing and reuse of software generally.
 
-			    NO WARRANTY
+                            NO WARRANTY
 
   11. BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
 FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW.  EXCEPT WHEN
@@ -277,9 +277,9 @@ YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER
 PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGES.
 
-		     END OF TERMS AND CONDITIONS
-
-	    How to Apply These Terms to Your New Programs
+                     END OF TERMS AND CONDITIONS
+
+            How to Apply These Terms to Your New Programs
 
   If you develop a new program, and you want it to be of the greatest
 possible use to the public, the best way to achieve this is to make it
@@ -291,7 +291,7 @@ convey the exclusion of warranty; and each file should have at least
 the "copyright" line and a pointer to where the full notice is found.
 
     <one line to give the program's name and a brief idea of what it does.>
-    Copyright (C) 19yy  <name of author>
+    Copyright (C) <year>  <name of author>
 
     This program is free software; you can redistribute it and/or modify
     it under the terms of the GNU General Public License as published by
@@ -303,17 +303,16 @@ the "copyright" line and a pointer to where the full notice is found.
     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
     GNU General Public License for more details.
 
-    You should have received a copy of the GNU General Public License
-    along with this program; if not, write to the Free Software
-    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
-
+    You should have received a copy of the GNU General Public License along
+    with this program; if not, write to the Free Software Foundation, Inc.,
+    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 
 Also add information on how to contact you by electronic and paper mail.
 
 If the program is interactive, make it output a short notice like this
 when it starts in an interactive mode:
 
-    Gnomovision version 69, Copyright (C) 19yy name of author
+    Gnomovision version 69, Copyright (C) year name of author
     Gnomovision comes with ABSOLUTELY NO WARRANTY; for details type `show w'.
     This is free software, and you are welcome to redistribute it
     under certain conditions; type `show c' for details.
@@ -336,5 +335,5 @@ necessary.  Here is a sample; alter the names:
 This General Public License does not permit incorporating your program into
 proprietary programs.  If your program is a subroutine library, you may
 consider it more useful to permit linking proprietary applications with the
-library.  If this is what you want to do, use the GNU Library General
+library.  If this is what you want to do, use the GNU Lesser General
 Public License instead of this License.
diff --git a/support/include/nfsrpc.h b/support/include/nfsrpc.h
index d50fe94..a0b80e1 100644
--- a/support/include/nfsrpc.h
+++ b/support/include/nfsrpc.h
@@ -15,8 +15,8 @@
  *
  * You should have received a copy of the GNU General Public
  * License along with this program; if not, write to the
- * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
- * Boston, MA 021110-1307, USA.
+ * Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  *
  */
 
diff --git a/support/nfs/getport.c b/support/nfs/getport.c
index d74400b..3331ad4 100644
--- a/support/nfs/getport.c
+++ b/support/nfs/getport.c
@@ -17,8 +17,8 @@
  *
  * You should have received a copy of the GNU General Public
  * License along with this program; if not, write to the
- * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
- * Boston, MA 021110-1307, USA.
+ * Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  *
  */
 
diff --git a/support/nfs/rpc_socket.c b/support/nfs/rpc_socket.c
index c14efe8..7896cd2 100644
--- a/support/nfs/rpc_socket.c
+++ b/support/nfs/rpc_socket.c
@@ -15,8 +15,8 @@
  *
  * You should have received a copy of the GNU General Public
  * License along with this program; if not, write to the
- * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
- * Boston, MA 021110-1307, USA.
+ * Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  *
  */
 
diff --git a/support/nfs/svc_socket.c b/support/nfs/svc_socket.c
index c252f53..f56f310 100644
--- a/support/nfs/svc_socket.c
+++ b/support/nfs/svc_socket.c
@@ -13,8 +13,8 @@
 
    You should have received a copy of the GNU Lesser General Public
    License along with the GNU C Library; if not, write to the Free
-   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
-   02111-1307 USA.  */
+   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
+   Boston, MA 0211-1301 USA */
 
 #include <stdio.h>
 #include <string.h>
diff --git a/tests/t0001-statd-basic-mon-unmon.sh b/tests/t0001-statd-basic-mon-unmon.sh
index 00127fb..51f0d22 100755
--- a/tests/t0001-statd-basic-mon-unmon.sh
+++ b/tests/t0001-statd-basic-mon-unmon.sh
@@ -16,7 +16,7 @@
 #
 # You should have received a copy of the GNU General Public License
 # along with this program; if not, write to the Free Software Foundation, Inc.,
-# 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
+* 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
 #
 
 . ./test-lib.sh
diff --git a/tests/test-lib.sh b/tests/test-lib.sh
index 3d47264..ce4ecff 100644
--- a/tests/test-lib.sh
+++ b/tests/test-lib.sh
@@ -16,7 +16,7 @@
 #
 # You should have received a copy of the GNU General Public License
 # along with this program; if not, write to the Free Software Foundation, Inc.,
-# 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
+* 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
 #
 
 # make sure $srcdir is set and sanity check it
diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
index c475c9e..280e15c 100644
--- a/tools/mountstats/mountstats.py
+++ b/tools/mountstats/mountstats.py
@@ -17,7 +17,8 @@ GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
-Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
+MA 02110-1301 USA
 """
 
 import sys, os, time
diff --git a/tools/nfs-iostat/nfs-iostat.py b/tools/nfs-iostat/nfs-iostat.py
index 1207674..4e55dad 100644
--- a/tools/nfs-iostat/nfs-iostat.py
+++ b/tools/nfs-iostat/nfs-iostat.py
@@ -17,7 +17,8 @@ GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
-Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
+MA 02110-1301 USA
 """
 
 import sys, os, time
diff --git a/utils/mount/error.c b/utils/mount/error.c
index 1b64bd7..83ad1d2 100644
--- a/utils/mount/error.c
+++ b/utils/mount/error.c
@@ -16,8 +16,8 @@
  *
  * You should have received a copy of the GNU General Public
  * License along with this program; if not, write to the
- * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
- * Boston, MA 021110-1307, USA.
+ * Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  *
  * To Do:
  *  + Proper support for internationalization
diff --git a/utils/mount/error.h b/utils/mount/error.h
index 42b28cf..ef80fd0 100644
--- a/utils/mount/error.h
+++ b/utils/mount/error.h
@@ -16,8 +16,8 @@
  *
  * You should have received a copy of the GNU General Public
  * License along with this program; if not, write to the
- * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
- * Boston, MA 021110-1307, USA.
+ * Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  *
  */
 
diff --git a/utils/mount/mount_libmount.c b/utils/mount/mount_libmount.c
index cf6e58c..e450d79 100644
--- a/utils/mount/mount_libmount.c
+++ b/utils/mount/mount_libmount.c
@@ -15,8 +15,8 @@
  *
  * You should have received a copy of the GNU General Public
  * License along with this program; if not, write to the
- * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
- * Boston, MA 021110-1307, USA.
+ * Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  *
  */
 
diff --git a/utils/mount/network.c b/utils/mount/network.c
index d1f91dc..e7bd522 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -16,8 +16,8 @@
  *
  * You should have received a copy of the GNU General Public
  * License along with this program; if not, write to the
- * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
- * Boston, MA 021110-1307, USA.
+ * Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  *
  */
 
diff --git a/utils/mount/network.h b/utils/mount/network.h
index 81c6f22..9c75856 100644
--- a/utils/mount/network.h
+++ b/utils/mount/network.h
@@ -16,8 +16,8 @@
  *
  * You should have received a copy of the GNU General Public
  * License along with this program; if not, write to the
- * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
- * Boston, MA 021110-1307, USA.
+ * Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  *
  */
 
diff --git a/utils/mount/parse_dev.c b/utils/mount/parse_dev.c
index c8a58b1..d64b83d 100644
--- a/utils/mount/parse_dev.c
+++ b/utils/mount/parse_dev.c
@@ -15,8 +15,8 @@
  *
  * You should have received a copy of the GNU General Public
  * License along with this program; if not, write to the
- * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
- * Boston, MA 021110-1307, USA.
+ * Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  *
  */
 
diff --git a/utils/mount/parse_dev.h b/utils/mount/parse_dev.h
index a1288c2..f9857bc 100644
--- a/utils/mount/parse_dev.h
+++ b/utils/mount/parse_dev.h
@@ -15,8 +15,8 @@
  *
  * You should have received a copy of the GNU General Public
  * License along with this program; if not, write to the
- * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
- * Boston, MA 021110-1307, USA.
+ * Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  *
  */
 
diff --git a/utils/mount/parse_opt.c b/utils/mount/parse_opt.c
index ab869d9..75a0daa 100644
--- a/utils/mount/parse_opt.c
+++ b/utils/mount/parse_opt.c
@@ -16,8 +16,8 @@
  *
  * You should have received a copy of the GNU General Public
  * License along with this program; if not, write to the
- * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
- * Boston, MA 021110-1307, USA.
+ * Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  *
  */
 
diff --git a/utils/mount/parse_opt.h b/utils/mount/parse_opt.h
index 2c0b5f4..5037207 100644
--- a/utils/mount/parse_opt.h
+++ b/utils/mount/parse_opt.h
@@ -16,8 +16,8 @@
  *
  * You should have received a copy of the GNU General Public
  * License along with this program; if not, write to the
- * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
- * Boston, MA 021110-1307, USA.
+ * Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  *
  */
 
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 4d023d6..7a2edab 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -16,8 +16,8 @@
  *
  * You should have received a copy of the GNU General Public
  * License along with this program; if not, write to the
- * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
- * Boston, MA 021110-1307, USA.
+ * Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  *
  */
 
diff --git a/utils/mount/stropts.h b/utils/mount/stropts.h
index b4fd888..37316eb 100644
--- a/utils/mount/stropts.h
+++ b/utils/mount/stropts.h
@@ -16,8 +16,8 @@
  *
  * You should have received a copy of the GNU General Public
  * License along with this program; if not, write to the
- * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
- * Boston, MA 021110-1307, USA.
+ * Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  *
  */
 
diff --git a/utils/mount/token.c b/utils/mount/token.c
index 5ef9604..d7e2f4a 100644
--- a/utils/mount/token.c
+++ b/utils/mount/token.c
@@ -16,8 +16,8 @@
  *
  * You should have received a copy of the GNU General Public
  * License along with this program; if not, write to the
- * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
- * Boston, MA 021110-1307, USA.
+ * Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  *
  */
 
diff --git a/utils/mount/token.h b/utils/mount/token.h
index 5a675ed..17a9c15 100644
--- a/utils/mount/token.h
+++ b/utils/mount/token.h
@@ -16,8 +16,8 @@
  *
  * You should have received a copy of the GNU General Public
  * License along with this program; if not, write to the
- * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
- * Boston, MA 021110-1307, USA.
+ * Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  *
  */
 
diff --git a/utils/mount/utils.c b/utils/mount/utils.c
index 298db39..2778ed7 100644
--- a/utils/mount/utils.c
+++ b/utils/mount/utils.c
@@ -13,8 +13,8 @@
  *
  * You should have received a copy of the GNU General Public
  * License along with this program; if not, write to the
- * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
- * Boston, MA 021110-1307, USA.
+ * Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  *
  */
 
diff --git a/utils/mount/utils.h b/utils/mount/utils.h
index 3fcd504..224918a 100644
--- a/utils/mount/utils.h
+++ b/utils/mount/utils.h
@@ -15,8 +15,8 @@
  *
  * You should have received a copy of the GNU General Public
  * License along with this program; if not, write to the
- * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
- * Boston, MA 021110-1307, USA.
+ * Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  *
  */
 
diff --git a/utils/mount/version.h b/utils/mount/version.h
index 531cf68..d7cf680 100644
--- a/utils/mount/version.h
+++ b/utils/mount/version.h
@@ -15,8 +15,8 @@
  *
  * You should have received a copy of the GNU General Public
  * License along with this program; if not, write to the
- * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
- * Boston, MA 021110-1307, USA.
+ * Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  *
  */
 
diff --git a/utils/nfsd/nfssvc.h b/utils/nfsd/nfssvc.h
index 1a01cec..08de0fe 100644
--- a/utils/nfsd/nfssvc.h
+++ b/utils/nfsd/nfssvc.h
@@ -16,7 +16,7 @@
  *
  * You should have received a copy of the GNU General Public License along
  * with this program; if not, write to the Free Software Foundation, Inc.,
- * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
+ * 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  *
  */
 
diff --git a/utils/statd/COPYING b/utils/statd/COPYING
deleted file mode 100644
index 60549be..0000000
--- a/utils/statd/COPYING
+++ /dev/null
@@ -1,340 +0,0 @@
-		    GNU GENERAL PUBLIC LICENSE
-		       Version 2, June 1991
-
- Copyright (C) 1989, 1991 Free Software Foundation, Inc.
-                       59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
- Everyone is permitted to copy and distribute verbatim copies
- of this license document, but changing it is not allowed.
-
-			    Preamble
-
-  The licenses for most software are designed to take away your
-freedom to share and change it.  By contrast, the GNU General Public
-License is intended to guarantee your freedom to share and change free
-software--to make sure the software is free for all its users.  This
-General Public License applies to most of the Free Software
-Foundation's software and to any other program whose authors commit to
-using it.  (Some other Free Software Foundation software is covered by
-the GNU Library General Public License instead.)  You can apply it to
-your programs, too.
-
-  When we speak of free software, we are referring to freedom, not
-price.  Our General Public Licenses are designed to make sure that you
-have the freedom to distribute copies of free software (and charge for
-this service if you wish), that you receive source code or can get it
-if you want it, that you can change the software or use pieces of it
-in new free programs; and that you know you can do these things.
-
-  To protect your rights, we need to make restrictions that forbid
-anyone to deny you these rights or to ask you to surrender the rights.
-These restrictions translate to certain responsibilities for you if you
-distribute copies of the software, or if you modify it.
-
-  For example, if you distribute copies of such a program, whether
-gratis or for a fee, you must give the recipients all the rights that
-you have.  You must make sure that they, too, receive or can get the
-source code.  And you must show them these terms so they know their
-rights.
-
-  We protect your rights with two steps: (1) copyright the software, and
-(2) offer you this license which gives you legal permission to copy,
-distribute and/or modify the software.
-
-  Also, for each author's protection and ours, we want to make certain
-that everyone understands that there is no warranty for this free
-software.  If the software is modified by someone else and passed on, we
-want its recipients to know that what they have is not the original, so
-that any problems introduced by others will not reflect on the original
-authors' reputations.
-
-  Finally, any free program is threatened constantly by software
-patents.  We wish to avoid the danger that redistributors of a free
-program will individually obtain patent licenses, in effect making the
-program proprietary.  To prevent this, we have made it clear that any
-patent must be licensed for everyone's free use or not licensed at all.
-
-  The precise terms and conditions for copying, distribution and
-modification follow.
-
-		    GNU GENERAL PUBLIC LICENSE
-   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
-
-  0. This License applies to any program or other work which contains
-a notice placed by the copyright holder saying it may be distributed
-under the terms of this General Public License.  The "Program", below,
-refers to any such program or work, and a "work based on the Program"
-means either the Program or any derivative work under copyright law:
-that is to say, a work containing the Program or a portion of it,
-either verbatim or with modifications and/or translated into another
-language.  (Hereinafter, translation is included without limitation in
-the term "modification".)  Each licensee is addressed as "you".
-
-Activities other than copying, distribution and modification are not
-covered by this License; they are outside its scope.  The act of
-running the Program is not restricted, and the output from the Program
-is covered only if its contents constitute a work based on the
-Program (independent of having been made by running the Program).
-Whether that is true depends on what the Program does.
-
-  1. You may copy and distribute verbatim copies of the Program's
-source code as you receive it, in any medium, provided that you
-conspicuously and appropriately publish on each copy an appropriate
-copyright notice and disclaimer of warranty; keep intact all the
-notices that refer to this License and to the absence of any warranty;
-and give any other recipients of the Program a copy of this License
-along with the Program.
-
-You may charge a fee for the physical act of transferring a copy, and
-you may at your option offer warranty protection in exchange for a fee.
-
-  2. You may modify your copy or copies of the Program or any portion
-of it, thus forming a work based on the Program, and copy and
-distribute such modifications or work under the terms of Section 1
-above, provided that you also meet all of these conditions:
-
-    a) You must cause the modified files to carry prominent notices
-    stating that you changed the files and the date of any change.
-
-    b) You must cause any work that you distribute or publish, that in
-    whole or in part contains or is derived from the Program or any
-    part thereof, to be licensed as a whole at no charge to all third
-    parties under the terms of this License.
-
-    c) If the modified program normally reads commands interactively
-    when run, you must cause it, when started running for such
-    interactive use in the most ordinary way, to print or display an
-    announcement including an appropriate copyright notice and a
-    notice that there is no warranty (or else, saying that you provide
-    a warranty) and that users may redistribute the program under
-    these conditions, and telling the user how to view a copy of this
-    License.  (Exception: if the Program itself is interactive but
-    does not normally print such an announcement, your work based on
-    the Program is not required to print an announcement.)
-
-These requirements apply to the modified work as a whole.  If
-identifiable sections of that work are not derived from the Program,
-and can be reasonably considered independent and separate works in
-themselves, then this License, and its terms, do not apply to those
-sections when you distribute them as separate works.  But when you
-distribute the same sections as part of a whole which is a work based
-on the Program, the distribution of the whole must be on the terms of
-this License, whose permissions for other licensees extend to the
-entire whole, and thus to each and every part regardless of who wrote it.
-
-Thus, it is not the intent of this section to claim rights or contest
-your rights to work written entirely by you; rather, the intent is to
-exercise the right to control the distribution of derivative or
-collective works based on the Program.
-
-In addition, mere aggregation of another work not based on the Program
-with the Program (or with a work based on the Program) on a volume of
-a storage or distribution medium does not bring the other work under
-the scope of this License.
-
-  3. You may copy and distribute the Program (or a work based on it,
-under Section 2) in object code or executable form under the terms of
-Sections 1 and 2 above provided that you also do one of the following:
-
-    a) Accompany it with the complete corresponding machine-readable
-    source code, which must be distributed under the terms of Sections
-    1 and 2 above on a medium customarily used for software interchange; or,
-
-    b) Accompany it with a written offer, valid for at least three
-    years, to give any third party, for a charge no more than your
-    cost of physically performing source distribution, a complete
-    machine-readable copy of the corresponding source code, to be
-    distributed under the terms of Sections 1 and 2 above on a medium
-    customarily used for software interchange; or,
-
-    c) Accompany it with the information you received as to the offer
-    to distribute corresponding source code.  (This alternative is
-    allowed only for noncommercial distribution and only if you
-    received the program in object code or executable form with such
-    an offer, in accord with Subsection b above.)
-
-The source code for a work means the preferred form of the work for
-making modifications to it.  For an executable work, complete source
-code means all the source code for all modules it contains, plus any
-associated interface definition files, plus the scripts used to
-control compilation and installation of the executable.  However, as a
-special exception, the source code distributed need not include
-anything that is normally distributed (in either source or binary
-form) with the major components (compiler, kernel, and so on) of the
-operating system on which the executable runs, unless that component
-itself accompanies the executable.
-
-If distribution of executable or object code is made by offering
-access to copy from a designated place, then offering equivalent
-access to copy the source code from the same place counts as
-distribution of the source code, even though third parties are not
-compelled to copy the source along with the object code.
-
-  4. You may not copy, modify, sublicense, or distribute the Program
-except as expressly provided under this License.  Any attempt
-otherwise to copy, modify, sublicense or distribute the Program is
-void, and will automatically terminate your rights under this License.
-However, parties who have received copies, or rights, from you under
-this License will not have their licenses terminated so long as such
-parties remain in full compliance.
-
-  5. You are not required to accept this License, since you have not
-signed it.  However, nothing else grants you permission to modify or
-distribute the Program or its derivative works.  These actions are
-prohibited by law if you do not accept this License.  Therefore, by
-modifying or distributing the Program (or any work based on the
-Program), you indicate your acceptance of this License to do so, and
-all its terms and conditions for copying, distributing or modifying
-the Program or works based on it.
-
-  6. Each time you redistribute the Program (or any work based on the
-Program), the recipient automatically receives a license from the
-original licensor to copy, distribute or modify the Program subject to
-these terms and conditions.  You may not impose any further
-restrictions on the recipients' exercise of the rights granted herein.
-You are not responsible for enforcing compliance by third parties to
-this License.
-
-  7. If, as a consequence of a court judgment or allegation of patent
-infringement or for any other reason (not limited to patent issues),
-conditions are imposed on you (whether by court order, agreement or
-otherwise) that contradict the conditions of this License, they do not
-excuse you from the conditions of this License.  If you cannot
-distribute so as to satisfy simultaneously your obligations under this
-License and any other pertinent obligations, then as a consequence you
-may not distribute the Program at all.  For example, if a patent
-license would not permit royalty-free redistribution of the Program by
-all those who receive copies directly or indirectly through you, then
-the only way you could satisfy both it and this License would be to
-refrain entirely from distribution of the Program.
-
-If any portion of this section is held invalid or unenforceable under
-any particular circumstance, the balance of the section is intended to
-apply and the section as a whole is intended to apply in other
-circumstances.
-
-It is not the purpose of this section to induce you to infringe any
-patents or other property right claims or to contest validity of any
-such claims; this section has the sole purpose of protecting the
-integrity of the free software distribution system, which is
-implemented by public license practices.  Many people have made
-generous contributions to the wide range of software distributed
-through that system in reliance on consistent application of that
-system; it is up to the author/donor to decide if he or she is willing
-to distribute software through any other system and a licensee cannot
-impose that choice.
-
-This section is intended to make thoroughly clear what is believed to
-be a consequence of the rest of this License.
-
-  8. If the distribution and/or use of the Program is restricted in
-certain countries either by patents or by copyrighted interfaces, the
-original copyright holder who places the Program under this License
-may add an explicit geographical distribution limitation excluding
-those countries, so that distribution is permitted only in or among
-countries not thus excluded.  In such case, this License incorporates
-the limitation as if written in the body of this License.
-
-  9. The Free Software Foundation may publish revised and/or new versions
-of the General Public License from time to time.  Such new versions will
-be similar in spirit to the present version, but may differ in detail to
-address new problems or concerns.
-
-Each version is given a distinguishing version number.  If the Program
-specifies a version number of this License which applies to it and "any
-later version", you have the option of following the terms and conditions
-either of that version or of any later version published by the Free
-Software Foundation.  If the Program does not specify a version number of
-this License, you may choose any version ever published by the Free Software
-Foundation.
-
-  10. If you wish to incorporate parts of the Program into other free
-programs whose distribution conditions are different, write to the author
-to ask for permission.  For software which is copyrighted by the Free
-Software Foundation, write to the Free Software Foundation; we sometimes
-make exceptions for this.  Our decision will be guided by the two goals
-of preserving the free status of all derivatives of our free software and
-of promoting the sharing and reuse of software generally.
-
-			    NO WARRANTY
-
-  11. BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
-FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW.  EXCEPT WHEN
-OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
-PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED
-OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
-MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  THE ENTIRE RISK AS
-TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU.  SHOULD THE
-PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING,
-REPAIR OR CORRECTION.
-
-  12. IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
-WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
-REDISTRIBUTE THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES,
-INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING
-OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED
-TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY
-YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER
-PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE
-POSSIBILITY OF SUCH DAMAGES.
-
-		     END OF TERMS AND CONDITIONS
-
-	    How to Apply These Terms to Your New Programs
-
-  If you develop a new program, and you want it to be of the greatest
-possible use to the public, the best way to achieve this is to make it
-free software which everyone can redistribute and change under these terms.
-
-  To do so, attach the following notices to the program.  It is safest
-to attach them to the start of each source file to most effectively
-convey the exclusion of warranty; and each file should have at least
-the "copyright" line and a pointer to where the full notice is found.
-
-    <one line to give the program's name and a brief idea of what it does.>
-    Copyright (C) 19yy  <name of author>
-
-    This program is free software; you can redistribute it and/or modify
-    it under the terms of the GNU General Public License as published by
-    the Free Software Foundation; either version 2 of the License, or
-    (at your option) any later version.
-
-    This program is distributed in the hope that it will be useful,
-    but WITHOUT ANY WARRANTY; without even the implied warranty of
-    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-    GNU General Public License for more details.
-
-    You should have received a copy of the GNU General Public License
-    along with this program; if not, write to the Free Software
-    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
-
-
-Also add information on how to contact you by electronic and paper mail.
-
-If the program is interactive, make it output a short notice like this
-when it starts in an interactive mode:
-
-    Gnomovision version 69, Copyright (C) 19yy name of author
-    Gnomovision comes with ABSOLUTELY NO WARRANTY; for details type `show w'.
-    This is free software, and you are welcome to redistribute it
-    under certain conditions; type `show c' for details.
-
-The hypothetical commands `show w' and `show c' should show the appropriate
-parts of the General Public License.  Of course, the commands you use may
-be called something other than `show w' and `show c'; they could even be
-mouse-clicks or menu items--whatever suits your program.
-
-You should also get your employer (if you work as a programmer) or your
-school, if any, to sign a "copyright disclaimer" for the program, if
-necessary.  Here is a sample; alter the names:
-
-  Yoyodyne, Inc., hereby disclaims all copyright interest in the program
-  `Gnomovision' (which makes passes at compilers) written by James Hacker.
-
-  <signature of Ty Coon>, 1 April 1989
-  Ty Coon, President of Vice
-
-This General Public License does not permit incorporating your program into
-proprietary programs.  If your program is a subroutine library, you may
-consider it more useful to permit linking proprietary applications with the
-library.  If this is what you want to do, use the GNU Library General
-Public License instead of this License.
diff --git a/utils/statd/COPYRIGHT b/utils/statd/COPYRIGHT
index 47ff720..2a6dff6 100644
--- a/utils/statd/COPYRIGHT
+++ b/utils/statd/COPYRIGHT
@@ -13,7 +13,7 @@ GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
-Foundation, Inc., 675 Massachusetts Ave, Cambridge, MA 02139, USA.
+Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 Jeffrey A. Uphoff
 Orion Multisystems, Inc.
