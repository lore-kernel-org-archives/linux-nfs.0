From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Will NFSv4 be accepted?
Date: Thu, 15 Aug 2002 00:07:13 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15174.6531170376$1029384852@news.gmane.org>
References: <1029375327.28240.35.camel@irongate.swansea.linux.org.uk> <Pine.LNX.4.44.0208141938350.31203-100000@mooru.gurulabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	"Kendrick M. Smith" <kmsmith@umich.edu>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>,
	beepy@netapp.com, trond.myklebust@fys.uio.no,
	torvalds@transmeta.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from dsl-65-186-160-165.telocity.com ([65.186.160.165] helo=pumpkin.fieldses.org)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17fBwv-0002sm-00
	for <nfs@lists.sourceforge.net>; Wed, 14 Aug 2002 21:09:29 -0700
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

On Wed, Aug 14, 2002 at 07:51:56PM -0600, Dax Kelson wrote:
> Right, I do understand that Kerberized/GSS NFS is not exclusive to NFSv4.  
> However, right now, there is only one way to get Kerberized NFS. The CITI
> NFSv4 patches.
> 
> Those patches are, in their estimation, ready for inclusion.  NFSv3 
> support is "coming down the pipeline". 

The minimal NFSv4 patches which Kendrick has submitted are ready for
inclusion, but those do not include rpcsec_gss support.  The only
patches which include rpcsec_gss support are patches against 2.4.18, and
they aren't in good enough shape yet, though we hope they will be soon!

--Bruce F.


-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
