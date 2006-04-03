From: Neil Brown <neilb@suse.de>
Subject: Re: [NFS] [PATCH] knfsd: Correct reserved reply space for read requests.
Date: Mon, 3 Apr 2006 11:17:17 +1000
Message-ID: <17456.30621.579579.483287@cse.unsw.edu.au>
References: <1060330055350.25337@suse.de>
	<OF66A2887E.D01D36C5-ON88257141.0061C8EF-88257141.00626357@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964802AbWDCBTL@vger.kernel.org>
To: Marc Eshel <eshel@almaden.ibm.com>
In-Reply-To: message from Marc Eshel on Thursday March 30
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Thursday March 30, eshel@almaden.ibm.com wrote:
> Hi Neil
> Can we use this opportunity to change NFSSVC_MAXBLKSIZE from 32K to 64K to 
> match RPCSVC_MAXPAYLOAD. It makes real difference in I/O performance (we 
> will still be saving half the space we used to allocate :).
> Thanks, Marc. 

Maybe... but why not 128K ??

There is certainly room to increase NFSSVC_MAXBLKSIZE, but I feel that
it needs to be done together with a more detailed look at consequences
in the network layer, particularly TCP window sizes.  I wouldn't mind
making a CONFIG_ tunable without that detailed look, but making it a
fixed change I feel less comfortable about.

NeilBrown
