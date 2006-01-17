From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Linux NFS Client ignores quotas
Date: Tue, 17 Jan 2006 15:45:43 -0500
Message-ID: <1137530743.7855.162.camel@lade.trondhjem.org>
References: <43CD547E.9080808@netidea.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Eyxia-0005eu-JS
	for nfs@lists.sourceforge.net; Tue, 17 Jan 2006 12:46:16 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EyxiY-0002PD-63
	for nfs@lists.sourceforge.net; Tue, 17 Jan 2006 12:46:16 -0800
To: Kirk Ismay <captain@netidea.com>
In-Reply-To: <43CD547E.9080808@netidea.com>
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

On Tue, 2006-01-17 at 12:33 -0800, Kirk Ismay wrote:
> I have an nfs client that mounts /home from another linux file server. 
> Both run Linux 2.4.25 kernels on Debian woody. Quotas are enabled for 
> /home and are working properly on the server, but on the client they are 
> ignored.

The NFS protocol has no support for quotas. It is up to the server to
enforce those, not the client.

Cheers,
  Trond



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
