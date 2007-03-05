From: Neil Brown <neilb@suse.de>
Subject: Re: [NFS] [PATCH 001 of 3] knfsd: Use recv_msg to get peer address for NFSD instead of code-copying
Date: Tue, 6 Mar 2007 10:47:53 +1100
Message-ID: <17900.44073.791834.143726@notabene.brown>
References: <20070302151748.5226.patches@notabene>
	<1070302042825.5760@suse.de>
	<200703051953.24900.olaf.kirch@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Olaf Kirch <olaf.kirch@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: message from Olaf Kirch on Monday March 5
Sender: netdev-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Monday March 5, olaf.kirch@oracle.com wrote:
> On Friday 02 March 2007 05:28, NeilBrown wrote:
> > The sunrpc server code needs to know the source and destination address
> > for UDP packets so it can reply properly.
> > It currently copies code out of the network stack to pick the pieces out
> > of the skb.
> > This is ugly and causes compile problems with the IPv6 stuff.
> 
> ... and this IPv6 code could never have worked anyway:

:-(
It's hard to test the IPv6 server until we have an IPv6 client I
guess, so thanks for the code review, even though we aren't going to
end up using that code...

> 
> But I find using recvmsg just for getting at the addresses
> a little awkward too.

Do you?  It's surely a lot better than code duplication, and it is
exactly how you would get the information from user-space.

>                       And I think to be on the safe side, you
> should check that you're really looking at a PKTINFO cmsg
> rather than something else.

Maybe.....
But is there really a chance that it might not be PKTINFO?
And what do you do if it isn't?
Log an error and drop the packet I guess.

I'll see what I can do.

NeilBrown
