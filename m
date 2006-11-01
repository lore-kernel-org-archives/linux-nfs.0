From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Some uncomformity between the realization of the
	RHEL5Beta1 and the RFC1813
Date: Tue, 31 Oct 2006 21:50:52 -0500
Message-ID: <20061101025052.GA32052@fieldses.org>
References: <008001c6fd5f$2c350330$8904a8c0@xurui>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gf6Br-0003u6-4r
	for nfs@lists.sourceforge.net; Tue, 31 Oct 2006 18:50:55 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gf6Br-0001Mo-4I
	for nfs@lists.sourceforge.net; Tue, 31 Oct 2006 18:50:56 -0800
To: xurui <xur@nanjing-fnst.com>
In-Reply-To: <008001c6fd5f$2c350330$8904a8c0@xurui>
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

On Wed, Nov 01, 2006 at 10:41:03AM +0800, xurui wrote:
>  struct COMMIT3args { nfs_fh3    file; offset3    offset; count3
>  count; };
...
>  
> 
> When we send the package with the sum of the augment count and offset
> larger than the file size ,which will lead to the overflow ,we assumed
> that nfs server will return fail message,

Why do you assume that?

That doesn't sound like the right behavior to me.  What if the file has
been truncated on the server without the client's knowledge?  Isn't it
better in that case to flush out whatever range remains instead of
failing the commit?

--b.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
