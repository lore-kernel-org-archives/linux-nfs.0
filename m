Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f174.google.com ([209.85.220.174]:37235 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751310Ab2JXAIK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Oct 2012 20:08:10 -0400
Received: by mail-vc0-f174.google.com with SMTP id fk26so4932072vcb.19
        for <linux-nfs@vger.kernel.org>; Tue, 23 Oct 2012 17:08:09 -0700 (PDT)
MIME-Version: 1.0
From: Brock Noland <brock@cloudera.com>
Date: Tue, 23 Oct 2012 19:07:49 -0500
Message-ID: <CAFukC=5Mq3CwK=u7YP_=cF6gab+0K_mP-Sj0k8fCk_a2f=xsfg@mail.gmail.com>
Subject: readdir from Linux NFS4 client when cookieverf is no longer valid
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

It is my first message to this list, so please understand I that I
might be in the wrong place or be wrong altogether. In my spare time I
am implementing a NFS Proxy for the Hadoop Distributed File System:
https://github.com/brockn/hdfs-nfs-proxy The scenario is as follows,
two clients RHEL 6.3 and 5.8:

Client 1) Creating and deleting files in a directory
Client 2) Listing the files in that directory with a wildcard: foo*

Eventually client 1 creates a file while client 2 is listing the directory.

Regarding readdir from a NFS4 client, based on RFC 3530 it is my
understanding that if the cookie verifier is invalid, I should return
NFS4ERR_NOT_SAME. I believe that because of this statement "If the
server determines that the cookieverf is no longer valid for the
directory, the error NFS4ERR_NOT_SAME must be returned." In my case, I
am using the number of entries in the directory as the cookieverf.
Based on the statement above, it was my belief that the client should
then re-read the directory.

However, what occurs is the nfs client bails and eventually the client
gets a NOENT after the wildcard foo* is send to the server for a
lookup request. When the client receives NFS4ERR_NOT_SAME should it
invalidate the directory and read it from scratch? I tried sending
NFS4ERR_BAD_COOKIE which had the same effect as NOT_SAME.

Oct 23 17:36:13 node102 kernel: NFS: nfs_do_filldir() filling ended @
cookie 2147483746; returning = 0
Oct 23 17:36:13 node102 kernel: _nfs4_proc_readdir: dentry = /tmp,
cookie = 2147483746
Oct 23 17:36:13 node102 kernel: encode_compound: tag=
Oct 23 17:36:13 node102 kernel: encode_readdir: cookie = 2147483746,
verifier = 00000000:53010000, bitmap = 0018011a:0030a23a
Oct 23 17:36:13 node102 kernel: nfs4_xdr_enc_readdir: inlined page
args = (60, ffff88012ba2fd08, 0, 32768)
Oct 23 17:36:13 node102 kernel: _nfs4_proc_readdir: returns -10027
Oct 23 17:36:13 node102 kernel: nfs4_map_errors could not handle NFSv4
error 10027
Oct 23 17:36:13 node102 kernel: NFS: readdir(/tmp) returns -5
Oct 23 17:36:13 node102 kernel: NFS: readdir(/tmp) starting at cookie 102
Oct 23 17:36:13 node102 kernel: _nfs4_proc_readdir: dentry = /tmp,
cookie = 2147483746
Oct 23 17:36:13 node102 kernel: encode_compound: tag=
Oct 23 17:36:13 node102 kernel: encode_readdir: cookie = 2147483746,
verifier = 00000000:53010000, bitmap = 0018011a:0030a23a
Oct 23 17:36:13 node102 kernel: nfs4_xdr_enc_readdir: inlined page
args = (60, ffff88012ba2fd08, 0, 32768)
Oct 23 17:36:13 node102 kernel: _nfs4_proc_readdir: returns -10027
Oct 23 17:36:13 node102 kernel: nfs4_map_errors could not handle NFSv4
error 10027
