From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: nfs-utils-1.0.5 is not backwards compatible with 2.4
Date: Mon, 4 Aug 2003 10:52:12 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16173.44604.327927.223153@gargle.gargle.HOWL>
References: <3F294DE3.9020304@RedHat.com>
	<16169.54918.472349.928145@gargle.gargle.HOWL>
	<3F2A6087.3060801@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@cse.unsw.edu.au>,
    nfs@lists.sourceforge.net,
    linux-kernel <linux-kernel@vger.kernel.org>,
    Chip Salzenberg <chip@pobox.com>,
    Andrew Morton <akpm@osdl.org>,
    Rik van Riel <riel@RedHat.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19jTaG-0007oW-00
	for <nfs@lists.sourceforge.net>; Sun, 03 Aug 2003 17:52:20 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <SteveD@redhat.com>) (for <neilb@cse.unsw.edu.au>)
	(for <nfs@lists.sourceforge.net>)
	(for <linux-kernel@vger.kernel.org>) (for <chip@pobox.com>) By note
	With Smtp ; Mon, 4 Aug 2003 10:52:12 +1000
To: Steve Dickson <SteveD@RedHat.com>
In-Reply-To: message from Steve Dickson on Friday August 1
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

On Friday August 1, SteveD@RedHat.com wrote:
> I see your point...  I guess I didn't realize that  the "nohide" option  
> (that the user
> sees) has been using the NFSEXP_CROSSMNT define this whole time....
> 
> And I also agree with you if somebody is directly using the bits instead of
> the "nohide" ascii representation they are on there own since there is no
> real export API per say....
> 
> But just to make the clean up complete, wouldn't the attached patch be
> needed in the 2.4 kernel if  nfs-utils-1.0.5 was going to be used?

It wouldn't hurt, but it certainly isn't needed (as it doesn't
actually change any bit of compiled code).

I will put it on my list to send for 2.4.23-pre

NeilBrown


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
