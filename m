From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [NFS][PATCH] Making sure negative lookup entries don't
 exist
Date: Sat, 29 Jan 2005 07:59:51 -0500
Message-ID: <41FB88C7.3060903@RedHat.com>
References: <41FA88D5.6010904@RedHat.com> <1106967908.10024.19.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CusB3-00032m-A0
	for nfs@lists.sourceforge.net; Sat, 29 Jan 2005 04:58:13 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CusB1-0006ua-BR
	for nfs@lists.sourceforge.net; Sat, 29 Jan 2005 04:58:12 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1106967908.10024.19.camel@lade.trondhjem.org>
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

Trond Myklebust wrote:

>If you are going to do a GETATTR on each call, why cache negative
>dentries in the first place? Better then to simply remove the relevant
>lines in nfs_lookup() and replace all occurrences of d_delete() with
>d_drop().
>  
>
Well I believe that would cause an otw lookup which is much more expensive
than a cheap getattr to ensure the correct mtime of the directory....

>Note, though, that both patches will seriously kill performance on
>static, frequently-accessed directories (think $PATH, /usr/share etc.),
>  
>
Well in my testing, which consisted of running the cthon04 tests a 
number of
times and counting the opts with nfsstat, the getattrs only went up by 
3% and the
lookups when down by about 2%.... which was a bit surprising....

>so we're certainly not applying that kind of patch to the mainline
>kernel...
>  
>
hmm... I hate when you say things like that... :-)  I just trying to 
come up with
a way to more aggressively time out negative cached entires w/out  
effecting
the entire attribute cache in hopes to make things like ClearCase run 
better....
Through some reverse engineering, it appears this is how other 
implementations
seem to deal with negative cache entries....

steved.



-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
