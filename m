From: Jeremy Sanders <jss@ast.cam.ac.uk>
Subject: Re: Re: Slow performance with 2.4.19pre1
Date: Fri, 5 Jul 2002 10:09:50 +0100 (BST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0207051009120.715-100000@xpc1.ast.cam.ac.uk>
References: <20020704165543.A28955@lucon.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Bryan O'Sullivan" <bos@serpentine.com>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from purple.csi.cam.ac.uk ([131.111.8.4])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17QP6F-0003er-00
	for <nfs@lists.sourceforge.net>; Fri, 05 Jul 2002 02:10:00 -0700
To: "H. J. Lu" <hjl@lucon.org>
In-Reply-To: <20020704165543.A28955@lucon.org>
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

On Thu, 4 Jul 2002, H. J. Lu wrote:

> On Thu, Jul 04, 2002 at 01:33:52PM -0700, Bryan O'Sullivan wrote:
> > On Thu, 2002-07-04 at 08:25, Jeremy Sanders wrote:
> > > Sorry - I know it's bad form to reply to one's own emails. It seems that
> > > the stock 2.4.19rc1 kernel doesn't have the problem as a client, and so
> > > it's the RedHat patched 2.4.18 kernel which is a very slow client. This
> > > looks like a RedHat bug.
> >
> > Yes, you're correct.  The kernels Red Hat has been shipping with 7.3
> > have atrocious NFS client behaviour, and will bring some servers (such
> > as Netapp boxes) to a halt.
> >
>
> Have you tried the 7.3 kernel update. It is 2.4.18-5.

The tests were with 2.4.18-5 on an athlon.

Jeremy

-- 
Jeremy Sanders <jss@ast.cam.ac.uk>   http://www-xray.ast.cam.ac.uk/~jss/
X-Ray Group, Institute of Astronomy, University of Cambridge, UK.
Public Key Server PGP Key ID: E1AAE053



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Bringing you mounds of caffeinated joy.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
