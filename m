From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Will NFSv4 be accepted?
Date: Thu, 15 Aug 2002 10:35:40 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6390.27795191414$1029467611@news.gmane.org>
References: <Pine.LNX.4.44.0208141938350.31203-100000@mooru.gurulabs.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
        "Kendrick M. Smith" <kmsmith@umich.edu>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>,
        <beepy@netapp.com>, <trond.myklebust@fys.uio.no>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from neon-gw-l3.transmeta.com ([63.209.4.196] helo=neon-gw.transmeta.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17fOV0-000476-00
	for <nfs@lists.sourceforge.net>; Thu, 15 Aug 2002 10:33:30 -0700
To: Dax Kelson <dax@gurulabs.com>
In-Reply-To: <Pine.LNX.4.44.0208141938350.31203-100000@mooru.gurulabs.com>
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


On Wed, 14 Aug 2002, Dax Kelson wrote:
> 
> Q for Linus: What's the prospect of adding crypto to the kernel?

For a good enough excuse, and with a good enough argument that it's not 
likely to be a big export problem, I don't think it's impossible any more.

However, the "good enough excuse" has to be better than "some technically 
excellent, but not very widespread" thing. 

Quite frankly, I personally suspect that crypto is one of those things 
that will be added by vendor kernels first - if vendors are willing to 
handle whatever export issues there are, that's good, and if they aren't, 
then the standard kernel cannot really force it upon them anyway.

I personally doubt that NFS would be the thing driving this. Judging by 
past performance, NFS security issues don't seem to bother people. I'd 
personally assume that the thing that would be important enough to people 
for vendors to add it is VPN or encrypted (local) disks.

		Linus



-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
