From: Vincent ROQUETA <vincent.roqueta@ext.bull.net>
Subject: Re: NFSv4 & /etc/exportfs
Date: Mon, 26 Jan 2004 17:13:50 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200401261713.50547.vincent.roqueta@ext.bull.net>
References: <200401261544.07589.vincent.roqueta@ext.bull.net> <20040126152747.GA14181@fieldses.org>
Reply-To: vincent.roqueta@ext.bull.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Al9Mh-0005RW-3c
	for nfs@lists.sourceforge.net; Mon, 26 Jan 2004 08:13:31 -0800
Received: from ecbull20.frec.bull.fr ([129.183.4.3])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1Al9MM-0001ZV-4j
	for nfs@lists.sourceforge.net; Mon, 26 Jan 2004 08:13:10 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20040126152747.GA14181@fieldses.org>
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

Le Lundi 26 Janvier 2004 16:27, J. Bruce Fields a =E9crit :
> On Mon, Jan 26, 2004 at 03:44:07PM +0100, Vincent ROQUETA wrote:
> > I tried to mount a directory using the old nfs conf. format (as indicat=
ed
> > in the man) and using the new one, as described here :
> > http://www.citi.umich.edu/projects/nfsv4/june_2002_rel/exports.html
>
> That's very out of date; the format described there was for a much older
> version of the code and will probably never be used.  See
> http://www.citi.umich.edu/projects/nfsv4/linux/ for instructions on
> exporting to nfsv4.  The idea is to use the fsid=3D0 option to mark one
> export as the nfsv4 "pseudofilesystem root" (the filesystem clients will
> get if they mount yourserver:/) and then attach other exports underneath
> it using mount --bind.
>
> --Bruce Fields

Great! It works fine ;)=20
Thx


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
