From: Igor Zhbanov <izh1979@gmail.com>
Subject: Re: [PATCH] nfsd: nfsd should drop CAP_MKNOD for non-root
Date: Wed, 18 Mar 2009 23:31:43 +0300
Message-ID: <f44001920903181331t6b4d6d2ev622d57604ba24866@mail.gmail.com>
References: <1237393292-14934-1-git-send-email-bfields@fieldses.org>
	 <1237393292-14934-2-git-send-email-bfields@fieldses.org>
	 <1237393292-14934-3-git-send-email-bfields@fieldses.org>
	 <20090318170843.GA29045@us.ibm.com>
	 <20090318173221.GA16077@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Serge E. Hallyn" <serue@us.ibm.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	stable@kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f169.google.com ([209.85.218.169]:57859 "EHLO
	mail-bw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754006AbZCRUbq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Mar 2009 16:31:46 -0400
In-Reply-To: <20090318173221.GA16077@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

That's good and I'm glad to see patch for CAP_NFSD_MASK in git. Thanks. :-)
Waiting for CAP_FS_MASK to be fixed too.

By the way, I don't see git repository for 2.4.x kernel. Could you fix
2.4.x too?
