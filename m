From: Neil Conway <nconway_kernel@yahoo.co.uk>
Subject: Re: NFS client bug in 2.6.8-2.6.11
Date: Tue, 15 Mar 2005 23:44:15 +0000 (GMT)
Message-ID: <20050315234415.71730.qmail@web26510.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	lkml <linux-kernel@vger.kernel.org>, nfs@lists.sourceforge.net
To: Bernardo Innocenti <bernie@develer.com>,
	Anders Saaby <as@cohaesio.com>
In-Reply-To: 6667
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Hi Bernardo (et al).  Apologies - I've not been reading my account for
a wee while.  Then again, I probably don't have much useful to add to
the debate right now ;-)

--- Bernardo Innocenti <bernie@develer.com> wrote:
> Anders Saaby wrote:
> > Anyways if your server has only run with 2.6.10 - try 2.6.11.
> 
> Thank you, I've finally nailed it down by upgrading the
> *server* kernel from 2.6.10-1.770_FC3 to 2.6.10-1.770_FC3.

Hmm, I will infer from a previous email you sent that you mean 766_FC3
for the "from" kernel.

> The latter is basically 2.6.10-ac12 plus a bunch of vendor
> specific patches.

766 -> 770 sounds like a "small" (ish) number of patches to check, if
we're lucky.  Did you wade through 'em all yet?  Any smoking guns?

Regards,
Neil
PS: oh bugger, just remembered that I also reproduced my bug with a
2.6.8 kernel on the server; admittedly though it was an FC2 kernel so
who knows what extra patches it had.



		
__________________________________ 
Do you Yahoo!? 
Make Yahoo! your home page 
http://www.yahoo.com/r/hs
