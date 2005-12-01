From: Vince Busam <vbusam@google.com>
Subject: Re: mtime not updated in client cache?
Date: Wed, 30 Nov 2005 17:06:47 -0800
Message-ID: <438E4CA7.2050405@google.com>
References: <438B9C44.4030305@google.com> <1133225130.12178.9.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ehcud-0004Dl-A1
	for nfs@lists.sourceforge.net; Wed, 30 Nov 2005 17:07:03 -0800
Received: from smtp-out.google.com ([216.239.45.12])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Ehcuc-0008Ih-2Z
	for nfs@lists.sourceforge.net; Wed, 30 Nov 2005 17:07:03 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1133225130.12178.9.camel@lade.trondhjem.org>
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

Trond Myklebust wrote:
> On Mon, 2005-11-28 at 16:09 -0800, Vince Busam wrote:
> 
>>The following code snippet run on a 2.6.13.4 (+CITI patch) client shows that mtime doesn't 
>>get updated unless fclose() is called before stat, or O_DIRECT is used.  In 2.4, the stat 
>>would return an updated mtime.  Is this a bug, or expected cache behavior?
> 
> 
> That is a known issue that should be fixed in 2.6.15-rcX
> 

Awesome.  Is there a patch I can help test out?

Vince


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
