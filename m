From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] All Arch: remove linkage for sys_nfsservctl system call
Date: Wed, 31 Aug 2011 11:15:04 +0100
Message-ID: <27331.1314785704@redhat.com>
References: <20110826220311.GA18140@fieldses.org> <1312810169.2591.1153.camel@deadeye> <20110808155538.GB904@fieldses.org> <20110808180658.GC29924@decadent.org.uk>
Cc: dhowells@redhat.com,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Ben Hutchings <ben@decadent.org.uk>,
	Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20110826220311.GA18140@fieldses.org>
Sender: linux-arch-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields <bfields@fieldses.org> wrote:

> From: NeilBrown <neilb@suse.de>
> 
> The nfsservctl system call is now gone, so we should remove all
> linkage for it.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>

Acked-by: David Howells <dhowells@redhat.com> [FRV/MN10300]
