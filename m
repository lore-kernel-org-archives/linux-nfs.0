Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f196.google.com ([209.85.213.196]:35206 "EHLO
	mail-ig0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751431AbcE0XuZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 May 2016 19:50:25 -0400
MIME-Version: 1.0
In-Reply-To: <57488072.6030502@oracle.com>
References: <ed695df4-9072-41ae-93b0-8479873333f6@Netapp.com>
	<57488072.6030502@oracle.com>
Date: Fri, 27 May 2016 16:50:24 -0700
Message-ID: <CA+55aFz6vQt-9kA0hdB-sdG4N9PzP5cp6m5NaeAV9sSLSQ41Ug@mail.gmail.com>
Subject: Re: [GIT PULL] Please pull NFS client changes for Linux 4.7
From: Linus Torvalds <torvalds@linux-foundation.org>
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Content-Type: multipart/mixed; boundary=f46d042abf1409823c0533db924c
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--f46d042abf1409823c0533db924c
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Fri, May 27, 2016 at 10:14 AM, Boris Ostrovsky
<boris.ostrovsky@oracle.com> wrote:
>
> This breaks on older compilers:
>
>   CC      fs/nfs/nfs4state.o
> /home/build/linux-linus/fs/nfs/nfs4state.c:69: error: unknown field
> =E2=80=98data=E2=80=99 specified in initializer

Does the attached patch fix it for you?

I don't have easy access to the old compiler, but I _think_ the
trivial patch of just adding braces around the data initializer should
make old gcc's happy

              Linus

--f46d042abf1409823c0533db924c
Content-Type: text/plain; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ioqdsgek0

IGZzL25mcy9uZnM0c3RhdGUuYyB8IDIgKy0KIDEgZmlsZSBjaGFuZ2VkLCAxIGluc2VydGlvbigr
KSwgMSBkZWxldGlvbigtKQoKZGlmZiAtLWdpdCBhL2ZzL25mcy9uZnM0c3RhdGUuYyBiL2ZzL25m
cy9uZnM0c3RhdGUuYwppbmRleCA1MDc1NTkyZGYxNDUuLjk2NzlmNDc0OTM2NCAxMDA2NDQKLS0t
IGEvZnMvbmZzL25mczRzdGF0ZS5jCisrKyBiL2ZzL25mcy9uZnM0c3RhdGUuYwpAQCAtNjYsNyAr
NjYsNyBAQAogI2RlZmluZSBPUEVOT1dORVJfUE9PTF9TSVpFCTgKIAogY29uc3QgbmZzNF9zdGF0
ZWlkIHplcm9fc3RhdGVpZCA9IHsKLQkuZGF0YSA9IHsgMCB9LAorCXsgLmRhdGEgPSB7IDAgfSB9
LAogCS50eXBlID0gTkZTNF9TUEVDSUFMX1NUQVRFSURfVFlQRSwKIH07CiBzdGF0aWMgREVGSU5F
X01VVEVYKG5mc19jbGlkX2luaXRfbXV0ZXgpOwo=
--f46d042abf1409823c0533db924c--
