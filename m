From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfs4 and atomic O_APPEND
Date: Wed, 30 Nov 2005 09:34:17 -0500
Message-ID: <1133361257.8625.6.camel@lade.trondhjem.org>
References: <20051130142253.GA9317@blackhole.websupport.sk>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EhT2t-0002DC-Qv
	for nfs@lists.sourceforge.net; Wed, 30 Nov 2005 06:34:55 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EhT2l-0000Ko-4Y
	for nfs@lists.sourceforge.net; Wed, 30 Nov 2005 06:34:55 -0800
To: stanojr@blackhole.websupport.sk
In-Reply-To: <20051130142253.GA9317@blackhole.websupport.sk>
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

On Wed, 2005-11-30 at 15:22 +0100, stanojr@blackhole.websupport.sk
wrote:
> hello
> 
> is O_APPEND atomic in nfs4 ? or it will be sometime ?

 1) No.
 2) I doubt it.

Atomic O_APPEND doesn't mesh very well with the concept of client-side
caching, nor does it work particularly well in an environment where you
may have to retransmit RPC requests because a reply was lost (for
instance when the server reboots).

Cheers,
  Trond



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
