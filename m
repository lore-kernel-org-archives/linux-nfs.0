From: Jeff Layton <jlayton@redhat.com>
Subject: Re: Implementing nfs in vfs
Date: Thu, 24 May 2007 09:09:54 -0400
Message-ID: <20070524090954.3b656080.jlayton@redhat.com>
References: <359369180705240404s2887d881uf591119b6397683d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HrD4p-0004dh-FC
	for nfs@lists.sourceforge.net; Thu, 24 May 2007 06:09:59 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HrD4r-0006Qc-Tr
	for nfs@lists.sourceforge.net; Thu, 24 May 2007 06:10:02 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l4OD9tBF008272
	for <nfs@lists.sourceforge.net>; Thu, 24 May 2007 09:09:55 -0400
Received: from pobox.corp.redhat.com (pobox.corp.redhat.com [10.11.255.20])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l4OD9tYM018213
	for <nfs@lists.sourceforge.net>; Thu, 24 May 2007 09:09:55 -0400
Received: from tleilax.poochiereds.net (vpn-14-153.rdu.redhat.com
	[10.11.14.153])
	by pobox.corp.redhat.com (8.13.1/8.13.1) with SMTP id l4OD9sLD013406
	for <nfs@lists.sourceforge.net>; Thu, 24 May 2007 09:09:54 -0400
In-Reply-To: <359369180705240404s2887d881uf591119b6397683d@mail.gmail.com>
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

On Thu, 24 May 2007 16:34:08 +0530
"Suraj Jacob" <suraj.email@gmail.com> wrote:

> Hi,
> Please forgive me if this is a naive question or if it does not belong to
> this list.
> 
> All the nfs implementations that Ive seen are always on top of local
> filesystems. Why is it that there is no implementation that could bypass the
> local fs like ext2 and implement a vfs layer for nfs? or eliminate vfs too
> and write a server operating on raw disks(like some databases do for
> performance)?
> 
> 
> Thanks in advance
> 

So you're wanting to make a backend filesystem that's somehow "better"
for nfs than a traditional on-disk filesystem? I suppose that's
possible, but it's not clear to me that it would be a huge performance
win.

Rather than reinventing the wheel, it would seem more reasonable to me
to identify the performance bottlenecks you see when dealing with the
backend filesystem and deal with those.

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
