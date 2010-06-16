From: Fred Isaman <iisaman@netapp.com>
Subject: patch "net: deliver skbs on inactive slaves to exact matches" stalls
	nfs mounts
Date: Wed, 16 Jun 2010 17:27:12 -0400
Message-ID: <AANLkTil5gBFkXgmImU1Mt8uJXKTTNCen8NtzWpBxaYdq@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: John Fastabend <john.r.fastabend@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org, NFS list <linux-nfs@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I am using vmware fusion 3.1.0 on a macbook pro host with a fedora 12
guest running a 2.6.35-rc3 based kernel,  Upgrading from rc2 to rc3
introduced a long delay when the guest attempts an nfs mount (~120
secs).  Reverting patch 597a264b1a9c7e36d1728f677c66c5c1f7e3b837
"net: deliver skbs on inactive slaves to exact matches" changes back
to normal behavior.

Fred
