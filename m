Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-3.desy.de ([131.169.56.156]:38591 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932095AbcELJDJ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 May 2016 05:03:09 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id BB902280373
	for <linux-nfs@vger.kernel.org>; Thu, 12 May 2016 11:03:06 +0200 (CEST)
Received: from ZITSWEEP4.win.desy.de (zitsweep4.win.desy.de [131.169.97.98])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id ADA1D1504
	for <linux-nfs@vger.kernel.org>; Thu, 12 May 2016 11:03:06 +0200 (MEST)
Date: Thu, 12 May 2016 11:03:06 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Message-ID: <168192002.12755981.1463043786072.JavaMail.zimbra@desy.de>
In-Reply-To: <BC64443A-0721-414A-9695-CDB2015099AB@primarydata.com>
References: <1463004843-3733-1-git-send-email-tigran.mkrtchyan@desy.de> <BC64443A-0721-414A-9695-CDB2015099AB@primarydata.com>
Subject: Re: [PATCH] nfs4: client: do not send empty SETATTR after
 OPEN_CREATE
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



----- Original Message -----
> From: "Trond Myklebust" <trondmy@primarydata.com>
> To: "Tigran Mkrtchyan" <tigran.mkrtchyan@desy.de>
> Cc: linux-nfs@vger.kernel.org
> Sent: Thursday, May 12, 2016 12:25:18 AM
> Subject: Re: [PATCH] nfs4: client: do not send empty SETATTR after OPEN_CREATE

> On 5/11/16, 18:14, "Tigran Mkrtchyan" <tigran.mkrtchyan@desy.de> wrote:
> 
>>OPEN_CREATE with EXCLUSIVE4_1 sends initial file permission.
>>Ignoring  fact, that server have indicated that file mod is set, client
>>will send yet another SETATTR request, but, as mode is already set,
>>new SETATTR will be empty. This is not a problem, nevertheless
>>an extra roundtrip and slow open on high latency networks.
>>
>>This change is aims to by-pass setattr if there are no attributes defined.
>>
>>Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
>>---
>> fs/nfs/nfs4proc.c | 6 ++++++
>> 1 file changed, 6 insertions(+)
>>
>>diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>>index 327b8c3..f6b278f 100644
>>--- a/fs/nfs/nfs4proc.c
>>+++ b/fs/nfs/nfs4proc.c
>>@@ -2724,6 +2724,12 @@ static int nfs4_do_setattr(struct inode *inode, struct
>>rpc_cred *cred,
>> 		.inode = inode,
>> 	};
>> 	int err;
>>+	/*
>>+	 * a shortcut: it there are no attributes to be updated, do not send setattr
>>at all
>>+	 */
>>+	if (sattr->ia_valid == ATTR_OPEN)
>>+		return 0;
>>+
> 
> There is already a similar optimization in nfs_setattr(), so I don’t think it
Obviously not mature enough.


> makes sense to put this in nfs4_do_setattr(). We should rather just fix
> _nfs4_do_open().

Agree. See v2.

Tigran.

> 
>> 	do {
>> 		err = _nfs4_do_setattr(inode, cred, fattr, sattr, state, ilabel, olabel);
>> 		switch (err) {
>>--
>>2.5.5
>>
> 
> N�����r��y���b�X��ǧv�^�)޺{.n�+����{���"��^n�r���z���h����&���G���h�(�階�ݢj"���m�����z�ޖ���f���h���~�m�
