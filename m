From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH v2 16/47] nfsd41: match clientid establishment method
Date: Wed, 1 Apr 2009 20:14:54 -0400
Message-ID: <20090402001454.GA14699@fieldses.org>
References: <49CDDFC2.4070402@panasas.com> <1238229137-10764-1-git-send-email-bhalevy@panasas.com> <20090331030418.GC7653@fieldses.org> <49D1D901.5000706@panasas.com> <3BDF03B5-9772-49DA-82D9-5D2CF70CC501@netapp.com> <20090402000127.GK8899@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
	pnfs@linux-nfs.org
To: Andy Adamson <andros@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:35648 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756403AbZDBAO5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Apr 2009 20:14:57 -0400
In-Reply-To: <20090402000127.GK8899@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

By the way, one more random question: the basic tests I run before
submitting patches, for example, are mainly just pynfs and cthon.  I'd
should start adding some 4.1 tests: suggestions?  E.g. could anyone
suggest a reasonable commandline for the 4.1 pynfs tests that excludes
known failing tests?

--b.
