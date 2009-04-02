From: Miles Bader <miles-mXXj517/zsQ@public.gmane.org>
Subject: Re: [GIT PULL] Please pull the first batch of NFS client changes (and
	cachefs merge)...
Date: Fri, 3 Apr 2009 03:56:09 +0900
Message-ID: <fc339e4a0904021156ke84b45elc55d07acea795c99@mail.gmail.com>
References: <alpine.LFD.2.00.0904010935000.4130@localhost.localdomain>
	 <1238522824.6577.5.camel@heimdal.trondhjem.org>
	 <19756.1238606665@redhat.com> <buoprfv8yjf.fsf@dhlpc061.dev.necel.com>
	 <1526.1238664007@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Howells
	<public-dhowells-H+wXaHxf7aLQT0dZR+AlfA-z5DuStaUktnZ+VzJOa5vwg@public.gmane.org>,
	Linus Torvalds
	<public-torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b-z5DuStaUktnZ+VzJOa5vwg@public.gmane.org>,
	Trond Myklebust
	<public-Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA-z5DuStaUktnZ+VzJOa5vwg@public.gmane.org>,
	public-linux-nfs-u79uwXL29TY76Z2rM5mHXA-z5DuStaUktnZ+VzJOa5vwg@public.gmane.org,
	Linux Kernel Mailing List
	<public-linux-kernel-u79uwXL29TY76Z2rM5mHXA-z5DuStaUktnZ+VzJOa5vwg@public.gmane.org>
To: David Howells <dhowells@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from blaine.gmane.org ([80.91.229.8]:34666 "EHLO hugh.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755328AbZDBTBA convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 15:01:00 -0400
Received: from public by hugh.gmane.org with local (Exim 4.63)
	(envelope-from <public-z5DuStaUktnZ+VzJOa5vwg@public.gmane.org>)
	id 1LpS6L-0008EF-KI
	for linux-nfs@vger.kernel.org; Thu, 02 Apr 2009 20:57:21 +0200
In-Reply-To: <1526.1238664007@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



2009/4/2 David Howells <dhowells@redhat.com>:
> Thanks! =A0That's pretty much what I wanted... =A0The one thing that'=
s missing is
> the ability to give this to C-x b, but I suppose C-x f will have to d=
o.

Not sure I understand -- it actually changes the name of the buffers,
so C-x b should see the names too...
(by default it retroactively renames existing buffers to reflect
needed "uniquification" too)

-Miles

--=20
Do not taunt Happy Fun Ball.

