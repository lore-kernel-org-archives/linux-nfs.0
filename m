Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f180.google.com ([209.85.214.180]:58307 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755820AbbB1ALS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Feb 2015 19:11:18 -0500
MIME-Version: 1.0
In-Reply-To: <20150227224846.GB8750@fieldses.org>
References: <cover.1424907511.git.agruenba@redhat.com>
	<20150227224846.GB8750@fieldses.org>
Date: Sat, 28 Feb 2015 01:11:17 +0100
Message-ID: <CAHpGcMK7k3Y3PhxdU-CB-0q1RDo12zZuyNaWPdJ1TM-9nL_XyQ@mail.gmail.com>
Subject: Re: [RFC 00/21] Richacls
From: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-02-27 23:48 GMT+01:00 J. Bruce Fields <bfields@fieldses.org>:
> I remember my main concern being how we collapse the ACL and mask bits
> to map a richacl to an NFSv4 (or Samba) ACL.

What richacl_apply_masks() in librichacl does and what "richacl --get" without
the --raw option displays. The basic algorithms are still unchanged:

  http://www.bestbits.at/richacl/draft-gruenbacher-nfsv4-acls-in-posix-00.html

Andreas
