From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [RFC][PATCH 2/4] sunrpc: Use utsnamespaces
Date: Tue, 06 Jan 2009 17:42:12 -0500
Message-ID: <1231281732.4173.6.camel@heimdal.trondhjem.org>
References: <20090106011314.534653345@us.ibm.com>
	 <20090106011314.961946803@us.ibm.com> <20090106200229.GA17031@us.ibm.com>
	 <1231274682.20316.65.camel@heimdal.trondhjem.org>
	 <20090106215831.GE18147@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Matt Helsley <matthltc@us.ibm.com>,
	Linux Containers <containers@lists.linux-foundation.org>,
	linux-nfs@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Containers <containers@lists.osdl.org>,
	Cedric Le Goater <clg@fr.ibm.com>
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758741AbZAFWmp@vger.kernel.org>
In-Reply-To: <20090106215831.GE18147@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-01-06 at 15:58 -0600, Serge E. Hallyn wrote:

> So should we use patch 2/4, plus (as someone - was it you? - suggested)
> using a DEFAULT instead of init_utsname()->nodename when
> current->utsname() == NULL?

No. I'm don't think that 2/4 is correct either. Basically, 2/4 is saying
that the container that first mounts the filesystem 'owns' it. However
at the same time we know that the lifetime of the filesystem is in no
way bounded by the lifetime of the container, and that's what gets you
into trouble with 'umount' in the first place.

IMO, the current code is the most correct approach, in that it assumes
that the filesystems are owned by the 'init' namespace.

Trond
