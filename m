From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS latency
Date: Tue, 08 Aug 2006 10:25:53 -0400
Message-ID: <1155047153.5673.35.camel@localhost>
References: <20060808140947.23526.qmail@web82504.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GASX0-0001gi-GW
	for nfs@lists.sourceforge.net; Tue, 08 Aug 2006 07:26:06 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GASX0-0002gb-Gt
	for nfs@lists.sourceforge.net; Tue, 08 Aug 2006 07:26:07 -0700
To: Ryan Lolli <rjlolli@sbcglobal.net>
In-Reply-To: <20060808140947.23526.qmail@web82504.mail.mud.yahoo.com>
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

On Tue, 2006-08-08 at 07:09 -0700, Ryan Lolli wrote:
>             I'm currently running on the following version of linux.
>  
>             
> 
> Red Hat Enterprise Linux AS release 3 (Taroon Update 7)
> 
> (Linux release 2.4.21-40.EL #1
> 
>  
> 
>        I have a directory NFS mounted onto my linux box and I'm
> fighting latency issues.  My application needs to read from the
> directory as close to real-time as possible, but I've seen delays as
> much as 30 seconds.  Does anyone know of a work-around or setting to
> resolve this latency issue?  Thanks.

You don't really tell us how your application is checking the directory.
Is it polling using opendir()/readdir()/closedir(), is it using stat(),
or is it something else altogether?

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
