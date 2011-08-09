Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:50241 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753412Ab1HIUaK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Aug 2011 16:30:10 -0400
Date: Tue, 9 Aug 2011 16:30:08 -0400
To: Fred Isaman <iisaman@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: two more minor pynfs patches
Message-ID: <20110809203008.GA18098@fieldses.org>
References: <1311883384-20260-1-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1311883384-20260-1-git-send-email-bfields@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Minor rearranging of nfs4.0/, an update to the README.  Please pull this
and previously posted patches from

	git://linux-nfs.org/~bfields/pynfs.git master

--b.

commit 8c1e8b6014b8680bdabd89948dd9de79504dec24
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Tue Aug 9 11:55:41 2011 -0400

    Move nfs4.0/lib/nfs4/* to nfs4.0/
    
    Petr Benas points out that my commit 4a297d951 "Share testmod.py between
    nfs4.0 and nfs4.1", which replaced nfs4.0's copy of testmod.py by a
    symlink to nfs4.1's copy, didn't work because nfs4lib is in a different
    location in the two trees.  He quite reasonably proposed replacing the
    symlink by a copy and fixing the import statment in the copy like:
    
    	- import nfs4lib
    	+ import nfs4.nfs4lib
    
    However, that would require admitting a mistake on my part, which my
    giant ego does not permit me to do.
    
    Instead, rearrange the rest of the world to match my original mistake.
    
    My theory is:
    	- we aim to merge the two code bases over time, so anything that
    	  makes them a little more similar is probably good; and
    	- nfs4.1 is Newer, therefore Better, so nfs4.0 should be made to
    	  imitate it rather than the other way around.
    
    Cc: Petr Benas <pbenas@redhat.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/nfs4.0/.gitignore b/nfs4.0/.gitignore
index 805fb8e..7ae645d 100644
--- a/nfs4.0/.gitignore
+++ b/nfs4.0/.gitignore
@@ -4,7 +4,7 @@
 /out_last
 
 # Generated files
-/lib/nfs4/nfs4_ops.py
+/nfs4_ops.py
 *_const.py
 *_type.py
 *_pack.py
@@ -17,4 +17,4 @@
 # quilt files
 patches
 series
-.pc
\ No newline at end of file
+.pc
diff --git a/nfs4.0/lib/nfs4/__init__.py b/nfs4.0/lib/nfs4/__init__.py
deleted file mode 100644
index 8b13789..0000000
--- a/nfs4.0/lib/nfs4/__init__.py
+++ /dev/null
@@ -1 +0,0 @@
-
diff --git a/nfs4.0/lib/ops_gen.py b/nfs4.0/lib/ops_gen.py
index f4cf10f..a677a10 100755
--- a/nfs4.0/lib/ops_gen.py
+++ b/nfs4.0/lib/ops_gen.py
@@ -6,8 +6,8 @@
 #                    Information Technology Integration
 #
 
-from nfs4.nfs4_const import nfs_opnum4
-import nfs4.nfs4_type as nfs4_type
+from nfs4_const import nfs_opnum4
+import nfs4_type as nfs4_type
 import time
 
 header = """\
diff --git a/nfs4.0/lib/nfs4/nfs4.x b/nfs4.0/nfs4.x
similarity index 100%
rename from nfs4.0/lib/nfs4/nfs4.x
rename to nfs4.0/nfs4.x
diff --git a/nfs4.0/lib/nfs4/nfs4acl.py b/nfs4.0/nfs4acl.py
similarity index 99%
rename from nfs4.0/lib/nfs4/nfs4acl.py
rename to nfs4.0/nfs4acl.py
index cfb4573..2bef2ca 100644
--- a/nfs4.0/lib/nfs4/nfs4acl.py
+++ b/nfs4.0/nfs4acl.py
@@ -10,8 +10,8 @@
 # Taken from mapping description at
 # http://www.citi.umich.edu/projects/nfsv4/rfc/draft-ietf-nfsv4-acl-mapping-02.txt
 
-from nfs4.nfs4_const import *
-from nfs4.nfs4_type import *
+from nfs4_const import *
+from nfs4_type import *
 
 # Taken from mapping
 MODE_R = ACE4_READ_DATA | ACE4_READ_NAMED_ATTRS
diff --git a/nfs4.0/nfs4client.py b/nfs4.0/nfs4client.py
index 5e67453..d76eddb 100755
--- a/nfs4.0/nfs4client.py
+++ b/nfs4.0/nfs4client.py
@@ -27,10 +27,10 @@ except ImportError:
 #    import rlcompleter
 #    readline.parse_and_bind("tab: complete")
 #import cmd
-import nfs4.nfs4lib as nfs4lib
-import nfs4.nfs4_type as nfs4_type
-import nfs4.nfs4_const as nfs4_const
-import nfs4.nfs4_pack as nfs4_pack
+import nfs4lib
+import nfs4_type
+import nfs4_const
+import nfs4_pack
 import code
 import traceback
 
diff --git a/nfs4.0/lib/nfs4/nfs4lib.py b/nfs4.0/nfs4lib.py
similarity index 100%
rename from nfs4.0/lib/nfs4/nfs4lib.py
rename to nfs4.0/nfs4lib.py
diff --git a/nfs4.0/nfs4server.py b/nfs4.0/nfs4server.py
index 1943b2f..bd848ca 100755
--- a/nfs4.0/nfs4server.py
+++ b/nfs4.0/nfs4server.py
@@ -25,15 +25,15 @@ if  __name__ == "__main__":
     if os.path.isfile(os.path.join(sys.path[0], 'lib', 'testmod.py')):
         sys.path.insert(1, os.path.join(sys.path[0], 'lib'))
 
-from nfs4.nfs4_const import *
-from nfs4.nfs4_type import *
-import nfs4.nfs4_pack as nfs4_pack
+from nfs4_const import *
+from nfs4_type import *
+import nfs4_pack
 import rpc.rpc as rpc
-import nfs4.nfs4lib as nfs4lib
+import nfs4lib
 import time, StringIO, random, traceback, codecs
 import StringIO
-import nfs4.nfs4state as nfs4state
-from nfs4.nfs4state import NFS4Error, printverf
+import nfs4state
+from nfs4state import NFS4Error, printverf
 from xdrlib import Error as XDRError
 
 unacceptable_names = [ "", ".", ".." ]
diff --git a/nfs4.0/lib/nfs4/nfs4state.py b/nfs4.0/nfs4state.py
similarity index 100%
rename from nfs4.0/lib/nfs4/nfs4state.py
rename to nfs4.0/nfs4state.py
diff --git a/nfs4.0/lib/nfs4/servertests/__init__.py b/nfs4.0/servertests/__init__.py
similarity index 100%
rename from nfs4.0/lib/nfs4/servertests/__init__.py
rename to nfs4.0/servertests/__init__.py
diff --git a/nfs4.0/lib/nfs4/servertests/environment.py b/nfs4.0/servertests/environment.py
similarity index 98%
rename from nfs4.0/lib/nfs4/servertests/environment.py
rename to nfs4.0/servertests/environment.py
index 8b23e66..2a4adad 100644
--- a/nfs4.0/lib/nfs4/servertests/environment.py
+++ b/nfs4.0/servertests/environment.py
@@ -10,9 +10,9 @@
 
 import time
 import testmod
-from nfs4.nfs4lib import NFS4Client, get_attrbitnum_dict
-from nfs4.nfs4_const import *
-from nfs4.nfs4_type import fsid4, nfsace4, fs_locations4, fs_location4, \
+from nfs4lib import NFS4Client, get_attrbitnum_dict
+from nfs4_const import *
+from nfs4_type import fsid4, nfsace4, fs_locations4, fs_location4, \
      specdata4, nfstime4, settime4, stateid4
 import rpc
 import sys
diff --git a/nfs4.0/lib/nfs4/servertests/st_access.py b/nfs4.0/servertests/st_access.py
similarity index 99%
rename from nfs4.0/lib/nfs4/servertests/st_access.py
rename to nfs4.0/servertests/st_access.py
index 56b045a..f0d606a 100644
--- a/nfs4.0/lib/nfs4/servertests/st_access.py
+++ b/nfs4.0/servertests/st_access.py
@@ -1,4 +1,4 @@
-from nfs4.nfs4_const import *
+from nfs4_const import *
 from environment import check
 
 _maxval = ACCESS4_DELETE | ACCESS4_EXECUTE | ACCESS4_EXTEND | \
diff --git a/nfs4.0/lib/nfs4/servertests/st_close.py b/nfs4.0/servertests/st_close.py
similarity index 99%
rename from nfs4.0/lib/nfs4/servertests/st_close.py
rename to nfs4.0/servertests/st_close.py
index 9df5f03..3c9fdab 100644
--- a/nfs4.0/lib/nfs4/servertests/st_close.py
+++ b/nfs4.0/servertests/st_close.py
@@ -1,4 +1,4 @@
-from nfs4.nfs4_const import *
+from nfs4_const import *
 from environment import check, makeStaleId
 
 
diff --git a/nfs4.0/lib/nfs4/servertests/st_commit.py b/nfs4.0/servertests/st_commit.py
similarity index 99%
rename from nfs4.0/lib/nfs4/servertests/st_commit.py
rename to nfs4.0/servertests/st_commit.py
index b7f536e..a6d7556 100644
--- a/nfs4.0/lib/nfs4/servertests/st_commit.py
+++ b/nfs4.0/servertests/st_commit.py
@@ -1,4 +1,4 @@
-from nfs4.nfs4_const import *
+from nfs4_const import *
 from environment import check, checklist
 
 _text = "Random data to write"
diff --git a/nfs4.0/lib/nfs4/servertests/st_compound.py b/nfs4.0/servertests/st_compound.py
similarity index 96%
rename from nfs4.0/lib/nfs4/servertests/st_compound.py
rename to nfs4.0/servertests/st_compound.py
index 4693b21..98be3a8 100644
--- a/nfs4.0/lib/nfs4/servertests/st_compound.py
+++ b/nfs4.0/servertests/st_compound.py
@@ -1,6 +1,6 @@
-from nfs4.nfs4_const import *
-from nfs4.nfs4_type import nfs_argop4
-from nfs4.nfs4_pack import NFS4Packer
+from nfs4_const import *
+from nfs4_type import nfs_argop4
+from nfs4_pack import NFS4Packer
 from environment import check, checklist, get_invalid_utf8strings
 from rpc import RPCError
 
diff --git a/nfs4.0/lib/nfs4/servertests/st_create.py b/nfs4.0/servertests/st_create.py
similarity index 98%
rename from nfs4.0/lib/nfs4/servertests/st_create.py
rename to nfs4.0/servertests/st_create.py
index fb16ce9..e5c99fa 100644
--- a/nfs4.0/lib/nfs4/servertests/st_create.py
+++ b/nfs4.0/servertests/st_create.py
@@ -1,5 +1,5 @@
-from nfs4.nfs4_const import *
-from nfs4.nfs4_type import createtype4, specdata4
+from nfs4_const import *
+from nfs4_type import createtype4, specdata4
 from environment import check, checklist
 
 def getDefaultAttr(c):
diff --git a/nfs4.0/lib/nfs4/servertests/st_delegation.py b/nfs4.0/servertests/st_delegation.py
similarity index 99%
rename from nfs4.0/lib/nfs4/servertests/st_delegation.py
rename to nfs4.0/servertests/st_delegation.py
index 389e401..a8297c8 100644
--- a/nfs4.0/lib/nfs4/servertests/st_delegation.py
+++ b/nfs4.0/servertests/st_delegation.py
@@ -1,5 +1,5 @@
-from nfs4.nfs4_const import *
-from nfs4.nfs4_type import nfs_client_id4, clientaddr4, cb_client4
+from nfs4_const import *
+from nfs4_type import nfs_client_id4, clientaddr4, cb_client4
 from environment import check, checklist
 import os
 import threading
@@ -389,7 +389,7 @@ def testChangeDeleg(t, env, funct=_recall):
     FLAGS: delegations
     CODE: DELEG9
     """
-    from nfs4.nfs4lib import CBServer
+    from nfs4lib import CBServer
     c = env.c1
     id = 'pynfs%i_%s' % (os.getpid(), t.code)
     c.init_connection(id, cb_ident=0)
diff --git a/nfs4.0/lib/nfs4/servertests/st_fslocations.py b/nfs4.0/servertests/st_fslocations.py
similarity index 98%
rename from nfs4.0/lib/nfs4/servertests/st_fslocations.py
rename to nfs4.0/servertests/st_fslocations.py
index 44a197b..f02c2f5 100644
--- a/nfs4.0/lib/nfs4/servertests/st_fslocations.py
+++ b/nfs4.0/servertests/st_fslocations.py
@@ -1,5 +1,5 @@
-from nfs4.nfs4_const import *
-from nfs4.nfs4lib import list2bitmap
+from nfs4_const import *
+from nfs4lib import list2bitmap
 from environment import check
 
 def testReference(t, env):
diff --git a/nfs4.0/lib/nfs4/servertests/st_getattr.py b/nfs4.0/servertests/st_getattr.py
similarity index 99%
rename from nfs4.0/lib/nfs4/servertests/st_getattr.py
rename to nfs4.0/servertests/st_getattr.py
index 0920ed9..1156acf 100644
--- a/nfs4.0/lib/nfs4/servertests/st_getattr.py
+++ b/nfs4.0/servertests/st_getattr.py
@@ -1,6 +1,6 @@
-from nfs4.nfs4_const import *
+from nfs4_const import *
 from environment import check, checklist
-from nfs4.nfs4lib import get_attr_name
+from nfs4lib import get_attr_name
 
 def _try_mandatory(t, env, path):
     c = env.c1
diff --git a/nfs4.0/lib/nfs4/servertests/st_getfh.py b/nfs4.0/servertests/st_getfh.py
similarity index 98%
rename from nfs4.0/lib/nfs4/servertests/st_getfh.py
rename to nfs4.0/servertests/st_getfh.py
index d953d64..7f022ab 100644
--- a/nfs4.0/lib/nfs4/servertests/st_getfh.py
+++ b/nfs4.0/servertests/st_getfh.py
@@ -1,4 +1,4 @@
-from nfs4.nfs4_const import *
+from nfs4_const import *
 from environment import check
 
 def testFile(t, env):
diff --git a/nfs4.0/lib/nfs4/servertests/st_gss.py b/nfs4.0/servertests/st_gss.py
similarity index 99%
rename from nfs4.0/lib/nfs4/servertests/st_gss.py
rename to nfs4.0/servertests/st_gss.py
index 6ad3e3e..eed707b 100644
--- a/nfs4.0/lib/nfs4/servertests/st_gss.py
+++ b/nfs4.0/servertests/st_gss.py
@@ -1,4 +1,4 @@
-from nfs4.nfs4_const import *
+from nfs4_const import *
 from environment import check
 from socket import timeout
 import rpc
diff --git a/nfs4.0/lib/nfs4/servertests/st_link.py b/nfs4.0/servertests/st_link.py
similarity index 99%
rename from nfs4.0/lib/nfs4/servertests/st_link.py
rename to nfs4.0/servertests/st_link.py
index c4882e1..10d7197 100644
--- a/nfs4.0/lib/nfs4/servertests/st_link.py
+++ b/nfs4.0/servertests/st_link.py
@@ -1,4 +1,4 @@
-from nfs4.nfs4_const import *
+from nfs4_const import *
 from environment import check, checklist, get_invalid_utf8strings
 
 def _basictest(t, c, path, error=NFS4_OK):
diff --git a/nfs4.0/lib/nfs4/servertests/st_lock.py b/nfs4.0/servertests/st_lock.py
similarity index 99%
rename from nfs4.0/lib/nfs4/servertests/st_lock.py
rename to nfs4.0/servertests/st_lock.py
index 8be25cd..328c692 100644
--- a/nfs4.0/lib/nfs4/servertests/st_lock.py
+++ b/nfs4.0/servertests/st_lock.py
@@ -1,5 +1,5 @@
-from nfs4.nfs4_const import *
-from nfs4.nfs4_type import stateid4
+from nfs4_const import *
+from nfs4_type import stateid4
 from environment import check, checklist, get_invalid_clientid, makeStaleId
 import time
 
diff --git a/nfs4.0/lib/nfs4/servertests/st_lockt.py b/nfs4.0/servertests/st_lockt.py
similarity index 99%
rename from nfs4.0/lib/nfs4/servertests/st_lockt.py
rename to nfs4.0/servertests/st_lockt.py
index a8f1e05..fff4995 100644
--- a/nfs4.0/lib/nfs4/servertests/st_lockt.py
+++ b/nfs4.0/servertests/st_lockt.py
@@ -1,4 +1,4 @@
-from nfs4.nfs4_const import *
+from nfs4_const import *
 from environment import check, checklist, get_invalid_clientid
 
 def testUnlockedFile(t, env):
diff --git a/nfs4.0/lib/nfs4/servertests/st_locku.py b/nfs4.0/servertests/st_locku.py
similarity index 99%
rename from nfs4.0/lib/nfs4/servertests/st_locku.py
rename to nfs4.0/servertests/st_locku.py
index 6f8a414..334f040 100644
--- a/nfs4.0/lib/nfs4/servertests/st_locku.py
+++ b/nfs4.0/servertests/st_locku.py
@@ -1,5 +1,5 @@
-from nfs4.nfs4_const import *
-from nfs4.nfs4_type import stateid4
+from nfs4_const import *
+from nfs4_type import stateid4
 from environment import check, checklist, makeStaleId
 
 def testFile(t, env):
diff --git a/nfs4.0/lib/nfs4/servertests/st_lookup.py b/nfs4.0/servertests/st_lookup.py
similarity index 99%
rename from nfs4.0/lib/nfs4/servertests/st_lookup.py
rename to nfs4.0/servertests/st_lookup.py
index ef662bb..40c5983 100644
--- a/nfs4.0/lib/nfs4/servertests/st_lookup.py
+++ b/nfs4.0/servertests/st_lookup.py
@@ -1,4 +1,4 @@
-from nfs4.nfs4_const import *
+from nfs4_const import *
 from environment import check, checklist, get_invalid_utf8strings
 
 def testDir(t, env):
diff --git a/nfs4.0/lib/nfs4/servertests/st_lookupp.py b/nfs4.0/servertests/st_lookupp.py
similarity index 99%
rename from nfs4.0/lib/nfs4/servertests/st_lookupp.py
rename to nfs4.0/servertests/st_lookupp.py
index d8f313b..d4f5246 100644
--- a/nfs4.0/lib/nfs4/servertests/st_lookupp.py
+++ b/nfs4.0/servertests/st_lookupp.py
@@ -1,4 +1,4 @@
-from nfs4.nfs4_const import *
+from nfs4_const import *
 from environment import check, checklist, get_invalid_utf8strings
 
 def testDir(t, env):
diff --git a/nfs4.0/lib/nfs4/servertests/st_nverify.py b/nfs4.0/servertests/st_nverify.py
similarity index 99%
rename from nfs4.0/lib/nfs4/servertests/st_nverify.py
rename to nfs4.0/servertests/st_nverify.py
index 00aed28..24e37e1 100644
--- a/nfs4.0/lib/nfs4/servertests/st_nverify.py
+++ b/nfs4.0/servertests/st_nverify.py
@@ -1,4 +1,4 @@
-from nfs4.nfs4_const import *
+from nfs4_const import *
 from environment import check, checklist, get_invalid_clientid, makeStaleId
 
 def _try_mand(env, path):
diff --git a/nfs4.0/lib/nfs4/servertests/st_open.py b/nfs4.0/servertests/st_open.py
similarity index 99%
rename from nfs4.0/lib/nfs4/servertests/st_open.py
rename to nfs4.0/servertests/st_open.py
index 88134f1..dc1e39d 100644
--- a/nfs4.0/lib/nfs4/servertests/st_open.py
+++ b/nfs4.0/servertests/st_open.py
@@ -1,6 +1,6 @@
-from nfs4.nfs4_const import *
+from nfs4_const import *
 from environment import check, checklist, checkdict, get_invalid_utf8strings
-from nfs4.nfs4lib import get_bitnumattr_dict
+from nfs4lib import get_bitnumattr_dict
 
 # Any test that uses create_confirm should depend on this test
 def testOpen(t, env):
diff --git a/nfs4.0/lib/nfs4/servertests/st_openconfirm.py b/nfs4.0/servertests/st_openconfirm.py
similarity index 98%
rename from nfs4.0/lib/nfs4/servertests/st_openconfirm.py
rename to nfs4.0/servertests/st_openconfirm.py
index 94f77df..6e623de 100644
--- a/nfs4.0/lib/nfs4/servertests/st_openconfirm.py
+++ b/nfs4.0/servertests/st_openconfirm.py
@@ -1,5 +1,5 @@
-from nfs4.nfs4_const import *
-from nfs4.nfs4_type import stateid4
+from nfs4_const import *
+from nfs4_type import stateid4
 from environment import check, checklist, makeStaleId
 
 def _confirm(t, c, file, stateid):
diff --git a/nfs4.0/lib/nfs4/servertests/st_opendowngrade.py b/nfs4.0/servertests/st_opendowngrade.py
similarity index 99%
rename from nfs4.0/lib/nfs4/servertests/st_opendowngrade.py
rename to nfs4.0/servertests/st_opendowngrade.py
index 4bf07a5..7bf5479 100644
--- a/nfs4.0/lib/nfs4/servertests/st_opendowngrade.py
+++ b/nfs4.0/servertests/st_opendowngrade.py
@@ -1,4 +1,4 @@
-from nfs4.nfs4_const import *
+from nfs4_const import *
 from environment import check, makeStaleId
 
 def testRegularOpen(t, env):
diff --git a/nfs4.0/lib/nfs4/servertests/st_putfh.py b/nfs4.0/servertests/st_putfh.py
similarity index 98%
rename from nfs4.0/lib/nfs4/servertests/st_putfh.py
rename to nfs4.0/servertests/st_putfh.py
index d76c459..67158e2 100644
--- a/nfs4.0/lib/nfs4/servertests/st_putfh.py
+++ b/nfs4.0/servertests/st_putfh.py
@@ -1,4 +1,4 @@
-from nfs4.nfs4_const import *
+from nfs4_const import *
 from environment import check
 
 def _try_put(t, c, path):
diff --git a/nfs4.0/lib/nfs4/servertests/st_putpubfh.py b/nfs4.0/servertests/st_putpubfh.py
similarity index 96%
rename from nfs4.0/lib/nfs4/servertests/st_putpubfh.py
rename to nfs4.0/servertests/st_putpubfh.py
index 0004991..2ca19ee 100644
--- a/nfs4.0/lib/nfs4/servertests/st_putpubfh.py
+++ b/nfs4.0/servertests/st_putpubfh.py
@@ -1,4 +1,4 @@
-from nfs4.nfs4_const import *
+from nfs4_const import *
 from environment import check
 
 def testSupported(t, env):
diff --git a/nfs4.0/lib/nfs4/servertests/st_putrootfh.py b/nfs4.0/servertests/st_putrootfh.py
similarity index 88%
rename from nfs4.0/lib/nfs4/servertests/st_putrootfh.py
rename to nfs4.0/servertests/st_putrootfh.py
index 65b1b62..4c9e9b8 100644
--- a/nfs4.0/lib/nfs4/servertests/st_putrootfh.py
+++ b/nfs4.0/servertests/st_putrootfh.py
@@ -1,4 +1,4 @@
-from nfs4.nfs4_const import *
+from nfs4_const import *
 from environment import check
 
 def testSupported(t, env):
diff --git a/nfs4.0/lib/nfs4/servertests/st_read.py b/nfs4.0/servertests/st_read.py
similarity index 99%
rename from nfs4.0/lib/nfs4/servertests/st_read.py
rename to nfs4.0/servertests/st_read.py
index c825b34..5dc9fc7 100644
--- a/nfs4.0/lib/nfs4/servertests/st_read.py
+++ b/nfs4.0/servertests/st_read.py
@@ -1,4 +1,4 @@
-from nfs4.nfs4_const import *
+from nfs4_const import *
 from environment import check, makeBadID, makeStaleId
 
 def _compare(t, res, expect, eof=True):
diff --git a/nfs4.0/lib/nfs4/servertests/st_readdir.py b/nfs4.0/servertests/st_readdir.py
similarity index 99%
rename from nfs4.0/lib/nfs4/servertests/st_readdir.py
rename to nfs4.0/servertests/st_readdir.py
index 42cb8f3..72a7c76 100644
--- a/nfs4.0/lib/nfs4/servertests/st_readdir.py
+++ b/nfs4.0/servertests/st_readdir.py
@@ -1,5 +1,5 @@
-from nfs4.nfs4_const import *
-from nfs4.nfs4lib import get_attr_name
+from nfs4_const import *
+from nfs4lib import get_attr_name
 from environment import check
 
 def _compare(t, entries, expect, attrlist=[]):
diff --git a/nfs4.0/lib/nfs4/servertests/st_readlink.py b/nfs4.0/servertests/st_readlink.py
similarity index 98%
rename from nfs4.0/lib/nfs4/servertests/st_readlink.py
rename to nfs4.0/servertests/st_readlink.py
index 37905d5..843247d 100644
--- a/nfs4.0/lib/nfs4/servertests/st_readlink.py
+++ b/nfs4.0/servertests/st_readlink.py
@@ -1,4 +1,4 @@
-from nfs4.nfs4_const import *
+from nfs4_const import *
 from environment import check
 
 def testReadlink(t, env):
diff --git a/nfs4.0/lib/nfs4/servertests/st_reboot.py b/nfs4.0/servertests/st_reboot.py
similarity index 99%
rename from nfs4.0/lib/nfs4/servertests/st_reboot.py
rename to nfs4.0/servertests/st_reboot.py
index 067cda6..41e4657 100644
--- a/nfs4.0/lib/nfs4/servertests/st_reboot.py
+++ b/nfs4.0/servertests/st_reboot.py
@@ -1,4 +1,4 @@
-from nfs4.nfs4_const import *
+from nfs4_const import *
 from environment import check, checklist
 import os
 
diff --git a/nfs4.0/lib/nfs4/servertests/st_releaselockowner.py b/nfs4.0/servertests/st_releaselockowner.py
similarity index 88%
rename from nfs4.0/lib/nfs4/servertests/st_releaselockowner.py
rename to nfs4.0/servertests/st_releaselockowner.py
index 3b670a1..73b2b5a 100644
--- a/nfs4.0/lib/nfs4/servertests/st_releaselockowner.py
+++ b/nfs4.0/servertests/st_releaselockowner.py
@@ -1,5 +1,5 @@
-from nfs4.nfs4_const import *
-from nfs4.nfs4_type import lock_owner4
+from nfs4_const import *
+from nfs4_type import lock_owner4
 from environment import check, checklist
 
 def testFile(t, env):
diff --git a/nfs4.0/lib/nfs4/servertests/st_remove.py b/nfs4.0/servertests/st_remove.py
similarity index 99%
rename from nfs4.0/lib/nfs4/servertests/st_remove.py
rename to nfs4.0/servertests/st_remove.py
index d33b812..73d00ea 100644
--- a/nfs4.0/lib/nfs4/servertests/st_remove.py
+++ b/nfs4.0/servertests/st_remove.py
@@ -1,4 +1,4 @@
-from nfs4.nfs4_const import *
+from nfs4_const import *
 from environment import check, get_invalid_utf8strings
 
 def testDir(t, env):
diff --git a/nfs4.0/lib/nfs4/servertests/st_rename.py b/nfs4.0/servertests/st_rename.py
similarity index 99%
rename from nfs4.0/lib/nfs4/servertests/st_rename.py
rename to nfs4.0/servertests/st_rename.py
index 4cc3b7a..a10cbac 100644
--- a/nfs4.0/lib/nfs4/servertests/st_rename.py
+++ b/nfs4.0/servertests/st_rename.py
@@ -1,4 +1,4 @@
-from nfs4.nfs4_const import *
+from nfs4_const import *
 from environment import check, get_invalid_utf8strings
 
 def testValidDir(t, env):
diff --git a/nfs4.0/lib/nfs4/servertests/st_renew.py b/nfs4.0/servertests/st_renew.py
similarity index 97%
rename from nfs4.0/lib/nfs4/servertests/st_renew.py
rename to nfs4.0/servertests/st_renew.py
index 6fd8aaa..4582c01 100644
--- a/nfs4.0/lib/nfs4/servertests/st_renew.py
+++ b/nfs4.0/servertests/st_renew.py
@@ -1,4 +1,4 @@
-from nfs4.nfs4_const import *
+from nfs4_const import *
 from environment import check
 
 def testRenew(t, env):
diff --git a/nfs4.0/lib/nfs4/servertests/st_replay.py b/nfs4.0/servertests/st_replay.py
similarity index 98%
rename from nfs4.0/lib/nfs4/servertests/st_replay.py
rename to nfs4.0/servertests/st_replay.py
index 559ab44..947a42f 100644
--- a/nfs4.0/lib/nfs4/servertests/st_replay.py
+++ b/nfs4.0/servertests/st_replay.py
@@ -1,6 +1,6 @@
-from nfs4.nfs4_const import *
+from nfs4_const import *
 from environment import check, checklist
-from nfs4.nfs4_type import exist_lock_owner4, locker4
+from nfs4_type import exist_lock_owner4, locker4
 
 def _replay(c, ops, error=NFS4_OK):
     # Can send in an error list, but replays must return same error as orig
diff --git a/nfs4.0/lib/nfs4/servertests/st_restorefh.py b/nfs4.0/servertests/st_restorefh.py
similarity index 98%
rename from nfs4.0/lib/nfs4/servertests/st_restorefh.py
rename to nfs4.0/servertests/st_restorefh.py
index 490f137..d8158e0 100644
--- a/nfs4.0/lib/nfs4/servertests/st_restorefh.py
+++ b/nfs4.0/servertests/st_restorefh.py
@@ -1,4 +1,4 @@
-from nfs4.nfs4_const import *
+from nfs4_const import *
 from environment import check
 
 def _try_sequence(t, c, path):
diff --git a/nfs4.0/lib/nfs4/servertests/st_savefh.py b/nfs4.0/servertests/st_savefh.py
similarity index 91%
rename from nfs4.0/lib/nfs4/servertests/st_savefh.py
rename to nfs4.0/servertests/st_savefh.py
index 9c35ee0..e193fe3 100644
--- a/nfs4.0/lib/nfs4/servertests/st_savefh.py
+++ b/nfs4.0/servertests/st_savefh.py
@@ -1,4 +1,4 @@
-from nfs4.nfs4_const import *
+from nfs4_const import *
 from environment import check
 
 # NOTE other tests in restorefh.py
diff --git a/nfs4.0/lib/nfs4/servertests/st_secinfo.py b/nfs4.0/servertests/st_secinfo.py
similarity index 99%
rename from nfs4.0/lib/nfs4/servertests/st_secinfo.py
rename to nfs4.0/servertests/st_secinfo.py
index b0d35c2..793fdfd 100644
--- a/nfs4.0/lib/nfs4/servertests/st_secinfo.py
+++ b/nfs4.0/servertests/st_secinfo.py
@@ -1,4 +1,4 @@
-from nfs4.nfs4_const import *
+from nfs4_const import *
 from environment import check, get_invalid_utf8strings
 
 # XXX Do this for each object type
diff --git a/nfs4.0/lib/nfs4/servertests/st_setattr.py b/nfs4.0/servertests/st_setattr.py
similarity index 99%
rename from nfs4.0/lib/nfs4/servertests/st_setattr.py
rename to nfs4.0/servertests/st_setattr.py
index af9e8bf..686ce87 100644
--- a/nfs4.0/lib/nfs4/servertests/st_setattr.py
+++ b/nfs4.0/servertests/st_setattr.py
@@ -1,7 +1,7 @@
-from nfs4.nfs4_const import *
+from nfs4_const import *
 from environment import check, checklist, get_invalid_utf8strings
-from nfs4.nfs4lib import bitmap2list, dict2fattr
-from nfs4.nfs4_type import nfstime4, settime4
+from nfs4lib import bitmap2list, dict2fattr
+from nfs4_type import nfstime4, settime4
 
 def _set_mode(t, c, file, stateid=None, msg=" using stateid=0",
               warnlist=[]):
diff --git a/nfs4.0/lib/nfs4/servertests/st_setclientid.py b/nfs4.0/servertests/st_setclientid.py
similarity index 99%
rename from nfs4.0/lib/nfs4/servertests/st_setclientid.py
rename to nfs4.0/servertests/st_setclientid.py
index eeb67c6..74b3d4f 100644
--- a/nfs4.0/lib/nfs4/servertests/st_setclientid.py
+++ b/nfs4.0/servertests/st_setclientid.py
@@ -1,4 +1,4 @@
-from nfs4.nfs4_const import *
+from nfs4_const import *
 from environment import check
 import os
 import struct, time
diff --git a/nfs4.0/lib/nfs4/servertests/st_setclientidconfirm.py b/nfs4.0/servertests/st_setclientidconfirm.py
similarity index 98%
rename from nfs4.0/lib/nfs4/servertests/st_setclientidconfirm.py
rename to nfs4.0/servertests/st_setclientidconfirm.py
index a42238a..cbe9700 100644
--- a/nfs4.0/lib/nfs4/servertests/st_setclientidconfirm.py
+++ b/nfs4.0/servertests/st_setclientidconfirm.py
@@ -1,4 +1,4 @@
-from nfs4.nfs4_const import *
+from nfs4_const import *
 from environment import check
 import os
 
diff --git a/nfs4.0/lib/nfs4/servertests/st_spoof.py b/nfs4.0/servertests/st_spoof.py
similarity index 98%
rename from nfs4.0/lib/nfs4/servertests/st_spoof.py
rename to nfs4.0/servertests/st_spoof.py
index 485169f..b9dca89 100644
--- a/nfs4.0/lib/nfs4/servertests/st_spoof.py
+++ b/nfs4.0/servertests/st_spoof.py
@@ -1,4 +1,4 @@
-from nfs4.nfs4_const import *
+from nfs4_const import *
 from environment import check
 
 def testSpoofUser(t, env):
diff --git a/nfs4.0/lib/nfs4/servertests/st_verify.py b/nfs4.0/servertests/st_verify.py
similarity index 99%
rename from nfs4.0/lib/nfs4/servertests/st_verify.py
rename to nfs4.0/servertests/st_verify.py
index 5096690..255b6a8 100644
--- a/nfs4.0/lib/nfs4/servertests/st_verify.py
+++ b/nfs4.0/servertests/st_verify.py
@@ -1,4 +1,4 @@
-from nfs4.nfs4_const import *
+from nfs4_const import *
 from environment import check, checklist, get_invalid_clientid, makeStaleId
 
 def _try_mand(env, path):
diff --git a/nfs4.0/lib/nfs4/servertests/st_write.py b/nfs4.0/servertests/st_write.py
similarity index 99%
rename from nfs4.0/lib/nfs4/servertests/st_write.py
rename to nfs4.0/servertests/st_write.py
index 1e85fcf..2d8a659 100644
--- a/nfs4.0/lib/nfs4/servertests/st_write.py
+++ b/nfs4.0/servertests/st_write.py
@@ -1,4 +1,4 @@
-from nfs4.nfs4_const import *
+from nfs4_const import *
 from environment import check, compareTimes, makeBadID, makeStaleId
 
 _text = 'write data' # len=10
diff --git a/nfs4.0/setup.py b/nfs4.0/setup.py
index e47a861..f17a1c9 100755
--- a/nfs4.0/setup.py
+++ b/nfs4.0/setup.py
@@ -41,8 +41,7 @@ def use_xdr(dir, xdrfile):
 
 def generate_files():
     home = os.getcwd()
-    dir = os.path.join(topdir, 'lib', 'nfs4')
-    use_xdr(dir, 'nfs4.x')
+    use_xdr(topdir, 'nfs4.x')
     import ops_gen # this must be delayed until nfs4.x is parsed
     sources = [ os.path.join(topdir, 'lib', 'ops_gen.py'),
                 'nfs4_const.py', 'nfs4_type.py' ]
@@ -94,7 +93,7 @@ setup(name = "newpynfs",
 
       ext_modules = [gssapi],
       package_dir = {'': 'lib'},
-      packages = ['nfs4', 'nfs4.servertests', 'ply', 'rpc', 'rpc.rpcsec'],
+      packages = ['servertests', 'ply', 'rpc', 'rpc.rpcsec'],
       py_modules = ['testmod', 'rpcgen'],
       scripts = ['testserver.py', 'showresults.py']
       )
diff --git a/nfs4.0/testserver.py b/nfs4.0/testserver.py
index c2a7c7b..326b86b 100755
--- a/nfs4.0/testserver.py
+++ b/nfs4.0/testserver.py
@@ -38,7 +38,7 @@ if  __name__ == "__main__":
 import re
 import testmod
 from optparse import OptionParser, OptionGroup, IndentedHelpFormatter
-import nfs4.servertests.environment as environment
+import servertests.environment as environment
 import socket
 import rpc
 import cPickle as pickle
@@ -260,7 +260,7 @@ def run_filter(test, options):
 
 def printflags(list):
     """Print all legal flag names, which are given in list"""
-    from nfs4.nfs4_const import nfs_opnum4
+    from nfs4_const import nfs_opnum4
     command_names = [s.lower()[3:].replace('_', '') \
                      for s in nfs_opnum4.values()]
     list.sort()
@@ -285,7 +285,7 @@ def main():
     opt, args = scan_options(p)
 
     # Create test database
-    tests, fdict, cdict = testmod.createtests('nfs4.servertests')
+    tests, fdict, cdict = testmod.createtests('servertests')
 
     # Deal with any informational options
     if opt.showflags:

commit 9bcbd7d3e2ec918f65d8d33cbf6df4cc76229b85
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Tue Aug 9 16:20:12 2011 -0400

    Fix README setup instructions
    
    This is what I have to do--perhaps it's not actually correct and the
    setup scripts need fixing.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/README b/README
index e756871..0c34b2a 100644
--- a/README
+++ b/README
@@ -3,7 +3,8 @@ the merge of what were originally two independent projects--initially
 the 4.0 pynfs code was all moved into the nfs4.0 directory, but as time
 passes we expect to merge the two code bases.
 
-You can prepare both for use with a single
+You can prepare both for use with
+	./setup.py build
 	./setup.py build_ext --inplace
 which will create auto-generated files and compile any shared libraries
 in place.

