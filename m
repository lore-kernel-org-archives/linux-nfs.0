From: David Howells <dhowells@redhat.com>
Subject: Re: PROBLEM: nfsd crashes in 2.6.29
Date: Tue, 28 Apr 2009 18:31:26 +0100
Message-ID: <25153.1240939886@redhat.com>
References: <20090428164133.GP17891@fieldses.org> <49D218C8.2040503@msconsult.dk> <20090401185759.GD8899@fieldses.org> <20090402105943.14031ff3mhfka6bk@ssl.msconsult.dk>
Cc: dhowells@redhat.com,
	Rasmus =?utf-8?Q?B=C3=B8g?= Hansen <rasmus-tUP8e6pgWdNlY7y4Fx5NiA@public.gmane.org>,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:39455 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760543AbZD1Rce (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Apr 2009 13:32:34 -0400
In-Reply-To: <20090428164133.GP17891@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields <bfields@fieldses.org> wrote:

> >> Without trying to figure out where that is, just looking at the
> >> offset...  That would be consistent with current_cred()->security being
> >> NULL, since the cred_sid(cred) in inode_has_perm does tsec->sid, where
> >> tsec is

It oughtn't to be possible...  Unless, perhaps, the credentials have been
freed.  During the process of freeing the creds, the security pointer is
cleared.

Are you running with CONFIG_DEBUG_SLAB=n?  If so, would it be possible to flip
it to =y?

David
