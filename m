From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Possible jiffy wrap-around problem in NFS client.
Date: Fri, 02 Feb 2007 09:53:55 -0800
Message-ID: <1170438835.5890.4.camel@lade.trondhjem.org>
References: <17858.40219.500690.988191@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HD2c6-0005lX-NP
	for nfs@lists.sourceforge.net; Fri, 02 Feb 2007 09:54:18 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1+5E1q2QdMyTrBAtmw66PaCK6if/wsqpeY=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HD2c6-0008Lb-7z
	for nfs@lists.sourceforge.net; Fri, 02 Feb 2007 09:54:20 -0800
In-Reply-To: <17858.40219.500690.988191@notabene.brown>
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

On Fri, 2007-02-02 at 13:08 +1100, Neil Brown wrote:
> Hi Trond (and anyone else who might know...)
> 
>  I'm chasing an apparent NFS client problem, and I'm wondering if it
>  could be a jiffy-wrap around problem.
> 
>  In particular, ->cache_change_attribute.
> 
>  This seems to be set to 'jiffies' only when the inode is first
>  allocated, or when we have changed the file, or when a GETATTR or wcc
>  shows that the file has changed.
>  So if a file is unchanged on the server, cache_change_attribute will
>  not change after it is first assigned.
> 
>  If the file remains in cache for 24 days (2^31 jiffies at 1000Hz),
> 	data_stable = nfs_verify_change_attribute(inode, fattr->time_start);
> 	if (data_stable)
> 		nfsi->cache_validity &= ~(NFS_INO_INVALID_ATTR|NFS_INO_REVAL_PAGECACHE|NFS_INO_INVALID_ATIME);
>  in nfs_update_inode will start clearing those flags (as
>  cache_change_attribute will always be in the future) and so will
>  trigger more GETATTR requests.
> 
>  Could this be correct?

...but if the file isn't changing on the server, why would any of the
above flags be set in the first place? Is this a situation in which the
client is writing to the file?

Cheers,
  Trond


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
