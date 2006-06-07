From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] [PATCH] NFS server does not update mtime on
	setattr	request
Date: Wed, 07 Jun 2006 13:17:03 -0400
Message-ID: <1149700624.26188.15.camel@localhost>
References: <4485C3FE.5070504@redhat.com>
	 <1149658707.27298.10.camel@localhost> <4486E662.5080900@redhat.com>
	 <20060607151754.GB23954@fieldses.org>  <4486F020.3030707@redhat.com>
	 <1149694742.26188.6.camel@localhost>  <4486F479.90406@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>,
	NFS List <nfs@lists.sourceforge.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932350AbWFGRRU@vger.kernel.org>
To: Peter Staubach <staubach@redhat.com>
In-Reply-To: <4486F479.90406@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Wed, 2006-06-07 at 11:44 -0400, Peter Staubach wrote:

> I am curious about how this would break truncate?

According to SuSv43, truncate should result in changes to
mtime/ctime/suid/sgid if and only if the file size changes. The
combination of disabling the client caching and always setting
mtime/ctime on the server will therefore clearly break truncate.

Cheers,
  Trond
