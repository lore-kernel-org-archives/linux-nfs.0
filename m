From: Yusuf Goolamabbas <yusufg@outblaze.com>
Subject: Re: number of files per directory under ext3 & directory indexing
Date: Tue, 18 Feb 2003 10:54:26 +0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030218025426.GB1014@outblaze.com>
References: <20030218022449.85354.qmail@web12202.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, SteveD@RedHat.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 202-77-223-51.outblaze.com ([202.77.223.51] helo=corpmail.outblaze.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18kxsx-0002wQ-00
	for <nfs@lists.sourceforge.net>; Mon, 17 Feb 2003 18:53:31 -0800
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by corpmail.outblaze.com (Postfix) with ESMTP id 887AE7D7E
	for <nfs@lists.sourceforge.net>; Tue, 18 Feb 2003 03:02:00 +0000 (GMT)
Received: from yusufg.portal2.com (202-77-223-125.outblaze.com [202.77.223.125])
	by corpmail.outblaze.com (Postfix) with SMTP id 318B8520D1
	for <nfs@lists.sourceforge.net>; Tue, 18 Feb 2003 03:02:00 +0000 (GMT)
To: Alan Powell <lakerfaniam2@yahoo.com>
In-Reply-To: <20030218022449.85354.qmail@web12202.mail.yahoo.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Alan, as a data-point the htree patch was included in the first beta of
Phoebe (upcoming Redhat version) but removed in the second beta since it
was probably not considered production quality. In a post to ext3-users,
sct says its still not 100% rock-solid

You might want to consider either using XFS for your fileserver or
modifying your directory structure

> Can you share your experiences of when performance
> starts dropping dramatically based on the number of
> files in a directory under ext3? (assuming that you
> haven't applied any directory indexing patch)
> 
> I had always thought that ext3 performed well with a
> large number of files per directory, but apparently
> directory indexing, which would substantially improve
> performance of large directories, has yet to be added
> to the kernel (submitted patch:
> http://lwn.net/Articles/11481/).


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
