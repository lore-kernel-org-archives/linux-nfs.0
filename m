From: Al Active <LLLActive@GMX.Net>
Subject: Re: Searching NFS Archives
Date: Wed, 11 Jan 2006 12:24:53 +0100
Message-ID: <1136978693.6819.96.camel@L10-WS-AWS1.AWS>
References: <200601111140.30115.vincent.roqueta@ext.bull.net>
	 <1136976671.6819.85.camel@L10-WS-AWS1.AWS>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Vincent Roqueta <vincent.roqueta@ext.bull.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ewe6D-0003zt-1b
	for nfs@lists.sourceforge.net; Wed, 11 Jan 2006 03:25:05 -0800
Received: from mail.gmx.de ([213.165.64.21] helo=mail.gmx.net)
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1Ewe6C-0000Gs-Gy
	for nfs@lists.sourceforge.net; Wed, 11 Jan 2006 03:25:05 -0800
To: nfs@lists.sourceforge.net
In-Reply-To: <1136976671.6819.85.camel@L10-WS-AWS1.AWS>
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

On Wed, 2006-01-11 at 11:51 +0100, Al Active wrote:
> On Wed, 2006-01-11 at 11:40 +0100, Vincent Roqueta wrote:

> I am using the one with the above kernel. How do I find out which
> version it is? From the /var/log/messages I see:
> "Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory"; I
> take it to be v4 then.
> 

Something else from the messages, when I look at the next line. Can this
mean something?

...
Jan 11 10:14:09 L10 kernel: NFSD: Using /var/lib/nfs/v4recovery as the
NFSv4 state recovery directory
Jan 11 10:14:09 L10 kernel: 
NFSD: recovery directory /var/lib/nfs/v4recovery doesn't exist
                                                 ^^^^^^^^^^^^^
Jan 11 10:14:09 L10 kernel: NFSD: starting 90-second grace period
...

:-)
Al




-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
