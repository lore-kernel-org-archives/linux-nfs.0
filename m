From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] fix comment parsing
Date: Fri, 23 Jun 2006 10:16:25 -0400
Message-ID: <20060623141625.GD21357@fieldses.org>
References: <20060622235156.GA8263@fieldses.org>
	<17563.26951.908793.369125@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, kwc@citi.umich.edu
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FtmSV-0008L1-5Q
	for nfs@lists.sourceforge.net; Fri, 23 Jun 2006 07:16:31 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FtmSU-0004fu-4C
	for nfs@lists.sourceforge.net; Fri, 23 Jun 2006 07:16:31 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17563.26951.908793.369125@cse.unsw.edu.au>
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

On Fri, Jun 23, 2006 at 02:08:39PM +1000, Neil Brown wrote:
> However I don't think that patch is quite right.
> It will make a comment through to the EOL parse as nothing at all,
> not even an EOL, so
> 
> /foo bar() #comment
> /baz *()
> 
> will parse like
> 
> /for bar() /baz *()
> 
> which isn't what we want.

Whoops.

> On reflect, I got it completely wrong.  Having reviewed how parsing
> really works, I think this is the right patch.

Thanks!  That works for me.--b.

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
