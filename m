From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFS FAQ updates
Date: Sun, 13 Mar 2005 17:19:38 -0500
Message-ID: <20050313221938.GA13667@fieldses.org>
References: <482A3FA0050D21419C269D13989C61130853986D@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DAbQZ-0007EK-4x
	for nfs@lists.sourceforge.net; Sun, 13 Mar 2005 14:19:15 -0800
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DAbQX-0006sN-I2
	for nfs@lists.sourceforge.net; Sun, 13 Mar 2005 14:19:15 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C61130853986D@lavender-fe.eng.netapp.com>
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

On Sun, Mar 13, 2005 at 01:41:36PM -0800, Lever, Charles wrote:
> hmmm.  so what's the difference between not having access to a file, and
> having access but not being able to read the file?

I was trying to differentiate between the ability to perform IO to the
file and the ability to just get a filehandle for it, but didn't come up
with a good way to say that....

> is it just the ability to know the file is there?  wouldn't that be
> prevented by not having access to its parent?

Lack of access to the parent doesn't prevent guessing the filehandle of
the children.

> or, since the file handle is still good, lack of permission to look
> the file up in the new parent would be inconsequential?

Right.

Kerberos allows us to trust that the permissions on files will be
enforced, because (under certain assumptions) the server enforcing the
permissions knows who is trying to access files.

But it doesn't do anything in particular to enforce exports.

> to my mind, this is a very fine hair to split.  why, in your opinion, is
> it worth mentioning?  ie do you have a particular case in mind where
> this kind of thing could be important?

Hm.  Someone on a single-user system that just wanted to export their
homework project might assume that they could safely export
/home/joeuser/compsci101/ without needing to tighten down permissions on
the rest of the filesystem, not realizing that this gives anyone in
their Kerberos realm the ability to read any file in their filesystem
that's world-readable.

Thinking about it a little more, I think I'd just leave out discussion
of kerberos from this section.  It really solves a different problem,
and we should still be encouraging people to export only whole
partitions.

--b.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
