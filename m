Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mxout1.mail.janestreet.com ([38.105.200.112]:43575 "EHLO
	mxout1.mail.janestreet.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752165AbbBWVZb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Feb 2015 16:25:31 -0500
Received: from tot-qpr-mailcore2.delacy.com ([172.27.56.106] helo=tot-qpr-mailcore2)
	by mxout1.mail.janestreet.com with smtp (Exim 4.82)
	(envelope-from <cperl@janestreet.com>)
	id 1YQ03S-0006z0-KU
	for linux-nfs@vger.kernel.org; Mon, 23 Feb 2015 15:56:38 -0500
Received: from mail-yh0-f42.google.com ([209.85.213.42])
	by mxgoog1.mail.janestreet.com with esmtps (UNKNOWN:AES128-GCM-SHA256:128)
	(Exim 4.72)
	(envelope-from <cperl@janestreet.com>)
	id 1YQ03S-0000Th-El
	for linux-nfs@vger.kernel.org; Mon, 23 Feb 2015 15:56:38 -0500
Received: by yhot59 with SMTP id t59so12109709yho.7
        for <linux-nfs@vger.kernel.org>; Mon, 23 Feb 2015 12:56:38 -0800 (PST)
MIME-Version: 1.0
From: Chris Perl <cperl@janestreet.com>
Date: Mon, 23 Feb 2015 15:56:17 -0500
Message-ID: <CAAih9mgvxu+L2Y7yxbHCOKX39Cm5U6ZCd5-HkJUUMFTL9moSwA@mail.gmail.com>
Subject: File Read Returns Non-existent Null Bytes
To: linux-nfs@vger.kernel.org
Cc: Chris Perl <chris.perl@gmail.com>
Content-Type: multipart/mixed; boundary=089e011838826922d0050fc7a378
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--089e011838826922d0050fc7a378
Content-Type: text/plain; charset=UTF-8

I'm currently experiencing an issue where reading from a file that is
known to only contain ascii characters can result in the process
reading that file seeing NULL bytes (0x0) in the file that never
existed.  This happens for NFSv3 clients when the file is being
updated concurrently either by another NFSv3 client or directly on the
NFS server.

Its possible this issue is already known as I've found the following
RHEL knowledge base article talking about it (unfortunately you need
to be logged in to view the full content of the following link):

https://access.redhat.com/solutions/22717

If this is already a known issue and there is relevant discussion of
it, I would appreciate it if someone could point me to it as I
couldn't find anything (but, its possible I just missed it).

If it isn't a known issue, here are the details of how I've been reproducing:

I have reproduced this on RHEL 6.5 (2.6.32.431.1.2.0.1.el6) as well as
on Fedora 21 (kernel-3.18.7-200.fc21).

In the RHEL 6.5 case, I am using two systems with the aforementioned
kernel and an Isilon as the NFS server.  In the Fedora 21 case, I am
using just one system, acting as both client and server.

The basic idea is to touch something like 10 files, then start the
attached python program (tail.py) on them "tailing" them as they grow
and finally start updating them either from another NFS client or from
the server directly.  Here is the general set of steps for reproducing
using a single system:

# mkdir -p /export/test
# mkdir -p /mnt/test
# echo '/export/test localhost(rw)' > /etc/exports
# exportfs -fa (make sure nfsd is running, etc)
# mount -t nfs -o vers=3 localhost:/export/test /mnt/test

(start the tailers)
# touch /mnt/test/file{00..09}
# for f in /mnt/test/file{00..09}; do python tail.py ${f} & done &&
cat >/dev/null

(start the updating)
# for f in /export/test/file{00..09}; do while true; do echo 'abc' >>
${f}; sleep .1; done & done

After a little while, you'll see output like the following from the
"tailer" processes:

file08: ['61', '62', '63', '0A', '61', '62', '63', '0A', '61', '62',
'63', '0A', '61', '62', '63', '0A', '00', '00', '00', '00']
file04: ['61', '62', '63', '0A', '61', '62', '63', '0A', '61', '62',
'63', '0A', '61', '62', '63', '0A', '00', '00', '00', '00']
file02: ['61', '62', '63', '0A', '61', '62', '63', '0A', '61', '62',
'63', '0A', '61', '62', '63', '0A', '00', '00', '00', '00']

As you can see, there are NULL bytes at the end that never existed.

I've done some analysis of this using SystemTap and am happy to share
details if necessary.  I believe the issue is due to concurrent
execution of `do_generic_file_read' (by the process making the read
syscall) and `nfs_update_inode' by rpciod.  rpciod updates the inode
size, but before it can invalidate the page cache, our process making
the read syscall has already found the the page and is now using the
vfs inode's size to determine how much data to copy out of the page
back into userspace.

It seems like since the VFS layer doesn't do any locking of the inode
(or at least `do_generic_file_read' doesn't), then the fact that
rpciod is updating the inode under the protection of `i_lock' doesn't
help.  My naive thought was to simply mark the page cache invalid
before updating the inode's size in `nfs_update_inode', but I'm unsure
if that would have other unwanted effects.

Any thoughts or insights appreciated.

--089e011838826922d0050fc7a378
Content-Type: text/x-python; charset=US-ASCII; name="tail.py"
Content-Disposition: attachment; filename="tail.py"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_i6icffw60

IyEvdXNyL2Jpbi9lbnYgcHl0aG9uCgppbXBvcnQgb3MKaW1wb3J0IHN5cwppbXBvcnQgc3RhdApp
bXBvcnQgdGltZQoKY2xhc3MgVGFpbGVyKG9iamVjdCk6CiAgICBkZWYgX19pbml0X18oc2VsZiwg
cGF0aCwgc3RhdF9kZWxheT0uNSwgYnVmc2l6ZT00MDk2KToKICAgICAgICBzZWxmLnBhdGggPSBw
YXRoCiAgICAgICAgc2VsZi5zdGF0X2RlbGF5ID0gc3RhdF9kZWxheQogICAgICAgIHNlbGYuYnVm
c2l6ZSA9IGJ1ZnNpemUKICAgICAgICBzZWxmLnBvcyA9IDAKCiAgICBkZWYgc2l6ZShzZWxmKToK
ICAgICAgICB3aXRoIG9wZW4oc2VsZi5wYXRoLCAncicpIGFzIGY6CiAgICAgICAgICAgIGZkID0g
Zi5maWxlbm8oKQogICAgICAgICAgICByZXR1cm4gb3MuZnN0YXQoZmQpW3N0YXQuU1RfU0laRV0K
ICAgICAgICAgICAgCiAgICBkZWYgcmVhZChzZWxmKToKICAgICAgICB3aXRoIG9wZW4oc2VsZi5w
YXRoLCAncicpIGFzIGY6CiAgICAgICAgICAgIGZkID0gZi5maWxlbm8oKQogICAgICAgICAgICBv
cy5sc2VlayhmZCwgc2VsZi5wb3MsIG9zLlNFRUtfU0VUKQogICAgICAgICAgICBkYXRhID0gIiIK
ICAgICAgICAgICAgd2hpbGUgVHJ1ZToKICAgICAgICAgICAgICAgIHRtcCA9IG9zLnJlYWQoZmQs
IHNlbGYuYnVmc2l6ZSkKICAgICAgICAgICAgICAgIGlmIHRtcCA9PSAiIjoKICAgICAgICAgICAg
ICAgICAgICBicmVhawogICAgICAgICAgICAgICAgZWxzZToKICAgICAgICAgICAgICAgICAgICBk
YXRhICs9IHRtcAogICAgICAgICAgICAgICAgICAgIHNlbGYucG9zICs9IGxlbih0bXApCiAgICAg
ICAgcmV0dXJuIGRhdGEKCiAgICBkZWYgcnVuKHNlbGYpOgogICAgICAgIHdoaWxlIFRydWU6CiAg
ICAgICAgICAgIGZpbGVfc2l6ZSA9IHNlbGYuc2l6ZSgpCiAgICAgICAgICAgIGlmIGZpbGVfc2l6
ZSA+IHNlbGYucG9zOgogICAgICAgICAgICAgICAgZGF0YSA9IHNlbGYucmVhZCgpCiAgICAgICAg
ICAgICAgICBpZiAiXHgwMCIgaW4gZGF0YToKICAgICAgICAgICAgICAgICAgICBwcmludCAiJXM6
ICVyIiAlIChzZWxmLnBhdGgsIFsiJTAyWCIgJSBvcmQoeCkgZm9yIHggaW4gZGF0YV0pCiAgICAg
ICAgICAgICAgICAgICAgYnJlYWsKICAgICAgICAgICAgdGltZS5zbGVlcChzZWxmLnN0YXRfZGVs
YXkpCiAgICAgICAgCmRlZiBtYWluKCk6CiAgICB0YWlsZXIgPSBUYWlsZXIoc3lzLmFyZ3ZbMV0s
IGJ1ZnNpemU9MzI3NjgpCiAgICB0YWlsZXIucnVuKCkKCmlmIF9fbmFtZV9fID09ICJfX21haW5f
XyI6CiAgICBtYWluKCkK
--089e011838826922d0050fc7a378--
