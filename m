From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC,PATCH 0/14] A transport switch for knfsd
Date: Wed, 16 May 2007 16:53:17 -0400
Message-ID: <20070516205316.GC18927@fieldses.org>
References: <20070516191821.GF9626@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Thomas Talpey <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>
To: Greg Banks <gnb@sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HoQUo-0000mz-25
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 13:53:18 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HoQUp-000368-Mb
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 13:53:21 -0700
In-Reply-To: <20070516191821.GF9626@sgi.com>
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

On Thu, May 17, 2007 at 05:18:21AM +1000, Greg Banks wrote:
> These 14 patches are an experimental transport switch for knfsd.
> They're based on Tom Tucker's 01-svc-xprt-switch.patch from the
> nfsrdma project November release, but redesigned to provide as simple
> and clean an abstraction as possible to new transport-specific code.
> Various messy details of flags, reference counts and other behaviour
> which are currently redundantly handled in both TCP and UDP code,
> will be handled in generic code now.  This makes the task of writing
> new transport code easier and less prone to breakage.

Are there other conjectured future users besides rdma?

What's happened to server-side ipv6, by the way?

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
