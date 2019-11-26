Return-Path: <SRS0=F8lJ=ZS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63325C432C0
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Nov 2019 15:47:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2A7F12071E
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Nov 2019 15:47:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="N6CVFeBl"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728641AbfKZPrW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 26 Nov 2019 10:47:22 -0500
Received: from us-smtp-delivery-1.mimecast.com ([207.211.31.120]:50865 "EHLO
        us-smtp-1.mimecast.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1727533AbfKZPrW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Nov 2019 10:47:22 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1574783241;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding;
        bh=Klmgo9VR6pUa/eaA3us09CLD2Dg/aX0EqkhFUyHPAf8=;
        b=N6CVFeBlltIqOwWCYC+ipZqqszaGNkgYs2wRQjoL2/IcGLPD7iD2gz6jPSLo9g38avRGQJ
        p035Je+BSTG02vwTSaRYcEjX/ldoQgMAPzG1A8422Hir1J3Jejx+lr8NheayRsfF/swVIa
        10eflEJVJ2IkAxNFKhLU6162ezd99jg=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-411-TzFt9ly9PHKzCWgL8bGdrQ-1; Tue, 26 Nov 2019 10:47:20 -0500
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 6247280268B
        for <linux-nfs@vger.kernel.org>; Tue, 26 Nov 2019 15:47:19 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-123-90.rdu2.redhat.com [10.10.123.90])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 4451B88862;
        Tue, 26 Nov 2019 15:47:19 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id D448A20781; Tue, 26 Nov 2019 10:47:18 -0500 (EST)
From:   Scott Mayhew <smayhew@redhat.com>
To:     steved@redhat.com
Cc:     linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH 0/3] A few small nfsdcld fixes
Date:   Tue, 26 Nov 2019 10:47:15 -0500
Message-Id: <20191126154718.22645-1-smayhew@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-MC-Unique: TzFt9ly9PHKzCWgL8bGdrQ-1
X-Mimecast-Spam-Score: 0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The first two patches fix problems I noticed when trying to build an rpm
package w/ nfsdcld enabled.  The third patch fixes an issue I found
trying to use nfsdcld on a ppc64le system.

Scott Mayhew (3):
  nfsdcld: don't override sbindir
  systemd: install nfsdcld.service when nfsdcld is enabled
  nfsdcld: getopt_long() returns an int, not a char

 systemd/Makefile.am       | 5 +++++
 utils/nfsdcld/Makefile.am | 4 ----
 utils/nfsdcld/nfsdcld.c   | 2 +-
 3 files changed, 6 insertions(+), 5 deletions(-)

--=20
2.17.2

