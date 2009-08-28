From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: Re: 2008 mountd clean-up patch
Date: Fri, 28 Aug 2009 08:06:00 -0700
Message-ID: <1251471960.32255.16.camel@dyn9047022153>
References: <1F6E13E6-2D6F-4B80-B4E6-1B251012AF5A@oracle.com>
	 <1251410478.32255.14.camel@dyn9047022153>
	 <6A9AD7A7-1727-4AB5-BDD9-23AFE71B4208@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steve Dickson <SteveD@redhat.com>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:42570 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751171AbZH1PGF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Aug 2009 11:06:05 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n7SExvpa025827
	for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2009 10:59:57 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7SF67M1179706
	for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2009 11:06:07 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7SF67wX004794
	for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2009 11:06:07 -0400
In-Reply-To: <6A9AD7A7-1727-4AB5-BDD9-23AFE71B4208@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-08-28 at 09:43 -0400, Chuck Lever wrote:
> On Aug 27, 2009, at 6:01 PM, Frank Filz wrote:
> > On Thu, 2009-08-27 at 15:34 -0400, Chuck Lever wrote:
> >> I'm looking at a 2008 nfs-utils clean up done in commit 7a817c45.  It
> >> has this hunk in it:
> >>
> >> @@ -111,7 +111,7 @@ void auth_unix_ip(FILE *f)
> >>         else if (client)
> >>                 qword_print(f, *client?client:"DEFAULT");
> >>         qword_eol(f);
> >> -       xlog(D_CALL, "auth_unix_ip: client %p '%s'", client, *client?
> >> client: "DEFAULT");
> >> +       xlog(D_CALL, "auth_unix_ip: client %p '%s'", client, client?
> >> client: "DEFAULT");
> >>
> >>         if (client) free(client);
> >>         free(he);
> >>
> >> You changed the '*client ? client : "DEFAULT"' expression in the
> >> xlog() call, but not in the qword_print() call right above it.  Which
> >> of these is correct, and why do they need to be different from each
> >> other?
> >>
> >> Seems to me _both_ should be 'client ? client : "DEFAULT"' (ie.
> >> without the dereference).
> >
> > There would be no point to not dereferencing client, it has already  
> > been
> > checked for NULL by "else if (client)". What it is doing is if the
> > client string is empty, it is printing "DEFAULT", and if the client
> > string is NULL, then it prints nothing.
> >
> > Perhaps the xlog should be:
> >
> >
> > 	if (client)
> > 		xlog(D_CALL, "auth_unix_ip: client %p '%s', client, *client? 
> > client: "DEFAULT");
> > 	else
> > 		xlog(D_CALL, "auth_unix_ip: client NULL");
> 
> To confirm, then, the fix in 7a817c45 is bogus?

>From what I can see, yes.

Frank


