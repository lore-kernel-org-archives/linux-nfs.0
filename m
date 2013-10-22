Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:53240 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751950Ab3JVOWn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Oct 2013 10:22:43 -0400
From: <andros@netapp.com>
To: <steved@redhat.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 0/3] GSSD: Use gss-ctx keys and gsskeyd to sync Kerberos credentials and kernel gss_contexts.
Date: Tue, 22 Oct 2013 10:22:34 -0400
Message-ID: <1382451757-3032-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

This is an RFC patchset, which will be used for testing.

This patchset requires the "SUNRPC: destroy gss_cred and context on Kerberos credential destruction" kernel patchset.

We need to do a lot of testing to ensure that once kdestroy and gss-ctx
gss_user_destroy is called, all existing buffered
writes using the 'destroyed gss credential + context' are serviced.

Differences from version 1:

- moved from nfstgt_login and nfstgt_logout to gsskeyd.
- gsskeyd automatically creates gss-ctx key on kinit and destroys the gss-ctx
key on kdestroy.

gsskeyd will need to act differently for different krb5 credential caches.
For example, some versions of gssd store FILE credentials in FILE:/tmp/krb5cc_<UID>
while this code, written for fedora 19 uses FILE:/run/user/<UID>/krb5cc/tgt.

As Trond suggested, if we keep gsskeyd separate from gssd, we could set up a
configuration file along the lines of the keytools' request-key.conf file to
allow both NFS and CIFS (and other filesystems) to install plugin handlers
for kinit/kdestroy events.

Else, we could have gssd be the process to poll inotify (given
that it already polls rpc_pipefs) and then just have it fork off the
subprocess if and when it sees an interesting event.

We need to investigate how this works when the kernel keyring is used for
Kerberos credentials. I believe that in this case gsskeyd can add the gss-ctx
key to the kerberos keyring, and it will get destroyed along with all other
keys at kdestroy.

Andy Adamson (2):
  GSSD add cc_name to upcall
  ANDROS: update gsskeyd to use new /run/user/UID/krb5cc/tgt cache file

Weston Andros Adamson (1):
  WIP: Add gsskeyd

 configure.ac            |   1 +
 utils/Makefile.am       |   2 +-
 utils/gssd/gssd_proc.c  |  37 ++++-
 utils/gssd/krb5_util.c  |   2 +-
 utils/gssd/krb5_util.h  |   1 +
 utils/gsskeyd/gsskeyd.c | 371 ++++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 408 insertions(+), 6 deletions(-)
 create mode 100644 utils/gsskeyd/gsskeyd.c

-- 
1.8.3.1

