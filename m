From: James Pearson <james-p@moving-picture.com>
Subject: Re: [bug] FC2/2.6.8.1 does not fallback to NFSv2
Date: Sat, 28 Aug 2004 21:31:10 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4130EB8E.6000609@moving-picture.com>
References: <20040827212244.GA57703@brandon.dvalentine.com> <1093642565.5758.108.camel@lade.trondhjem.org> <1093643490.5758.120.camel@lade.trondhjem.org> <20040827233235.GB57703@brandon.dvalentine.com> <20040827233431.GC57703@brandon.dvalentine.com> <1093671305.6028.46.camel@lade.trondhjem.org> <20040828062959.GA68499@brandon.dvalentine.com> <1093718722.5945.5.camel@lade.trondhjem.org> <20040828195703.GB84014@brandon.dvalentine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C19qt-0003Nw-MT
	for nfs@lists.sourceforge.net; Sat, 28 Aug 2004 13:31:07 -0700
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C19qs-00026c-2O
	for nfs@lists.sourceforge.net; Sat, 28 Aug 2004 13:31:07 -0700
To: "Brandon D. Valentine" <brandon@dvalentine.com>
In-Reply-To: <20040828195703.GB84014@brandon.dvalentine.com>
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

Brandon D. Valentine wrote:
> On Sat, Aug 28, 2004 at 02:45:22PM -0400, Trond Myklebust wrote:
> 
> I applied the patch James Pearson also posted to this thread to the
> SRPM, and it allowed me to mount the filesystem.
> 
>   [root@scylla mount]# ./mount -t nfs reef:/export/reef/httpd/ /mnt/temp/
>   Probed program 100003, vers 3, (udp) with result 9
>   Probed program 100003, vers 2, (udp) with result 0
>   Probed program 100005, vers 1, (tcp) with result 0
>   [root@scylla mount]# grep reef /proc/mounts
>   reef:/export/reef/httpd/ /mnt/temp nfs rw,v2,rsize=8192,wsize=8192,hard,udp,lock,addr=reef 0 0
> 
> Out of curiosity I just grabbed the upstream util-linux-2.12b tarball
> and built it and was also able to mount the filesystem no problem, so
> this bug definitely seems to be a bug in the RedHat SRPM.  Their version
> of nfsmount.c is vastly different from the upstream version.

Yes, its definitely a bug in Redhat's version - a bugzilla comment says 
'Patch added to CVS for the next util-linux package' - as yet, this 
doesn't seem to have been released yet.

It appears that a lot of the changes in their nfsmount.c are based on a 
patch that has been on Trond's site for sometime - 
http://client.linux-nfs.org/util-linux-2.11n.dif.gz (although, not the 
bit that causes it to fail to fall back to NFSv2!)

> 
>   [root@scylla mount]# ./mount -t nfs reef:/export/reef/httpd/ /mnt/temp/
>   [root@scylla mount]# grep reef /proc/mounts 
>   reef:/export/reef/httpd/ /mnt/temp nfs rw,v2,rsize=8192,wsize=8192,hard,udp,lock,addr=reef 0 0
> 
> Thanks for all of your help.  I guess from here on out I've gotta take
> it up with the RPM maintainer.

May be someone on this list from RedHat can help ...

James Pearson



-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
