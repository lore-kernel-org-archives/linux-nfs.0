From: David Howells <dhowells@redhat.com>
Subject: Re: [v2.6.30 nfs+fscache] kswapd1: blocked for more
	than 120 seconds
Date: Mon, 15 Jun 2009 15:03:47 +0100
Message-ID: <25124.1245074627@redhat.com>
References: <20090615123658.GC4721@jukie.net>
	<20090613182721.GA24072@jukie.net> <25357.1245068384@redhat.com>
Reply-To: Linux filesystem caching discussion list <linux-cachefs@redhat.com>
Cc: linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-cachefs@redhat.com,
	linux-kernel@vger.kernel.org
To: Bart Trojanowski <bart@jukie.net>
Return-path: <linux-cachefs-bounces@redhat.com>
In-Reply-To: <20090615123658.GC4721@jukie.net>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/linux-cachefs>,
	<mailto:linux-cachefs-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/linux-cachefs>
List-Post: <mailto:linux-cachefs@redhat.com>
List-Help: <mailto:linux-cachefs-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/linux-cachefs>,
	<mailto:linux-cachefs-request@redhat.com?subject=subscribe>
Sender: linux-cachefs-bounces@redhat.com
Errors-To: linux-cachefs-bounces@redhat.com
List-ID: <linux-nfs.vger.kernel.org>

Bart Trojanowski <bart@jukie.net> wrote:

> Sure, I'll create a new lvm volume with ext3 on it and give it a try.
> Can I just shutdown cachefilesd, relocate the cahce, and restart the
> daemon without remounting the nfs volumes?

Yes...  But it won't begin caching any files that are already in the inode
cache in memory until they're discarded from the icache and are iget'd
again...  Which is something else I need to look at.

David
