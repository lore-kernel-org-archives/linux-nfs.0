Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58083 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751836Ab0A3DsI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Jan 2010 22:48:08 -0500
Date: Fri, 29 Jan 2010 22:48:05 -0500 (EST)
From: CAI Qian <caiqian@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org, pnfs@linux-nfs.org,
        James Laska <jlaska@redhat.com>, caiqian@redhat.com
Message-ID: <1945482165.647591264823285285.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <20100129164229.GB24042@fieldses.org>
Subject: Re: [pnfs] Fedora NFSv4 Test Day
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


> Note on https://fedoraproject.org/wiki/QA:Testcase_nfs_pynfs there
> seems to be a mix-up between pynfs and connectathon instructions.

Thanks for pointing out, Bruce! Yes, that page still need some cleanup here to also include known failures from pynfs that you pointed out earlier, so the tester can skip those false alarms. I'll fix that one up.

CAI Qian
