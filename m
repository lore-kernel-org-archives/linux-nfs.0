From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: RedHat Rawhide Kernels
Date: Thu, 8 Aug 2002 15:33:31 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020808153331.F28223@redhat.com>
References: <Pine.LNX.4.44.0208082017590.23326-100000@xpc1.ast.cam.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from to-velocet.redhat.com ([216.138.202.10] helo=touchme.toronto.redhat.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17ct2N-000737-00
	for <nfs@lists.sourceforge.net>; Thu, 08 Aug 2002 12:33:35 -0700
To: Jeremy Sanders <jss@ast.cam.ac.uk>
In-Reply-To: <Pine.LNX.4.44.0208082017590.23326-100000@xpc1.ast.cam.ac.uk>; from jss@ast.cam.ac.uk on Thu, Aug 08, 2002 at 08:21:27PM +0100
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

On Thu, Aug 08, 2002 at 08:21:27PM +0100, Jeremy Sanders wrote:
> Just to let you guys know (as it's close to the current thread), I'm
> getting very bad lock-ups using the current rawhide kernel (2.4.18-7.94).
> When I connet with a machine running 2.4.18-5 (standard 7.3 errata
> kernel), both the client and the server get processes stuck in a "D" state
> - the nfsd processes on the server and the user command on the client.
> This means you can't shut the server down as the nfsd processes can't get
> killed. Strangely 2.4.19 kernels can talk to the server fine!

For the sake of spreading the knowledge around, I've also got a couple 
of reports of -5 (which has an earlier set of Trond's client patches) 
and vanilla 2.4.18 getting D state stuck processes in lock_page on NFS 
mounts.  There's no useful data point beyond that, but it looks like a 
request is getting lost somewhere.

		-ben
-- 
"You will be reincarnated as a toad; and you will be much happier."


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
