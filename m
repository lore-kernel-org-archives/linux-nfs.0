From: Roger Luethi <rl@hellgate.ch>
Subject: Re: Will NFSv4 be accepted?
Date: Thu, 15 Aug 2002 21:52:31 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020815195231.GA18239@k3.hellgate.ch>
References: <Pine.LNX.4.44.0208141938350.31203-100000@mooru.gurulabs.com> <Pine.LNX.4.44.0208151027510.3130-100000@home.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dax Kelson <dax@gurulabs.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	"Kendrick M. Smith" <kmsmith@umich.edu>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>,
	beepy@netapp.com, trond.myklebust@fys.uio.no
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mta11n.bluewin.ch ([195.186.1.211])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17fQfl-0002Ze-00
	for <nfs@lists.sourceforge.net>; Thu, 15 Aug 2002 12:52:45 -0700
To: Linus Torvalds <torvalds@transmeta.com>
In-Reply-To: <Pine.LNX.4.44.0208151027510.3130-100000@home.transmeta.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

On Thu, 15 Aug 2002 10:35:40 -0700, Linus Torvalds wrote:
> 
> On Wed, 14 Aug 2002, Dax Kelson wrote:
> > 
> > Q for Linus: What's the prospect of adding crypto to the kernel?
> 
> For a good enough excuse, and with a good enough argument that it's not 
> likely to be a big export problem, I don't think it's impossible any more.
> 
> However, the "good enough excuse" has to be better than "some technically 
> excellent, but not very widespread" thing. 

While I'm all for adding crypto to the standard kernel, I contend the
crucial part is not strong crypto, but the API. With a stock kernel that
merely offered rot13 type algorithms and a simple way to add more, we could
sidestep the export issue [1] if necessary and still get important
benefits.

There have been some efforts to find a common platform (e.g. between the
freeswan and the cryptoapi folks recently), but the driving force that
brought us LSM is sorely missing with crypto, although the issue seems less
complex.

I won't comment on the technical excellence of the currently available
solutions, but VPNs and disk encryption (especially for laptop owners) are
quite likely to see (even more) widespread use in the near future. With
Reiser4 it seems there is soon going to be another contender in local
filesystems besides the loopback based ones. RedHat, Mandrake, and SuSE are
already selling products using kernel space encryption (i.e. VPNs and/or
encrypted filesystems).

IMHO the case for crypto in the kernel has already been made. The questions
are rather: what would a kernel crypto facility look like if it was to be
useful for all those projects out there, and who could pull an LSM on this
one?

Roger

[1] Assuming that the times when even crypto _hooks_ were likely a felony
    are gone for good (for many countries anyway). IANAL, obviously.


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
