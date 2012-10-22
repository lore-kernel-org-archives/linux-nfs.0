Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:55161 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755814Ab2JVVnj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Oct 2012 17:43:39 -0400
Date: Mon, 22 Oct 2012 17:43:32 -0400
From: Jim Rees <rees@umich.edu>
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Added more compile warning options
Message-ID: <20121022214332.GA14793@umich.edu>
References: <1350939654-25126-1-git-send-email-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1350939654-25126-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve Dickson wrote:

  To ensure the code compiles cleaner, the following warning options
  are now set
      -Wall -Wextra -Wstrict-prototypes -Wstrict-aliasing
      -Wconversion -Wsign-conversion -Wmissing-prototypes
      -Wsign-conversion -pedantic -Wmissing-prototypes

You only need to specify them once.  You've got sign-conversion and
missing-prototypes twice.  Also I think -pedantic is going too far.
