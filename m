From: Bernd Strieder <strieder@informatik.uni-kl.de>
Subject: Re: NFS mount in a changing network
Date: Thu, 16 Feb 2006 11:16:24 +0100
Message-ID: <200602161116.24884.strieder@informatik.uni-kl.de>
References: <200602151716.18601.strieder@informatik.uni-kl.de> <1140031426.7888.28.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F9gBh-0004Tg-Au
	for nfs@lists.sourceforge.net; Thu, 16 Feb 2006 02:16:37 -0800
Received: from mailgate1.uni-kl.de ([131.246.120.5])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1F9gBf-0006CD-JQ
	for nfs@lists.sourceforge.net; Thu, 16 Feb 2006 02:16:37 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1140031426.7888.28.camel@lade.trondhjem.org>
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

Hello,

Trond Myklebust wrote:
> On Wed, 2006-02-15 at 17:16 +0100, Bernd Strieder wrote:
> > Attaching gdb to the process and setting a breakpoint on
> > printf, after calling ferror returning 1, it is clear that
> > printf does not output anything. errno has the value 116
> > ESTALE.
> >
> > How can this happen, an existing file gets into deleted status
> > on the client, without anybody having issued an unlink or
> > whatever? Or do stale filehandles finally result in deleted?
>
> See http://nfs.sourceforge.net/#faq_a10

There are 5 common reasons listed.

2. and 3. do not match, the file has not been touched on the server 
or any other client.

5. does not match, it is XFS on the server side. There used to be 
issues with NFS and XFS in the 2.4.x era, I had several times 
hanging xfsdump probably on concurrent NFS accesses. But xfsdump 
is not being used any more since a few months.

This leaves two reasons, 1. and 4.

4., i.e. a changed device id on the server should not be the 
reason, the fs on the server is XFS on a regular scsi 
disc /dev/sdc1, with manually assigned scsi ids, and no hardware 
changes. Nothing should change on bootup.

If it is the 1. then I must have done an error during the whole 
process of adding the additional IP addresses. The biggest error 
probably trying it at all without any instructions.

Usually if a server is booted NFS clients hang, until the server is 
back again. This is what happened always in the case of the 
hanging xfsdumps, this is what I was relying on, when doing the 
server reboot. The question is, whether during a usual server 
reboot a client might interpret anything, that the server or the 
file in question will not be reachable any more, before all 
daemons are back again, then ESTALE would be the only acceptable 
to do. E.g. when adding the IP addresses the old DNS names have 
not been kept. Could this matter? What happens if directories from 
the same fs are mounted via different IP addresses, might this 
matter. 

The exports line in question is:

/homes  @crime(rw,async,no_root_squash) 192.168.16.28
(rw,async,no_root_squash)

@crime being a netgroup with the new addresses. This netgroup used 
to be the old addresses.

The ultimate question, which might be helpful to others, which I 
haven't found anything written on anywhere is:

What are the things to care about, if you want to switch the 
network configuration of a NFS server and a NFS client if umount 
must be avoided? Are there any chances to get this cleanly done?

Thanks,

Bernd Strieder


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
