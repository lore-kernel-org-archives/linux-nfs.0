From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS Write Delays
Date: Mon, 27 Aug 2007 13:17:30 -0400
Message-ID: <1188235050.6701.87.camel@heimdal.trondhjem.org>
References: <46CFB46D.8010405@csclub.uwaterloo.ca>
	<46CFBE60.1080609@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: David Bartley <dtbartle@csclub.uwaterloo.ca>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IPiDb-0001Vb-9A
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 10:17:39 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IPiDd-00006J-Fb
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 10:17:43 -0700
In-Reply-To: <46CFBE60.1080609@csclub.uwaterloo.ca>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Sat, 2007-08-25 at 01:30 -0400, David Bartley wrote:
> I was able to turn on debugging and I believe I see what's happening. 
> Here's what I see in /var/log/messages:
> 
> 01:01:31 kernel: nfs: write(/mterry2.avi(147458), 262144@0)
> 01:01:31 kernel: nfs: write(/mterry2.avi(147458), 262144@262144)
> 01:01:31 kernel: nfs: write(/mterry2.avi(147458), 262144@524288)
> 01:01:31 kernel: nfs: write(/mterry2.avi(147458), 262144@786432)
> .
> .
> .
> 01:01:38 kernel: nfs: write(/mterry2.avi(147458), 262144@417071104)
> 01:01:38 kernel: nfs: write(/mterry2.avi(147458), 201314@417333248)
> 01:01:38 kernel: nfs: flush(0:13/147458)
> 01:01:39 kernel: RPC: 62652 reserved req fffffc007b4fc000 xid 4e72324e
> 01:01:39 kernel: RPC: 62652 xprt_prepare_transmit
> 01:01:39 kernel: RPC: 62652 xprt_transmit(262332)
> 01:01:39 kernel: RPC: 62653 reserved req fffffc007b4fc128 xid 4f72324e
> 
> So it looks like it takes 7 seconds to read the entire file into memory 
> (the client has 6G of RAM), and only after it is read in is the file 
> pushed to the network. I'm wondering if there is some way to force the 
> data to start transmitting before it's does reading the file in.
> 
> -- David

Sure. You can simply tell the kernel to keep fewer dirty pages by
adjusting the values of /proc/sys/vm/dirty_background_ratio
and /proc/sys/vm/dirty_ratio.

See Documentation/filesystems/proc.txt and/or
Documentation/sysctl/vm.txt

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
