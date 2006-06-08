From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: Re: query about kernel 2.4.21-37.ELsmp
Date: Thu, 8 Jun 2006 01:50:04 -0700 (PDT)
Message-ID: <20060608085004.73262.qmail@web51611.mail.yahoo.com>
References: <1149748767.3379.66.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list2-b.sourceforge.net ([10.3.1.8]
	helo=sc8-sf-list2.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FoHzv-0006Ew-1f
	for nfs@lists.sourceforge.net; Thu, 08 Jun 2006 03:44:19 -0700
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FoHvK-0001Oi-C9
	for nfs@lists.sourceforge.net; Thu, 08 Jun 2006 03:39:34 -0700
Received: from web51611.mail.yahoo.com ([68.142.224.84])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1FoGDV-00054c-Bw
	for nfs@lists.sourceforge.net; Thu, 08 Jun 2006 01:50:13 -0700
To: Wendy Cheng <wcheng@redhat.com>
In-Reply-To: <1149748767.3379.66.camel@localhost.localdomain>
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

I tried all the steps you talked 
about mount remains busy. The only
thing effective which you mentioned
is  killing nfsd. This causes kernel to 
release all reference to exported fs.

Steps to reproduce this problem :

1. mount <device> <mountpoint>
2. export it
3. unexport it
4. try umounting it. it wont



Thanks,
 kiran

--- Wendy Cheng <wcheng@redhat.com> wrote:

> On Thu, 2006-06-08 at 02:35 -0400, Wendy Cheng
> wrote:
> 
> 
> > 2.2.a Manually unexport filesystem. This is a
> tricky one. Note that if
> > kernel still hold the vfsmount reference for the
> export entry, umount
> > will fail. The "exportfs -u hostname:/export_path"
> doesn't necessarily
> > go into the kernel to delete the export entry (to
> drop vfsmount
> > reference count). You have to use either "exportfs
> -ua" or "exportfs
> > *:/export_path" to explicitly remove the export
> entry from RHEL 3
> > kernel. 
> 
> I'm famous for my typo :) ... should use "exportfs
> -u *:/export_path".
> 
> > 2.2.b Is NFS client holding a posix lock via NLM
> without releasing it ?
> > If yes, a quick and dirty way is to send lockd a
> signal ("kill -9
> > lockd"). This will signal lockd to drop the NLM
> locks (and subsequently
> > close the file).
> 
> -- Wendy
> 
> 
> 
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 


__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around 
http://mail.yahoo.com 


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
