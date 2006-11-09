From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: PROBLEM: can't mkdir() in 2.6.19-rc3
Date: Wed, 8 Nov 2006 21:52:40 -0500
Message-ID: <20061109025240.GA1734@fieldses.org>
References: <20061101021647.GA4203@schwan.zoo>
	<20061108234515.GD16390@fieldses.org>
	<20061109013521.GA1330@schwan.zoo>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gi024-000186-Jb
	for nfs@lists.sourceforge.net; Wed, 08 Nov 2006 18:52:48 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gi024-0002w8-JH
	for nfs@lists.sourceforge.net; Wed, 08 Nov 2006 18:52:49 -0800
To: Ingo Saitz <Ingo.Saitz@stud.uni-hannover.de>
In-Reply-To: <20061109013521.GA1330@schwan.zoo>
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

On Thu, Nov 09, 2006 at 02:35:22AM +0100, Ingo Saitz wrote:
> On Wed, Nov 08, 2006 at 06:45:15PM -0500, J. Bruce Fields wrote:
> > Do you have the "async" option set on this export?  (What does
> > 
> > 	exportfs -v
> > 
> > say?)
> 
> Yes, i do use async as optin. exportfs -v says:
> 
> /DATA/media 10.4.0.225(rw,async,wdelay,root_squash,anonuid=65534,anongid=65534)
> 
> Also, your patch in <20061109004909.GA30367@fieldses.org> fixes this
> problem. Thanks.

Thanks for the confirmation.--b.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
