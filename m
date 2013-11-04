Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:28318 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751497Ab3KDTUL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Nov 2013 14:20:11 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Steve Dickson <SteveD@redhat.com>, Bruce Fields <bfields@fieldses.org>
CC: Jeff Layton <jlayton@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "dpquigl@davequigley.com" <dpquigl@davequigley.com>
Subject: Labeled NFS: Is the value of FATTR4_WORD2_SECURITY_LABEL correct?
Date: Mon, 4 Nov 2013 19:20:09 +0000
Message-ID: <58879923-7AE9-4E5B-A29E-4EA26E8330DD@netapp.com>
References: <1383389838-1858-1-git-send-email-jlayton@redhat.com>
 <C85EF88C-B4F8-484C-A00D-5A86ACB61C10@netapp.com>
 <5277BAFB.9070109@RedHat.com>
 <48054582-1F6A-4A27-AE62-C9B0AE8F9619@netapp.com>
 <5277DFBB.1010901@RedHat.com>
In-Reply-To: <5277DFBB.1010901@RedHat.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

AFAICS from draft-ietf-nfsv4-minorversion2-20.txt, the ‘sec_label’ attribute has Id == 80.

Shouldn’t that mean that FATTR4_WORD2_SECURITY_LABEL should take the value (1 << (80-64))?

i.e.

#define FATTR4_WORD2_SECURITY_LABEL (1UL << 16)

instead of the current value of (1UL << 17)…

Trond

--
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

