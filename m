From: Hadmut Danisch <hadmut@danisch.de>
Subject: NFS incompatible with Solaris jumpstart
Date: Mon, 4 Oct 2004 01:03:00 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20041003230300.GA9057@danisch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S268216AbUJCXFN@vger.kernel.org>
To: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Hi,

I want to jumpstart-install (initial installation of the 
Solaris operating system) a sparc machine from a linux server
with kernel 2.6.8.1.

It works when using the nfs-user-server, but the sparc hangs after 
printing the OS prompt when using the nfs-kernel-server.

Any idea in how the nfs-user-server and the nfs-kernel-server differ 
and how to fix it?

regards
Hadmut
