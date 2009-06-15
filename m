From: David Howells <dhowells@redhat.com>
Subject: Re: [v2.6.30 nfs+fscache] kswapd1: blocked for more
	than 120 seconds
Date: Mon, 15 Jun 2009 13:19:44 +0100
Message-ID: <25357.1245068384@redhat.com>
References: <20090613182721.GA24072@jukie.net>
Reply-To: Linux filesystem caching discussion list <linux-cachefs@redhat.com>
Cc: linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-cachefs@redhat.com,
	linux-kernel@vger.kernel.org
To: Bart Trojanowski <bart@jukie.net>
Return-path: <linux-cachefs-bounces@redhat.com>
In-Reply-To: <20090613182721.GA24072@jukie.net>
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

>   - my cachefilesd uses xfs on MD raid0 volume over two SATA disks

Is it possible for you try it with ext3 instead of XFS?  I'd be interested to
know if this is something XFS specific.

David
