From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] NFSD: Don't hold unrefcounted creds over call to nfsd_setuser()
Date: Fri, 03 Jul 2009 15:41:26 +0100
Message-ID: <31545.1246632086@redhat.com>
References: <20090703142250.GB31538@fieldses.org> <20090702203937.GA10504@fieldses.org> <20090702133532.28297.89635.stgit@warthog.procyon.org.uk> <575.1246570293@redhat.com> <20090702230955.GB12376@fieldses.org>
Cc: dhowells@redhat.com, steved@redhat.com, rasmus-tUP8e6pgWdNlY7y4Fx5NiA@public.gmane.org,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:56428 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751477AbZGCOlb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Jul 2009 10:41:31 -0400
In-Reply-To: <20090703142250.GB31538@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields <bfields@fieldses.org> wrote:

> Also: the problem was introduced by
> 745ca2475a6ac596e3d8d37c2759c0fbe2586227, right?

Yes.

David
