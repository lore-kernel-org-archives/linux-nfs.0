From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] [PATCH] NFS server does not update mtime on setattr request
Date: Wed, 7 Jun 2006 12:03:34 -0400
Message-ID: <20060607160334.GB22335@fieldses.org>
References: <4485C3FE.5070504@redhat.com> <1149658707.27298.10.camel@localhost> <4486E662.5080900@redhat.com> <20060607151754.GB23954@fieldses.org> <4486F020.3030707@redhat.com> <20060607154258.GA22335@fieldses.org> <4486F5C7.60606@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>, NFS List <nfs@lists.sourceforge.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932282AbWFGQDn@vger.kernel.org>
To: Peter Staubach <staubach@redhat.com>
In-Reply-To: <4486F5C7.60606@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Wed, Jun 07, 2006 at 11:50:31AM -0400, Peter Staubach wrote:
> The Red Hat BZ number is 193621.

"You are not authorized to access bug #193621", it tells me....

> The description is that when zero length files are copied, even over
> an existing zero length file, the mtime on the target file does not
> change.

Is the server-side patch sufficient on its own?

--b.
