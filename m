From: Jeff Layton <jlayton@redhat.com>
Subject: Re: NFSv4 uninitialized mtime
Date: Sat, 30 Jun 2007 07:19:43 -0400
Message-ID: <20070630071943.683b5271.jlayton@redhat.com>
References: <nfs-valinux.20070628064127.a769bc53.jlayton@redhat.com>
	<46857F06.102@ligo.caltech.edu>
	<20070629181234.b70f6f7f.jlayton@redhat.com>
	<46858831.2040504@ligo.caltech.edu>
	<20070629223528.fe7ac38d.jlayton@redhat.com>
	<4685C95C.4050008@ligo.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Stuart Anderson <anderson@ligo.caltech.edu>,
	nfs@lists.sourceforge.net
To: "Erik A. Espinoza" <espinoza@ligo.caltech.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I4azY-0004BX-Co
	for nfs@lists.sourceforge.net; Sat, 30 Jun 2007 04:19:52 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I4azb-00076q-K5
	for nfs@lists.sourceforge.net; Sat, 30 Jun 2007 04:19:55 -0700
In-Reply-To: <4685C95C.4050008@ligo.caltech.edu>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Fri, 29 Jun 2007 20:09:16 -0700
"Erik A. Espinoza" <espinoza@ligo.caltech.edu> wrote:

> Interestingly enough, using Solaris as a client and server does not have
> mtime issues.
> 

They're probably using NFSv3 semantics and are clobbering the mtime and
atime irregardless of the attrmask sent back.

> 
> Should I attempt to get a tcpdump of Sol NFSv4 server and client combo
> doing the same thing?

I doubt it will tell us more than we already know. The captures we
already have indicate that they are not following the RFC.

> 
> Erik
> 
> Jeff Layton wrote:
> > On Fri, 29 Jun 2007 15:31:13 -0700
> > "Erik A. Espinoza" <espinoza@ligo.caltech.edu> wrote:
> > 
> >> Jeff Layton wrote:
> >>> The attribute mask seems to be zeroed out here as well. What sort of server is this?
> >>> -- Jeff
> >>>
> >> # cat /etc/release
> >> Solaris 10 11/06 s10x_u3wos_10 X86
> >> Copyright 2006 Sun Microsystems, Inc. All Rights Reserved.
> >> Use is subject to license terms.
> >> Assembled 14 November 2006
> >> # uname -v
> >> Generic_118855-36
> >>
> > 
> > Ok, so looks like Solaris 10 has this bug too. You might want to open a
> > case with Sun if you have a support contract with them. Let them know
> > that they're not sending a correct attribute mask when they send an
> > exclusive create reply.
> > 
> > You might also try opening a bug about this at the opensolaris site.
> > 
> 
> -- 
> Erik A. Espinoza
> Systems Administrator
> LIGO/Caltech - MS 18-34
> Pasadena, CA 91125
> Ph: 626-395-8517
> 
> -------------------------------------------------------------------------
> This SF.net email is sponsored by DB2 Express
> Download DB2 Express C - the FREE version of DB2 express and take
> control of your XML. No limits. Just data. Click to get it now.
> http://sourceforge.net/powerbar/db2/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 


-- 
Jeff Layton <jlayton@redhat.com>

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
