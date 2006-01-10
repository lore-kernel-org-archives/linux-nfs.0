From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS client getting server not responding on kernel
	2.6.15 with nfs-client-patch
Date: Tue, 10 Jan 2006 08:37:57 -0800
Message-ID: <1136911077.9223.13.camel@lade.trondhjem.org>
References: <BAY7-F206E8494F3B5CB3B898ABCB9250@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EwMW9-00066W-9X
	for nfs@lists.sourceforge.net; Tue, 10 Jan 2006 08:38:41 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EwMW7-0002tK-Pi
	for nfs@lists.sourceforge.net; Tue, 10 Jan 2006 08:38:41 -0800
To: Pelle Svensson <pelle2004@hotmail.com>
In-Reply-To: <BAY7-F206E8494F3B5CB3B898ABCB9250@phx.gbl>
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

On Tue, 2006-01-10 at 17:20 +0100, Pelle Svensson wrote:
> Hi,
> 
> I'm running a 2.6.15 client on a small ARM embedded platform with the root 
> system as NFS client
> (root=/dev/nfs). The server is Fedora core 3.
> 
> I'm getting about 2 to 6 errors as below on the first larger operation on 
> the ARM system after
> booting the system. Smaller this like #echo "dof to file" >/tmp/dog is okay
> 
> nfs: server 192.168.x.x not responding, still trying.
> nfs: server 192.168.x.x not responding, still trying.
> nfs: server 192.168.x.x not responding, still trying.
> 
> This happens when I read a lot from the server and at the same time try's to 
> write that back as an
> image file. Looking at the output from Ethereal shows that all 'V2 Read ...' 
> request gets an answer
> from the server but when the client issu the first section of 'V2 Write ...' 
> there are no answers.
> After a short while the client retransmitt same request in a loop.
> 
> The command I use is 'mkfs.jffs2' which reads a image of the root system and 
> writes that
> into a image file. Reads about 46M and supose to writes about 20M.
> 
> Any ideas what to do next?

A lot of the ARM embedded systems use really cheap and crappy NICs with
almost no on-board memory. I'd therefore try the following:

Use the 'tcp' mount option

or

set the "rsize" and "wsize" mount options to some smaller value (4096 or
even 1024).

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
