From: David Quigley <dpquigl@davequigley.com>
Subject: Labeled NFS [v5]
Date: Mon, 12 Nov 2012 01:15:34 -0500
Message-ID: <1352700947-3915-1-git-send-email-dpquigl@davequigley.com>
Cc: linux-nfs@vger.kernel.org, selinux@tycho.nsa.gov,
        linux-security-module@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@netapp.com, sds@tycho.nsa.gov
Return-path: <owner-selinux-MESi4pFTnrejpDF0oNHs+n7yKkN/O5/Z@public.gmane.org>
Sender: owner-selinux@tycho.nsa.gov
List-ID: <linux-nfs.vger.kernel.org>

The NFSv4 working group has finally accepted Labeled NFS as part of the NFSv4.2
specification and it has been decided that a reposting of the Labeled NFS code
for inclusion into mainline was a good idea. The patches have been rebased onto
v3.7-rc2 and have been tested against the SELinux testsuite with the only
failures being for features not supported by NFS.
