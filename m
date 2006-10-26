From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Annoying rename() problem
Date: Wed, 25 Oct 2006 22:51:20 -0400
Message-ID: <20061026025120.GA12505@fieldses.org>
References: <003f01c6f54a$90506250$020010ac@athlon64>
	<20061024160932.GB17308@dementia.proulx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GcvL1-0004Pc-PQ
	for nfs@lists.sourceforge.net; Wed, 25 Oct 2006 19:51:25 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GcvL1-00066D-LU
	for nfs@lists.sourceforge.net; Wed, 25 Oct 2006 19:51:24 -0700
To: Antoniu-George SAVU <antoniu-george.savu@linux-expert.eu>,
	nfs@lists.sourceforge.net
In-Reply-To: <20061024160932.GB17308@dementia.proulx.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Tue, Oct 24, 2006 at 10:09:32AM -0600, Bob Proulx wrote:
> Antoniu-George SAVU wrote:
> > Now, when a user has more than 50 files inside the new/ directory and 
> > Courier IMAP rename those files to cur/ directory, I get strange errors 
> > inside the Courier log complaining that the rename() has failed with the 
> > errno=ENOENT (no such file or directory). The most amazing part is that the 
> > files are moved just fine from new/ to cur/ and I just can not understand 
> > why I keep getting those rename() errors and most important, how can I fix 
> > this.
...
> The application replaces an existing file on disk by writing a new
> file off to the side in a temporary file and then after successfully
> close() operation rename()s the file to the final name, replacing the
> file that is already on disk.  The rename() returns a failure.
> Subsequent inspection showed that the new file was renamed okay.

I'd have guessed the client is replaying the rename request and only
seeing the reply to the second attempt (even though the first also
succeeded).

Are you using tcp?  (And if not, does switching help?)  Does adjusting
the timeout times (see timeo, retrans in "man nfs") help?

--b.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
