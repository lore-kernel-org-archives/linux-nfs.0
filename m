From: Neil Horman <nhorman@redhat.com>
Subject: Re: possible client stale filehandle bug?
Date: Wed, 16 Feb 2005 16:47:35 -0500
Message-ID: <4213BF77.9080004@redhat.com>
References: <482A3FA0050D21419C269D13989C61130853976F@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Garrick Staples <garrick@usc.edu>, nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D1X1L-0004xz-Ha
	for nfs@lists.sourceforge.net; Wed, 16 Feb 2005 13:47:43 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D1X1K-0007pf-0M
	for nfs@lists.sourceforge.net; Wed, 16 Feb 2005 13:47:43 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C61130853976F@lavender-fe.eng.netapp.com>
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

Lever, Charles wrote:
>>I agree, it probably doesn't re-drive on any operation that 
>>doesn't walk 
>>a path, which is in line with what RHEL is doing currently.  I didn't 
>>mean to imply that solaris retired ESTALE in all occurances of the 
>>event.  Anywho, Can you point me to your patches?  I'd be 
>>interested to 
>>know how you managed to implement retry on ESTALE without 
>>leaking into 
>>the VFS, which I think you will recall was the big sticking 
>>point that 
>>we were debating here.
> 
> 
> the patches do touch fs/namei.c (it was al viro's suggestion) with a
> pretty simple change.  and i think they are KABI friendly enough to be
> included in RHEL 3, once we are satisfied that the solution is
> effective.
> 
> the cto-lookup-revalidate patch adds just enough of the 2.6
> lookup-intent logic to the 2.4 VFS layer to allow us to support NFS
> close-to-open in nfs_lookup_revalidate instead of in nfs_open.  this
> resolves one of the most common ESTALE failure modes, where just the
> object at the end of the pathname has been replaced.
> 
> the second patch applies on top of this.  it adds logic to redrive
> pathname resolution if an ESTALE is encountered anywhere during a
> pathname lookup.  it redrives it once from the top, asserting a flag
> that causes the VFS layer to abandon the dcache and use only real
> lookups for this resolution request.  if the redriven resolution fails,
> we give up.  this resolves the other typical ESTALE failure mode, where
> some or all of the path has been replaced, while avoiding retrying an
> unbounded number of times.
Fantastic, Thanks!
Neil

-- 
/***************************************************
  *Neil Horman
  *Software Engineer
  *Red Hat, Inc.
  *nhorman@redhat.com
  *gpg keyid: 1024D / 0x92A74FA1
  *http://pgp.mit.edu
  ***************************************************/


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
