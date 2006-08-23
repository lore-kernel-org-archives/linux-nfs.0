From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Random ESTALE due to lookup "/" in mount point?
Date: Wed, 23 Aug 2006 12:20:25 -0400
Message-ID: <1156350025.5619.14.camel@localhost>
References: <20060823150941.GA13000@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GFvTA-0003WE-BU
	for nfs@lists.sourceforge.net; Wed, 23 Aug 2006 09:20:44 -0700
Received: from pat.uio.no ([129.240.10.4])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GFvT8-0007yu-Jo
	for nfs@lists.sourceforge.net; Wed, 23 Aug 2006 09:20:45 -0700
To: Frank van Maarseveen <frankvm@frankvm.com>
In-Reply-To: <20060823150941.GA13000@janus>
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

On Wed, 2006-08-23 at 17:09 +0200, Frank van Maarseveen wrote:
> NFSv3, udp, client=2.6.17.8, server=tru64
> 
> On the client I started to get some random ESTALE errors which disappeared
> quickly afterwards without a remount. The errors only occurred when typing
> 
> 	stat ..
> 
> in a subdirectory of a mountpoint. Doing ls -al in that subdirectory
> gave an ESTALE only on "..". I could even change directory to / and back
> without an ESTALE but the "stat .." command still gave an ESTALE.
> 
> A "tcpdump -i eth0 udp port 2049 -n -s 1500" showed something which is
> unusual to my knowledge. The kernel tried to lookup "/" in the mount
> point as it seems:

I've never seen that, and my own kernel certainly appears to do no such
thing when I stat '..'.

Any chance of a 'strace' with that?

Cheers,
  Trond


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
