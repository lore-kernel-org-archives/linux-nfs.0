From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: nfs-utils 1.0.5 break amd?
Date: Tue, 5 Aug 2003 12:13:46 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16175.4826.984307.413302@gargle.gargle.HOWL>
References: <1059672742.21271.58.camel@ikarus>
	<16169.55986.854984.818132@gargle.gargle.HOWL>
	<1060033126.1354.118.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19jrKo-0005MY-00
	for <nfs@lists.sourceforge.net>; Mon, 04 Aug 2003 19:13:58 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <mschmitt@inf.ethz.ch>) (for <nfs@lists.sourceforge.net>) By
	note With Smtp ; Tue, 5 Aug 2003 12:13:51 +1000
To: Marc Schmitt <mschmitt@inf.ethz.ch>
In-Reply-To: message from Marc Schmitt on  August 4
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

On  August 4, mschmitt@inf.ethz.ch wrote:
> 
> Now comes the interesting part, changing MOUNTD_TCP in
> /etc/sysconfig/nfs from no to yes will make the problem go away. With
> MOUNTD_TCP=yes I went up to 1000 exports and `showmount -e` worked fine.

Yes,  that makes sense.  UDP has a limited request/reply size.  TCP
doesn't.

I honestly cannot think of any good reason to have MOUNTD_TCP=no  
Maybe I should update the man page
  
       -n  or  --no-tcp
              Don't advertise TCP for mount.

              NOTE: there is no good reason do use this option, and
	      if you do, then things will mysteriously break.

:-)
NeilBrown


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
