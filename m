From: Dax Kelson <dax@gurulabs.com>
Subject: Re: Will NFSv4 be accepted?
Date: Thu, 15 Aug 2002 12:20:54 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16232.1389107548$1029435932@news.gmane.org>
References: <Pine.LNX.4.44.0208151027510.3130-100000@home.transmeta.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
    "Kendrick M. Smith" <kmsmith@umich.edu>,
    "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
    "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>,
    "beepy@netapp.com" <beepy@netapp.com>,
    "trond.myklebust@fys.uio.no" <trond.myklebust@fys.uio.no>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.gurulabs.com ([208.177.141.7] ident=you)
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17fPEu-0004Xe-00
	for <nfs@lists.sourceforge.net>; Thu, 15 Aug 2002 11:20:56 -0700
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

On Thu, 15 Aug 2002, Linus Torvalds wrote:

> 
> For a good enough excuse, and with a good enough argument that it's not 
> likely to be a big export problem, I don't think it's impossible any more.
[snip]
> Quite frankly, I personally suspect that crypto is one of those things 
> that will be added by vendor kernels first - if vendors are willing to 
> handle whatever export issues there are, that's good, and if they aren't, 
> then the standard kernel cannot really force it upon them anyway.

FWIW, Red Hat ships the CIPE kernel module (VPN), so the US export issues
have already been looked at by them.

The US regulations can be found at:

http://w3.access.gpo.gov/bis/ear/ear_data.html

The Export Control Classification Number (ECCN) for the kernel IMHO would
be "NLR" (No License Required) because of the license exception for source
code found in §740.1(e)(2).

Dax



-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
