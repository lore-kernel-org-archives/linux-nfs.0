From: "H. J. Lu" <hjl@lucon.org>
Subject: Re: empty /etc/exports causes nfs rc script to exit
Date: Mon, 3 Feb 2003 10:02:07 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030203100207.A12532@lucon.org>
References: <Pine.LNX.4.44.0302031125590.16330-100000@sherman.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sccrmhc03.attbi.com ([204.127.202.63])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18fkv8-0001EF-00
	for <nfs@lists.sourceforge.net>; Mon, 03 Feb 2003 10:02:14 -0800
To: Mark Goodwin <markgw@sgi.com>
In-Reply-To: <Pine.LNX.4.44.0302031125590.16330-100000@sherman.melbourne.sgi.com>; from markgw@sgi.com on Mon, Feb 03, 2003 at 11:31:21AM +1100
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Mon, Feb 03, 2003 at 11:31:21AM +1100, Mark Goodwin wrote:
> 
> Is there some good reason why the nfs rc script exits if /etc/exports
> is empty?  [ -s /etc/exports ] || exit 0
> 
> If an admin adds something to /etc/exports, they have to kick the
> rc script too. Seems silly.
> 

We did

# echo "#" > /etc/exports

for this purpose.


H.J.


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
