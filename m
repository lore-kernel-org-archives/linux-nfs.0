From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: [PATCH 2/2] idmapd: fix use after free in dirscancb
	cleanup loop
Date: Thu, 26 Oct 2006 15:51:18 -0400
Message-ID: <4d569c330610261251x62c615d2j9a5d8a76553df222@mail.gmail.com>
References: <1161888339.2667.44.camel@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GdBG6-0004AL-Mb
	for nfs@lists.sourceforge.net; Thu, 26 Oct 2006 12:51:22 -0700
Received: from wx-out-0506.google.com ([66.249.82.231])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GdBG6-000528-LY
	for nfs@lists.sourceforge.net; Thu, 26 Oct 2006 12:51:23 -0700
Received: by wx-out-0506.google.com with SMTP id r21so737637wxc
	for <nfs@lists.sourceforge.net>; Thu, 26 Oct 2006 12:51:19 -0700 (PDT)
To: "Jeff Layton" <jlayton@redhat.com>
In-Reply-To: <1161888339.2667.44.camel@tleilax.poochiereds.net>
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

Thanks for these.  I will work on getting them into our patch and on
to Neil ASAP.

On 10/26/06, Jeff Layton <jlayton@redhat.com> wrote:
> The previous patch seems to expose a use after free bug in dirscancb. At
> least, I could reliably reproduce a segfault by doing a bunch of mounts
> and then unmounting them all. The code uses the following list macro:

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
