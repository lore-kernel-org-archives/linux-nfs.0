From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFSv4 & /etc/exportfs
Date: Mon, 26 Jan 2004 10:27:47 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040126152747.GA14181@fieldses.org>
References: <200401261544.07589.vincent.roqueta@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Al8eY-0004or-Jc
	for nfs@lists.sourceforge.net; Mon, 26 Jan 2004 07:27:54 -0800
Received: from dsl093-002-214.det1.dsl.speakeasy.net
	([66.93.2.214] helo=pumpkin.fieldses.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1Al8eY-0003jz-3G
	for nfs@lists.sourceforge.net; Mon, 26 Jan 2004 07:27:54 -0800
To: Vincent ROQUETA <vincent.roqueta@ext.bull.net>
In-Reply-To: <200401261544.07589.vincent.roqueta@ext.bull.net>
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

On Mon, Jan 26, 2004 at 03:44:07PM +0100, Vincent ROQUETA wrote:
> I tried to mount a directory using the old nfs conf. format (as indicated in 
> the man) and using the new one, as described here : 
> http://www.citi.umich.edu/projects/nfsv4/june_2002_rel/exports.html

That's very out of date; the format described there was for a much older
version of the code and will probably never be used.  See
http://www.citi.umich.edu/projects/nfsv4/linux/ for instructions on
exporting to nfsv4.  The idea is to use the fsid=0 option to mark one
export as the nfsv4 "pseudofilesystem root" (the filesystem clients will
get if they mount yourserver:/) and then attach other exports underneath
it using mount --bind.

--Bruce Fields


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
