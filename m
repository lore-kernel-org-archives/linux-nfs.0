Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:60404 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S2388431AbeGXIja (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 24 Jul 2018 04:39:30 -0400
From: jiyin@redhat.com
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, "Jianhong.Yin" <yin-jianhong@163.com>
Subject: [PATCH 16/24] pynfs: python3 support plan: remove cPickle
Date: Tue, 24 Jul 2018 15:33:34 +0800
Message-Id: <20180724073342.5738-16-jiyin@redhat.com>
In-Reply-To: <20180724073342.5738-1-jiyin@redhat.com>
References: <20180724073342.5738-1-jiyin@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "Jianhong.Yin" <yin-jianhong@163.com>

Signed-off-by: Jianhong Yin <yin-jianhong@163.com>
---
 nfs4.0/testserver.py | 2 +-
 nfs4.1/testclient.py | 2 +-
 nfs4.1/testserver.py | 2 +-
 showresults.py       | 1 -
 4 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/nfs4.0/testserver.py b/nfs4.0/testserver.py
index fcee8e9..581dc3e 100755
--- a/nfs4.0/testserver.py
+++ b/nfs4.0/testserver.py
@@ -41,7 +41,7 @@ from optparse import OptionParser, OptionGroup, IndentedHelpFormatter
 import servertests.environment as environment
 import socket
 import rpc
-import cPickle as pickle
+import pickle
 
 VERSION="0.2" # How/when update this?
 
diff --git a/nfs4.1/testclient.py b/nfs4.1/testclient.py
index 47b74bd..3665253 100755
--- a/nfs4.1/testclient.py
+++ b/nfs4.1/testclient.py
@@ -34,7 +34,7 @@ from optparse import OptionParser, OptionGroup, IndentedHelpFormatter
 import client41tests.environment as environment
 import socket
 import rpc
-import cPickle as pickle
+import pickle
 
 def parse_useparams(str):
     return str.split(':')
diff --git a/nfs4.1/testserver.py b/nfs4.1/testserver.py
index c21221e..7818a5d 100755
--- a/nfs4.1/testserver.py
+++ b/nfs4.1/testserver.py
@@ -38,7 +38,7 @@ from optparse import OptionParser, OptionGroup, IndentedHelpFormatter
 import server41tests.environment as environment
 import socket
 import rpc
-import cPickle as pickle
+import pickle
 
 VERSION="0.2" # How/when update this?
 
diff --git a/showresults.py b/showresults.py
index ed23f7b..0b022fa 100755
--- a/showresults.py
+++ b/showresults.py
@@ -17,7 +17,6 @@ if  __name__ == "__main__":
     if os.path.isfile(os.path.join(sys.path[0], 'nfs4.1', 'testmod.py')):
         sys.path.insert(1, os.path.join(sys.path[0], 'nfs4.1'))
 
-#import cPickle as pickle
 import pickle
 import testmod
 from optparse import OptionParser
-- 
2.17.1

