From: James Pearson <james-p@moving-picture.com>
Subject: File system cache corruptions?
Date: Wed, 06 Oct 2004 17:40:58 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4164201A.8020005@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CFEqj-0000pw-1H
	for nfs@lists.sourceforge.net; Wed, 06 Oct 2004 09:41:09 -0700
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CFEqd-00024K-J7
	for nfs@lists.sourceforge.net; Wed, 06 Oct 2004 09:41:08 -0700
Received: from minion.mpc.local ([172.16.11.112] helo=moving-picture.com)
	by moving-picture.com with esmtp (Exim 4.24)
	id 1CFEqY-0004ew-Cx
	for nfs@lists.sourceforge.net; Wed, 06 Oct 2004 17:40:58 +0100
To: nfs@lists.sourceforge.net
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

Very occasionally we get problems where by an application on an NFS 
server fails to load on one NFS client - for example just had one which 
fails when you try to run it:

/path/to/nfs/mounted/binary: relocation error: 
/path/to/nfs/mounted/shared/object.so: symbol , version GLIBC_2.0 not 
defined in file libpthread.so.0 with link time reference

I 'fixed' the problem by running a simple tool on the client that just 
grabs memory - and hence flushes any cached files.

The application in question hasn't changed in months.

In this case, the client is running Fedora Core 1 with a 2.4.22 based 
kernel (with Trond's NFS client patches), but we've seen similar 
problems with Redhat 7.2 based machines with a variety of kernel.org 
2.4.X based kernels.

Any ideas on what may be causing this?

James Pearson


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
