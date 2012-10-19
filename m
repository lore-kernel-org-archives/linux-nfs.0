From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 00/21] treewide: Use consistent api
 style for address testing
Date: Fri, 19 Oct 2012 09:04:14 +0200
Message-ID: <1350630254.2293.183.camel@edumazet-glaptop>
References: <cover.1350618006.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-mips@linux-mips.org, linux-usb@vger.kernel.org,
	linux-doc@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	linux-kernel@vger.kernel.org, linux-sctp@vger.kernel.org,
	devel@open-fcoe.org, dev@openvswitch.org, linux-s390@vger.kernel.org,
	user-mode-linux-devel@lists.sourceforge.net,
	linux-scsi@vger.kernel.org, linux-rdma@vger.kernel.org,
	bridge@lists.linux-foundation.org, lvs-devel@vger.kernel.org,
	coreteam@netfilter.org, b43-dev@lists.infradead.org,
	cbe-oss-dev@lists.ozlabs.org, devel@driverdev.osuosl.org,
	wimax@linuxwimax.org, devicetree-discuss@lists.ozlabs.org,
	linux-nfs@vger.kernel.org, netfilter@vger.kernel.org,
	user-mode-linux-user@lists.sourceforge.net,
	linux-arm-kernel@lists.infradead.org,
	davinci-linux-open-source@linux.davincidsp.com,
	linux-parisc@vger.kernel.org, netdev@vger.kernel.org,
	b.a.t.m.a.n@lists.open-mesh.org, linux-wireless@vger.kernel.org,
	us
To: Joe Perches <joe@perches.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <cover.1350618006.git.joe@perches.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2012-10-18 at 20:55 -0700, Joe Perches wrote:
> ethernet, ipv4, and ipv6 address testing uses 3 different api naming styles.
> 
> ethernet uses:	is_<foo>_ether_addr
> ipv4 uses:	ipv4_is_<foo>
> ipv6 uses:	ipv6_addr_<foo>
> 
> Standardize on the ipv6 style of <prefix>_addr_<type> to reduce
> the number of styles to remember.
> 
> The new consistent styles are:
> 
> eth_addr_<foo>(const u8 *)
> ipv4_addr_<foo>(__be32)
> ipv6_addr_<foo>(const struct in6_addr *)
> 
> Add temporary backward compatibility #defines for the old names too.
> 
> Joe Perches (21):
>   etherdevice: Rename is_<foo>_ether_addr tests to eth_addr_<foo>
>   net: Convert is_<foo>_ether_addr uses to eth_addr_<foo>
>   arch: Convert is_<foo>_ether_addr uses to eth_addr_<foo>
>   wireless: Convert is_<foo>_ether_addr uses to eth_addr_<foo>
>   drivers: net: Convert is_<foo>_ether_addr uses to eth_addr_<foo>
>   staging: Convert is_<foo>_ether_addr uses to eth_addr_<foo>
>   infiniband: Convert is_<foo>_ether_addr uses to eth_addr_<foo>
>   scsi: Convert is_<foo>_ether_addr uses to eth_addr_<foo>
>   of: Convert is_<foo>_ether_addr uses to eth_addr_<foo>
>   s390: Convert is_<foo>_ether_addr uses to eth_addr_<foo>
>   usb: Convert is_<foo>_ether_addr uses to eth_addr_<foo>
>   uwb: Convert is_<foo>_ether_addr uses to eth_addr_<foo>
>   Documentation: networking: Convert is_<foo>_ether_addr uses to eth_addr_<foo>
>   llc_if.h: Convert is_<foo>_ether_addr uses to eth_addr_<foo>
>   in.h: Rename ipv4_is_<foo> functions to ipv4_addr_<foo>
>   net: Convert ipv4_is_<foo> uses to ipv4_addr_<foo>
>   infiniband: Convert ipv4_is_<foo> uses to ipv4_addr_<foo>
>   ath6kl: Convert ipv4_is_<foo> uses to ipv4_addr_<foo>
>   parisc: Convert ipv4_is_<foo> uses to ipv4_addr_<foo>
>   lockd: Convert ipv4_is_<foo> uses to ipv4_addr_<foo>
>   sctp: Convert ipv4_is_<foo> uses to ipv4_addr_<foo>

Yes they are some names discrepancies, thats a big deal.

And we have alloc_skb() / kfree_skb() / skb_clone() 

Why not skb_alloc() / skb_free() / skb_clone() ?

Some people actually know current code by name of functions, they dont
want to change their mind and having to grep include files and git log
to learn the new names of an old function, especially when traveling and
using a laptop.

Sure, when we want to use eth_random_addr(), a grep into include files
to check if its still the right name (old one was random_ether_addr())
is OK because we dont use this one often.

If you think about it, eth_random_addr() was not the perfect name.

Think about all the documentation you can find outside of kernel tree,
RFC and things like that, copy/pasting some linux kernel code.

This kind of changes make our life more difficult, when we have to
backport patches or rebase code, or even perform some searches to find
prior issues/discussions.

Life of a kernel developer is not only dealing with latest Linus (or
-next) tree, and using automatic 'tools'.

Thats a real pain for me at least.
