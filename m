Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50700 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752849Ab3EGUqq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 May 2013 16:46:46 -0400
Date: Tue, 7 May 2013 16:46:42 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 03/17] NFSDv4.2: Added NFS v4.2 support to the NFS server
Message-ID: <20130507204642.GD32743@fieldses.org>
References: <1367240239-19326-1-git-send-email-SteveD@redhat.com>
 <1367240239-19326-4-git-send-email-SteveD@redhat.com>
 <20130507204433.GC32743@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130507204433.GC32743@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 07, 2013 at 04:44:33PM -0400, bfields wrote:
> On Mon, Apr 29, 2013 at 08:57:05AM -0400, Steve Dickson wrote:
> > From: Steve Dickson <steved@redhat.com>
> > 
> > This enable NFSv4.2 support for the server. To enable this
> > code do the following:
> >   echo "+4.2" >/proc/fs/nfsd/versions
> > 
> > after the nfsd kernel module is loaded.
> 
> We also need one more change to get working 4.2.

Also added a pynfs --minorversion option, committed to

	git://linux-nfs.org/~bfields/pynfs.git master

So, for example, I can run:

	./nfs4.1/testserver.py pip1:/exports/xfs/tmp2 --maketree --rundeps --minorversion=2 --hidepass all

and verify (after the above commit) that all tests pass (except two
known to also fail on 4.1, EID50 and LKPP1d).

--b.

commit 7cb12d18db4ed616cf5432e501be944db3bc8c47
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Tue May 7 15:46:51 2013 -0400

    4.1 server tests: support other minor versions
    
    So you can run tests with minor version 4.2, for example, by using
    --minorversion=2.
    
    This is a bit primitive.  Eventually we'll need it to vary behavior and
    applicable tests based on minorversion.
    
    Also, it shouldn't really allow --minorversion=0.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/nfs4.1/nfs4client.py b/nfs4.1/nfs4client.py
index 9e759b1..e750728 100644
--- a/nfs4.1/nfs4client.py
+++ b/nfs4.1/nfs4client.py
@@ -26,13 +26,13 @@ log_cb.setLevel(logging.DEBUG)
 
 SHOW_TRAFFIC = True # Debugging aid, prints out client traffic
 class NFS4Client(rpc.Client, rpc.Server):
-    def __init__(self, host='localhost', port=2049, ctrl_proc=16):
+    def __init__(self, host='localhost', port=2049, minorversion=1, ctrl_proc=16):
         rpc.Client.__init__(self, 100003, 4)
         self.prog = 0x40000000
         self.versions = [1] # List of supported versions of prog
 
-        self.minorversion = 1
-        self.minor_versions = [1]
+        self.minorversion = minorversion
+        self.minor_versions = [minorversion]
         self.tag = "default tag"
         self.impl_id = nfs_impl_id4("citi.umich.edu", "pynfs X.X",
                                     nfs4lib.get_nfstime())
diff --git a/nfs4.1/server41tests/environment.py b/nfs4.1/server41tests/environment.py
index 12f7970..e36a247 100644
--- a/nfs4.1/server41tests/environment.py
+++ b/nfs4.1/server41tests/environment.py
@@ -113,7 +113,7 @@ class Environment(testmod.Environment):
     def __init__(self, opts):
         self._lock = Lock()
         self.opts = opts
-        self.c1 = nfs4client.NFS4Client(opts.server, opts.port)
+        self.c1 = nfs4client.NFS4Client(opts.server, opts.port, opts.minorversion)
         s1 = rpc.security.instance(opts.flavor)
         if opts.flavor == rpc.AUTH_NONE:
             self.cred1 = s1.init_cred()
diff --git a/nfs4.1/testserver.py b/nfs4.1/testserver.py
index 3c72435..ba88996 100755
--- a/nfs4.1/testserver.py
+++ b/nfs4.1/testserver.py
@@ -70,6 +70,8 @@ def scan_options(p):
                  help="Store test results in xml format [%default]")
     p.add_option("--debug_fail", action="store_true", default=False,
                  help="Force some checks to fail")
+    p.add_option("--minorversion", type="int", default=1,
+                 metavar="MINORVERSION", help="Choose NFSv4 minor version")
 
     g = OptionGroup(p, "Security flavor options",
                     "These options choose or affect the security flavor used.")
