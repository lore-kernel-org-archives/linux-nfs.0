From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: nfs-utils-1.0.9 compilation failed!
Date: Mon, 10 Jul 2006 19:04:46 -0400
Message-ID: <4d569c330607101604u62a240edo6116c589ac4dc780@mail.gmail.com>
References: <OF7F9FF7E6.DBB070D5-ON882571A7.00785158-882571A7.0079CB32@us.ibm.com>
	<OF1D753314.D06EB0BF-ON882571A7.007A2454-882571A7.007B6268@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G04o4-0003YI-Rr
	for nfs@lists.sourceforge.net; Mon, 10 Jul 2006 16:04:52 -0700
Received: from nf-out-0910.google.com ([64.233.182.188])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G04o4-0004PC-R7
	for nfs@lists.sourceforge.net; Mon, 10 Jul 2006 16:04:49 -0700
Received: by nf-out-0910.google.com with SMTP id h2so173818nfe
	for <nfs@lists.sourceforge.net>; Mon, 10 Jul 2006 16:04:46 -0700 (PDT)
To: "Usha Ketineni" <uketinen@us.ibm.com>
In-Reply-To: <OF1D753314.D06EB0BF-ON882571A7.007A2454-882571A7.007B6268@us.ibm.com>
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

write_oid() should be defined in utils/gssd/write_bytes.h as an inline function.

On 7/10/06, Usha Ketineni <uketinen@us.ibm.com> wrote:
>
>
> nfs-bounces@lists.sourceforge.net wrote on 07/10/2006
> 03:10:17 PM:
>
>
>  >
>  > Hi,
>  >
>  > Compilation of nfs-utils-1.0.9 failed with the below error on my machine.
>  > I don't see the function "write_oid()" being defined in the source code.
>  > Anyone hit this error or am I missing something?
>  >
>
>
> write_oid() has been defined in nfs-utils-1.0.8 version and used in couple
> of function calls in utils/gssd/context_mit.c. I believe some changes might
> have
> happened in the release 1.0.9.
>
>
>
>
> -------------------------------------------------------------------------
> Using Tomcat but need to do more? Need to support web services, security?
> Get stuff done quickly with pre-integrated technology to make your job
> easier
> Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
> http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
>
>
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>
>
>


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
