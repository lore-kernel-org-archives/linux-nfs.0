From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: rquota overflow fix never applied ?
Date: Tue, 30 Aug 2005 09:20:44 -0400
Message-ID: <200508300920.44405.vapier@gentoo.org>
References: <200508300108.52636.vapier@gentoo.org> <17171.63513.738531.932794@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EA62f-0001Ff-7U
	for nfs@lists.sourceforge.net; Tue, 30 Aug 2005 06:20:45 -0700
Received: from smtp.gentoo.org ([134.68.220.30])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EA62e-0007Zq-RH
	for nfs@lists.sourceforge.net; Tue, 30 Aug 2005 06:20:45 -0700
Received: from localhost ([127.0.0.1] helo=home.wh0rd.org)
	by smtp.gentoo.org with esmtp (Exim 4.43)
	id 1EA62Y-0002TQ-3G
	for nfs@lists.sourceforge.net; Tue, 30 Aug 2005 13:20:38 +0000
To: nfs@lists.sourceforge.net
In-Reply-To: <17171.63513.738531.932794@cse.unsw.edu.au>
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

On Tuesday 30 August 2005 02:09 am, Neil Brown wrote:
> On Tuesday August 30, vapier@gentoo.org wrote:
> > Gentoo and Fedora both apply an old patch to resolve an overflow issue
> > ... is this just a case of fixes never going upstream or is there a
> > reason this hasnt been applied ... if so, can someone please clue me in
> > ;)
>
> Well..... the patch does seem to be somewhat flawed .....
> There is a comment, and matching code, and the code is changed, but
> not the comment !!! :-)

i'm just the messenger, i didnt write it ;)

> However I don't think that would be the reason.  I think it either has
> not been sent upstream, it when it was it was missed and not resent.
>
> I have added it to my tree, with appropriate changes to the comment.
>
> However I seem to be a bit thick today and cannot see where the
> overflow is happening.
> dqblk is 6 u_int32_t's and 2 time_t's
> struct rquota (after rq_bhardlimit) is 8 u_int's
>
> On what arch are there different?
> (maybe time_t isn't 32bits everwhere, is that it?)

the overflow occurs on 64bit arches due to the size differences in time_t ... 
for original description of the issue and author of the patch, please see 
(sorry, should have included this in the first e-mail):
http://bugs.gentoo.org/72113
-mike


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
