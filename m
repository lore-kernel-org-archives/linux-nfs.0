From: "H. J. Lu" <hjl@lucon.org>
Subject: Re: Re: Slow performance with 2.4.19pre1
Date: Thu, 4 Jul 2002 16:55:43 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020704165543.A28955@lucon.org>
References: <Pine.LNX.4.44.0207041624120.30131-100000@xpc1.ast.cam.ac.uk> <1025814832.2122.14.camel@camp4.serpentine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeremy Sanders <jss@ast.cam.ac.uk>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sccrmhc03.attbi.com ([204.127.202.63])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17QGRz-0007hx-00
	for <nfs@lists.sourceforge.net>; Thu, 04 Jul 2002 16:55:51 -0700
To: Bryan O'Sullivan <bos@serpentine.com>
In-Reply-To: <1025814832.2122.14.camel@camp4.serpentine.com>; from bos@serpentine.com on Thu, Jul 04, 2002 at 01:33:52PM -0700
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

On Thu, Jul 04, 2002 at 01:33:52PM -0700, Bryan O'Sullivan wrote:
> On Thu, 2002-07-04 at 08:25, Jeremy Sanders wrote:
> > Sorry - I know it's bad form to reply to one's own emails. It seems that
> > the stock 2.4.19rc1 kernel doesn't have the problem as a client, and so
> > it's the RedHat patched 2.4.18 kernel which is a very slow client. This
> > looks like a RedHat bug.
>=20
> Yes, you're correct.  The kernels Red Hat has been shipping with 7.3
> have atrocious NFS client behaviour, and will bring some servers (such
> as Netapp boxes) to a halt.
>=20

Have you tried the 7.3 kernel update. It is 2.4.18-5.


H.J.


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Caffeinated soap. No kidding.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
