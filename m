From: Neil Horman <nhorman@redhat.com>
Subject: Re: Rename window
Date: Fri, 11 Nov 2005 08:30:36 -0500
Message-ID: <20051111133036.GA3847@hmsendeavour.rdu.redhat.com>
References: <9E621559095AA746B22B21CD4FAF99A557356D@EDINMAIL1.ad.datcon.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EaYzW-00034P-AH
	for nfs@lists.sourceforge.net; Fri, 11 Nov 2005 05:30:54 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EaYzU-0001nl-SU
	for nfs@lists.sourceforge.net; Fri, 11 Nov 2005 05:30:54 -0800
To: Edward Hibbert <Edward.Hibbert@dataconnection.com>
In-Reply-To: <9E621559095AA746B22B21CD4FAF99A557356D@EDINMAIL1.ad.datcon.co.uk>
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

On Fri, Nov 11, 2005 at 11:42:01AM -0000, Edward Hibbert wrote:
> I have noticed a atomicity problem with the handling of rename by the
> Linux NFS client, and just wanted to check if this is something that we
> just have to work-around, or is there some other solution.
>  
> The problem arises when two different machines issue a file rename which
> is identical.
>  
> E.g. rename oldname newname
>  
> You would expect that one machine would be successful, and the other
> would fail.    However, the NFS client seems to be issuing 3 NFS
> operations to perform the rename
> 
> *	LOOKUP oldname 
> *	LOOKUP newname 
> *	RENAME oldname newname
> 
> There is a timing window where both LOOKUPs can succeed (if the other
> machine does the rename at the right time).   In this case, the Linux
> NFS client does not issue the final NFS RENAME operation - BUT still
> returns success to the caller.
>  
> Thus both machines have succeeded in renaming the file.
>  
> You might argue that since they are performing the same operation that
> it is OK for both to succeed, but I have an application that depends on
> the atomicity of the operation, as it uses the filename to hold a
> counter, and rename to assign a unique counter to a process.
>  
> Any help appreciated. 
> 

I don't believe rename ever guaranteed atomicity of its operation.  If you want
to guarantee atomicity I expect you will want to implement a locking strategy
around the directories/files you are modifying in the rename operation using fcntl
locking.
Regards
Neil

> Edward. 
>  
>  

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
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. Download
it for free - -and be entered to win a 42" plasma tv or your very own
Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
