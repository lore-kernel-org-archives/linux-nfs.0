From: Greg Banks <gnb@sgi.com>
Subject: Re: NFS behavior as seen by EXT2
Date: Tue, 20 Dec 2005 10:14:32 +1100
Message-ID: <20051219231432.GA30403@sgi.com>
References: <28437eef0512190352l34a0ba47g96be56cb455608cf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EoUDL-0003Tq-AQ
	for nfs@lists.sourceforge.net; Mon, 19 Dec 2005 15:14:43 -0800
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EoUDJ-0008ES-Oy
	for nfs@lists.sourceforge.net; Mon, 19 Dec 2005 15:14:43 -0800
To: Muhammad Irfan Nazir <arfan.se@gmail.com>
In-Reply-To: <28437eef0512190352l34a0ba47g96be56cb455608cf@mail.gmail.com>
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

On Mon, Dec 19, 2005 at 04:52:30PM +0500, Muhammad Irfan Nazir wrote:
> Where as at EXT2 level I was supposing to get the position zero as the file
> was closed in the last reading and all its memory references were deleted.
> 
> How/where does the nfs keeps the record of the previous reading position?

In the NFS client.  Each READ call passes the filehandle, offset and
size to be read.  On traditional UNIX servers, read and readahead
behaviour is controlled entirely by the client.  However the Linux
NFS server also keeps a cache of read-ahead state for a small number
of files (search for "raparm" in fs/nfsd/vfs.c) thus enabling it to
do server-side readahead also.

> I want to get the reference to the documentation stating the read/write
> behaviour of nfs.

RFC1813 would be a good start.

http://www.faqs.org/rfcs/rfc1813.html

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
