From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: LINUX NFS server Solaris NFS client issue
Date: Wed, 08 Sep 2004 14:08:36 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1094616516.20243.173.camel@hole.melbourne.sgi.com>
References: <0CF6F73B3B779D43B160B85FD0CC2D37026551D7@xch-sw-07.sw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C4tda-000125-SV
	for nfs@lists.sourceforge.net; Tue, 07 Sep 2004 21:00:50 -0700
Received: from omx3-ext.sgi.com ([192.48.171.20] helo=omx3.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C4tdZ-0002b0-2B
	for nfs@lists.sourceforge.net; Tue, 07 Sep 2004 21:00:49 -0700
To: "Hyatt, Daniel J" <daniel.j.hyatt@boeing.com>
In-Reply-To: <0CF6F73B3B779D43B160B85FD0CC2D37026551D7@xch-sw-07.sw.nos.boeing.com>
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

On Wed, 2004-09-08 at 04:43, Hyatt, Daniel J wrote:
> I am hoping for some recommendations for success. I was just told that
> Linux NFS server is experimental.

No.  Support for *TCP* with the Linux NFS server was marked EXPERIMENTAL
until recently, but despite that has been stable for some time.


> Vfstab is:
> lap:/projects/os -    /proj/os                ufs     -       yes     rw
> 
> lap:/appl      -      /appll                  ufs     -       yes     rw
                                                ^^^

I'm no Solaris expert but you might try specifying "nfs" here.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.




-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
