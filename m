From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: [Storage_sig] Re: Question on bug tracking for NFSv4 work
Date: Fri, 10 Dec 2004 06:51:05 -0800
Message-ID: <482A3FA0050D21419C269D13989C61130435EC86@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>, <storage_sig@osdl.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ccm6z-0004x0-Mp
	for nfs@lists.sourceforge.net; Fri, 10 Dec 2004 06:51:13 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Ccm6x-0001FJ-Ct
	for nfs@lists.sourceforge.net; Fri, 10 Dec 2004 06:51:13 -0800
To: "Bryce Harrington" <bryce@osdl.org>,
        "J. Bruce Fields" <bfields@fieldses.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

> On Thu, 9 Dec 2004, J. Bruce Fields wrote:
>=20
> > On Thu, Dec 09, 2004 at 02:24:27PM -0800, Lever, Charles wrote:
> > > we tried this once already.  i set up a cvstrac bug
> > > database here at=20
> > > CITI.  you and i were the only ones who actually touched=20
> > > the thing, and now it is long since dead.
>=20
> Do you think any of the bugs in that system still valid?  If
> so would it be possible for us to get a copy in some form (db=20
> dump or whatever)?

many of those bugs were against a 2.4 backport of the NFSv4 code, and
are thus not relevant.  of the remaining bugs, only a few are of
interest, and those are widely known issues (for example, the
requirement for keyring support for session-based authentication, or the
requirement for ACL side-band protocol support in upstream kernels).
most or all of that information is documented in the priorities list at
client.linux-nfs.org.

i used the cvstrac database primarily for release planning.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
