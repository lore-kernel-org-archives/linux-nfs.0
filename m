From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] zerocopy NFS, ipv4 infrastructure
Date: Wed, 16 Oct 2002 14:28:35 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20021016.142835.52135022.davem@redhat.com>
References: <233C89823A37714D95B1A891DE3BCE521423D4@xch-b.win.zambeel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, linux-net@vger.kernel.org,
	neilb@cse.unsw.edu.au, taka@valinux.co.jp
Return-path: <linux-net-owner@vger.kernel.org>
To: dheeraj@Zambeel.com
In-Reply-To: <233C89823A37714D95B1A891DE3BCE521423D4@xch-b.win.zambeel.com>
List-ID: <nfs.lists.sourceforge.net>


Both e1000 and tg3 can both checksum a fragmented UDP packet,
supporting this properly isn't easy though and it is possible
early 2.6.x likely won't support this.

