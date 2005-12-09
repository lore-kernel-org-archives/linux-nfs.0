From: Peter Staubach <staubach@redhat.com>
Subject: Re: mtime not updated in client cache?
Date: Fri, 09 Dec 2005 11:40:02 -0500
Message-ID: <4399B362.40601@redhat.com>
References: <044B81DE141D7443BCE91E8F44B3C1E201332862@exsvl02.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Vince Busam <vbusam@google.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EklID-0003Ax-Ni
	for nfs@lists.sourceforge.net; Fri, 09 Dec 2005 08:40:21 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EklID-0001ql-9B
	for nfs@lists.sourceforge.net; Fri, 09 Dec 2005 08:40:21 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <044B81DE141D7443BCE91E8F44B3C1E201332862@exsvl02.hq.netapp.com>
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

Lever, Charles wrote:

>
>i like the idea.
>
>do you need to prevent writes *during* the stat() call?  or do you just
>want to make sure that any writes that happened *before* the stat() call
>have the intended side-effects on the file size and mtime?  that might
>be worth a comment or two.
>
>  
>

The semantic is generally that any write(2) calls made before the 
stat(2) call
should be reflected in the update mtime.

>are you flushing dirty mmap'd data too?  or can this be skipped until
>msync() time?
>
>and now that you have added a "flush but don't commit" flag to
>nfs_sync_file, maybe we might consider using that (optionally) at file
>close() time, like some other NFS client implementations do.  :^)
>  
>

This seems like a pretty dangerous thing to do.  I've thought about it
because it would seem to make close-to-open less expensive, but it 
introduces
the possibility of data loss without the application being aware.  If the
data is not committed at close(2), then if it can not be committed when it
needs to be committed, then there is no way to return an error to the
application.  A somewat contrived but still possible scenario is that the
server crashes, comes back up, and the file system fills up before the 
client
can retransmit all of the data.  In this case, the data will be lost, but
the application thought that it was all stored because no system calls
returned any errors.

    Thanx...

       ps


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
