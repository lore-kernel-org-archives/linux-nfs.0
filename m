From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: Re: [ath9k-devel] [PATCH net-next 00/21] treewide: Use
 consistent api style for address testing
Date: Fri, 19 Oct 2012 11:55:17 -0400
Message-ID: <20121019115517.7b8514a8@mj>
References: <cover.1350618006.git.joe@perches.com>
	<1350630254.2293.183.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	linux-doc@vger.kernel.org, brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	users-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org, linux-sctp@vger.kernel.org,
	devel-s9riP+hp16TNLxjTenLetw@public.gmane.org, dev@openvswitch.org,
	linux-s390@vger.kernel.org, wimax-BPSAo7wm5JOHVYUYWc+uSQ@public.gmane.org,
	linux-scsi@vger.kernel.org, linux-rdma@vger.kernel.org,
	bridge@lists.linux-foundation.org, lvs-devel@vger.kernel.org,
	coreteam@netfilter.org, b43-dev@lists.infradead.org,
	cbe-oss-dev@lists.ozlabs.org, devel@driverdev.osuosl.org,
	user-mode-linux-devel@lists.sourceforge.net,
	devicetree-discuss@lists.ozlabs.org,
	davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org, netfilter@vger.kernel.org,
	user-mode-linux-user@lists.sourceforge.net,
	linux-arm-kernel@lists.infradead.org, linux-nfs@vger.kernel.org,
	linux-parisc@vger.kernel.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org,
	l
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <dev-bounces@openvswitch.org>
In-Reply-To: <1350630254.2293.183.camel@edumazet-glaptop>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request@openvswitch.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev@openvswitch.org>
List-Help: <mailto:dev-request@openvswitch.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request@openvswitch.org?subject=subscribe>
Sender: dev-bounces@openvswitch.org
Errors-To: dev-bounces@openvswitch.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 19 Oct 2012 09:04:14 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Yes they are some names discrepancies, thats a big deal.
> 
> And we have alloc_skb() / kfree_skb() / skb_clone() 
> 
> Why not skb_alloc() / skb_free() / skb_clone() ?
> 
> Some people actually know current code by name of functions, they dont
> want to change their mind and having to grep include files and git log
> to learn the new names of an old function, especially when traveling
> and using a laptop.

I agree.

Also, it makes sense to introduce a more consistent name for a function
when it's improved in some way and the callers need to be adjusted or
re-checked.

That way, the old name can be phased out as the code is made compatible
with the new function.

-- 
Regards,
Pavel Roskin
